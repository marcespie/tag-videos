CREATE TABLE file (Id integer primary key, path text unique on conflict ignore);
CREATE TABLE tag (Id integer primary key, tag text unique on conflict ignore);
CREATE TABLE filetag (Id integer primary key, FileId integer, TagId integer, 
	constraint nodups unique (FileId, TagId) on conflict ignore);
