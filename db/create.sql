drop table if exists headlines;
create table headlines (
	id int not null auto_increment,
	author varchar(40) not null,
	title varchar(100) not null,
	happened_at timestamp not null,
	description text,
	primary key (id)
);
create table articles (
	id int not null auto_increment,
	headline_id int not null,
	description text,
	constraint fk_article_headline foreign key (headline_id) references headlines(id),
	primary key (id)
);