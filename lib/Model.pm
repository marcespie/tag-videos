use v5.36;

package Model;
use DBI;

my $dbpath = "$FindBin::Bin/mydb";

my $requests = {
	fh => qq{insert into file (path) values (?)},
	stmt => qq{select tag from tag order by tag},
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
	suggest =>
	    qq{select distinct(tag.tag) from tag 
	    	join filetag on filetag.tagid=tag.id
		join filetag t1 on t1.fileid=filetag.fileid
		join tag t2 on t2.id=t1.tagid
		where t2.tag=? order by tag.tag}
};

sub connect($class)
{
	my $dbpath = "$FindBin::Bin/mydb";
	my $o = bless { 
		db => DBI->connect("dbi:SQLite:dbname=$dbpath", "", "")
	    }, $class;
	while (my ($k, $v) = each %$requests) {
		$o->{$k} = $o->db->prepare($v);
	}
	return $o;
}

sub db($o)
{
	return $o->{db};
}

sub selectcol_arrayref($o, $key, @rest)
{
	return $o->db->selectcol_arrayref($o->{$key}, {}, @rest);
}

1;
