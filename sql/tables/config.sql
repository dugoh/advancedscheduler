create table config
(
	module	varchar(100) not null,
	name	varchar(100) not null,
	value	varchar(4000) null,

	constraint ConfigPK primary key (module, name)
);

insert into config ( module, name, value )
values
( 'ads', 'autocreate_boxes', 'y');