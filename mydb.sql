CREATE TABLE if not exists file 
	(Id integer primary key, path text unique on conflict ignore);
CREATE TABLE if not exists tag 
	(Id integer primary key, tag text unique on conflict ignore);
CREATE TABLE if not exists filetag 
	(Id integer primary key, FileId integer, TagId integer, 
	constraint nodups unique (FileId, TagId) on conflict ignore);
create view _filetag as
	select tag.tag as tag, file.path as path
	from filetag
	    join tag on filetag.tagid=tag.id
	    join file on filetag.fileid=file.id;
