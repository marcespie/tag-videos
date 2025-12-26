#! /usr/bin/perl
use v5.36;

# Copyright (c) 2024 Marc Espie <espie@openbsd.org>
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

package TagVideos::Model;
use TagVideos::Base;
our @ISA = qw(TagVideos::Base);

my $requests = {
	fh => qq{insert into file (path) values (?)},
	alltags => qq{select tag from tag order by tag},
	findid => qq{select id from file where path=?},
	findtags => 
	    qq{select tag.tag from tag 
		join filetag on tagid=tag.id
		join file on fileid = file.id
		where fileid = ? order by tag.tag},
	createtag => qq{insert into tag (tag) values (?)},
	inserttag => 
	    qq{insert into filetag (fileid, tagid)
		values (?, (select id from tag where tag=?))},
	deletetag =>
	    qq{delete from filetag where fileid=?
		and tagid=(select id from tag where tag=?)},
	suggestions =>
	    qq{select tag.tag, count(filetag.id) from tag 
	    	join filetag on filetag.tagid=tag.id
		join filetag t1 on t1.fileid=filetag.fileid
		join tag t2 on t2.id=t1.tagid
		where t2.tag=? 
		    and tag.id!=t2.id 
		    and tag.id not in 
			(select tagid from filetag where fileid=?)
		group by tag.tag},
	addnewtag =>
	    qq{insert into filetag (tagid, fileid)
	    	select t1.id,filetag.fileid from filetag 
		    join tag t1 
		    join tag t2 on t2.id=filetag.tagid
		    where t1.tag=? and t2.tag=?},
	deleteoldtag =>
	    qq{delete from filetag where
		tagid=(select id from tag where tag=?)},
	readdescr =>
	    qq{select descr from descr where fileid=?},
	setdescr =>
	    qq{insert or replace into descr (descr, fileid) values (?, ?)},
	readrule =>
		qq{select rule from rules},
	writerule =>
		qq{insert into rules (rule) values (?)},
	deleterule => qq{delete from rules where rule like '%'||?||'%'},
	wipetags =>
	    qq{delete from filetag where fileid=?},
	occurrences =>
	    qq{select tag.tag, count(filetag.id) from tag 
	    	join filetag on filetag.tagid=tag.id 
		group by filetag.tagid 
		order by count(filetag.id), tag.tag},
};

sub connect($class, $database)
{
	my $o = bless { 
		db => $class->SUPER::connect($database, {})
	    }, $class;
	while (my ($k, $v) = each %$requests) {
		$o->{$k} = $o->db->prepare($v);
	}
	return $o;
}

sub nopath($)
{
	say STDERR "Error: can't use this command without a path";
}

sub db($o)
{
	return $o->{db};
}

sub id($o)
{
	return $o->{id};
}

sub selectcol_arrayref($o, $key, @rest)
{
	return $o->db->selectcol_arrayref($o->{$key}, {}, @rest);
}

sub set_path($self, $path)
{
	$self->{fh}->execute($path);

	my $id;
	$self->{findid}->bind_columns(\$id);
	$self->{findid}->execute($path);
	while ($self->{findid}->fetch) {
	}
	$self->{id} = $id;
	$self->{path} = $path;
}

sub find_tags($self)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	return $self->selectcol_arrayref('findtags', $self->id);
}

sub create_tag($self, $tag)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	$self->{createtag}->execute($tag);
	$self->{inserttag}->execute($self->id, $tag);
}

sub delete_tag($self, $tag)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	$self->{deletetag}->execute($self->id, $tag);
}

sub suggestions($self, $tag)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	my $s = $self->{suggestions};
	my $h = {};
	$s->execute($tag, $self->id);
	my ($t, $count);
	$s->bind_columns(\($t, $count));
	while ($s->fetch) {
		$h->{$t} = $count;
	}
	return $h;
}

sub rename_tag($self, $old, $new)
{
	$self->{createtag}->execute($new);
	$self->{addnewtag}->execute($new, $old);
	$self->{deleteoldtag}->execute($old);
}

sub read_descr($self)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	my $s = $self->{readdescr};
	$s->execute($self->id);
	my $descr;
	$s->bind_columns(\($descr));
	while ($s->fetch) {
	}
	return $descr;
}

sub set_descr($self, $descr)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	$self->{setdescr}->execute($descr, $self->id);
}

sub insertif($self, $not, @tags)
{
	my $subquery =
	    qq{file.id in (select fileid from filetag join tag on tagid=tag.id
		    where tag.tag like ?)};

	my @extra = (qq{tag.tag like ?});
	for my $tag (@tags) {
		my $not = '';
		if ($tag =~ s/^!//) {
			$not = " not ";
		}

		push(@extra, 
		    "file.id $not in (select fileid from filetag ".
			"join tag on tagid=tag.id where tag.tag like ?)");
	}
	my $query =
		qq{insert into filetag (tagid, fileid) 
			select tag.id, file.id from tag join file where }
		.join(' and ', @extra);
	return $self->db->prepare($query);
}

sub parse_rules($self)
{
	my $counter = 0;
	for my $rule (@{$self->selectcol_arrayref('readrule')}) {
		$self->parse_rule($rule);
		$counter++;
	}
	say "Executed $counter permanent rules" if $counter;
}

sub show_rules($self)
{
	for my $rule (@{$self->selectcol_arrayref('readrule')}) {
		say $rule;
	}
}

sub delete_rule($self, $partial)
{
	$self->{deleterule}->execute($partial);
}

sub parse_rule($self, $rule)
{
	if ($rule =~ m/^\!?tag\s+(.*)\s+IF\s+(.*)/) {
		my ($set, $cond) = (lc($1), lc($2));
		my @tags = split(/\s+/, $cond);
		my $stmt = $self->insertif(0, @tags);
		my $not_stmt = $self->insertif(1, @tags);
		for my $tag (split(/\s+/, $set)) {
			if ($tag =~ s/^\!//) {
				$not_stmt->execute($tag, @tags);
			} else {
				$stmt->execute($tag, @tags);
			}
		}
	} elsif ($rule =~ m/^\!?rename\s+(\S+)\s+(\S+)\s*$/) {
		$self->rename_tag(lc($1), lc($2));
	} else {
		say "Error: can't parse $rule";
		return;
	}
	if ($rule =~ s/^!//) {
		$self->{writerule}->execute($rule);
	}
}

sub wipe_tags($self)
{
	if (!defined $self->id) {
		$self->nopath;
		return;
	}
	$self->{wipetags}->execute($self->id);
}

sub occurrences($self, $limit)
{
	my $s = $self->{occurrences};
	$s->execute;
	my ($tag, $count);
	$s->bind_columns(\($tag, $count));
	my @r;
	while ($s->fetch) {
		last if $count > $limit;
		push(@{$r[$count]}, $tag);
	}
	$s->finish;
	return @r;
}

sub cleanup($self)
{
	$self->parse_rules;
	$self->db->do(
	    qq{delete from tag where id in 
	    	(select id from tag where tag.id not in 
		    (select tagid from filetag))});
	$self->db->disconnect;
}
1;
