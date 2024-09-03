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

sub dbpath($, $path)
{
	return $path // $ENV{DBPATH} // $ENV{HOME}."/video_tags";
}

sub connect($class, $path = undef, $h = {})
{
	my $p = $class->dbpath($path);
	if (!-f $p) {
		say "Creating database $p";
		$class->create($p);
	}
	my $db = DBI->connect("dbi:SQLite:dbname=$p", "", "", 
	    {
		RaiseError => 1,
		PrintError => 0});
	eval {
	    $db->prepare("select * from descr");
	    $db->prepare("select * from rules");
	};
	if ($@) {
		say "Updating database $p";
		$class->create($p);
	}
	return DBI->connect("dbi:SQLite:dbname=$p", "", "", $h);
}

sub create($class, $p)
{
	my $db = DBI->connect("dbi:SQLite:dbname=$p", "", "");
	undef $/;
	# XXX somehow DBI want separate statements, so we split on ;
	for my $sql (split /;/, <DATA>) {
		$db->do($sql.';');
	}
}

1;
__DATA__
-- XXX maybe it would be better to have a directory/file separation
-- together with a file view ?
PRAGMA encoding = "UTF-8";
CREATE TABLE if not exists file 
	(Id integer primary key, path text unique on conflict ignore);
CREATE TABLE if not exists tag 
	(Id integer primary key, tag text unique on conflict ignore);
CREATE TABLE if not exists filetag 
	(Id integer primary key, FileId integer, TagId integer, 
	constraint nodups unique (FileId, TagId) on conflict ignore);
CREATE TABLE if not exists descr
	(Id integer primary key, FileId integer unique, Descr text);
CREATE TABLE if not exists rules
	(Id integer primary key, Rule text unique);
-- just in case one wants to check
create view if not exists _filetag as
	select tag.tag as tag, file.path as path
	from filetag
	    join tag on filetag.tagid=tag.id
	    join file on filetag.fileid=file.id;
