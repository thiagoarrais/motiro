drop table if exists headlines;
create table headlines (
	id int not null auto_increment,
	author varchar(40) not null,
	title varchar(100) not null,
	happened_at timestamp not null,
	reported_by varchar(40) not null,
    -- An id that identifies the revision to the reporter
	rid varchar(40) not null,
	primary key (id)
);
drop table if exists articles;
create table articles (
	id int not null auto_increment,
	headline_id int not null,
	description text,
	constraint fk_article_headline foreign key (headline_id) references headlines(id),
	primary key (id)
);
drop table if exists changes;
create table changes (
	id int not null auto_increment,
	article_id int not null,
	summary text,
	constraint fk_change_article foreign key (article_id) references articles(id),
	primary key (id)
);