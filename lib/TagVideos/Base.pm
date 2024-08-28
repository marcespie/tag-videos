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

package TagVideos::Base;
use DBI;
use FindBin;

sub dbpath($, $param)
{
	return $param // $ENV{DBPATH} // "$FindBin::Bin/lib/mydb";
}

sub connect($class, $param = undef, $readonly = 0)
{
	my $p = $class->dbpath($param);
	my $h = {};
	if ($readonly) {
		$h->{ReadOnly} = 1;
	}
	if (!-f $p) {
		say "Creating database $p";
		$class->create($p);
	}
	return DBI->connect("dbi:SQLite:dbname=$p", "", "", $h);
}

sub create($class, $p)
{
	my $db = DBI->connect("dbi:SQLite:dbname=$p", "", "");
	undef $/;
	# XXX somehow DBI want separate statements, so we split on ;
	for my $sql(split /;/, <DATA>) {
		$db->do($sql.';');
	}
}

1;
__DATA__
-- XXX maybe it would be better to have a directory/file separation
-- together with a file view ?
CREATE TABLE if not exists file 
	(Id integer primary key, path text unique on conflict ignore);
CREATE TABLE if not exists tag 
	(Id integer primary key, tag text unique on conflict ignore);
CREATE TABLE if not exists filetag 
	(Id integer primary key, FileId integer, TagId integer, 
	constraint nodups unique (FileId, TagId) on conflict ignore);
-- just in case one wants to check
create view _filetag as
	select tag.tag as tag, file.path as path
	from filetag
	    join tag on filetag.tagid=tag.id
	    join file on filetag.fileid=file.id;
