create database lab3;
create EXTENSION postgis;


--1
select tkb.gid,tkb.polygon_id,tkb."name",tkb."type",tkb.height, st_astext(tkb.geom) 
from t2019_kar_buildings tkb 
left join t2018_kar_buildings tkb18 on tkb.geom = tkb18.geom
where tkb18.gid is null ;


--2
with new_bui as (
	select tkb.gid,tkb.polygon_id,tkb."name",tkb."type",tkb.height,tkb.geom
	from t2019_kar_buildings tkb 
	left join t2018_kar_buildings tkb18 on tkb.geom = tkb18.geom
	where tkb18.gid is null 
),
new_poi as(
select kpt.gid,kpt.poi_id,kpt.link_id, kpt.poi_name ,kpt.st_name, kpt.lat ,kpt."type",kpt.lon, kpt.geom
	from t2019_kar_poi_table kpt
	left join t2018_kar_poi_table kpt18 on kpt.geom = kpt18.geom
	where kpt18.gid is null 
),
result as (
select poi.type
from new_poi poi
join new_bui bui on ST_Intersects(poi.geom, ST_Buffer(bui.geom,0.005))
)

select count(*),type from result group by type;

--3
select * from t2019_kar_streets tks ;
create table streets_reprojected(
gid int primary key,
link_id float8,
st_name varchar(254) null,
ref_in_id float8,
nref_in_id float8,
func_class varchar(1),
speed_cat varchar(1),
fr_speed_I float8,
to_speed_I float8,
dir_travel varchar(1),
geom geometry )

insert into streets_reprojected
select gid,link_id,st_name,ref_in_id,nref_in_id,func_class,speed_cat,fr_speed_l,to_speed_l,dir_travel,ST_Transform(ST_SetSRID(geom,4326), 3068)
from t2019_kar_streets ;

select * from streets_reprojected;

--4

create table input_points(
id int primary key,
name varchar(50),
geom geometry);

insert into input_points values
  (1, 'point1', 'POINT(8.36093 49.03174)'),
  (2, 'point2', 'POINT(8.39876 49.00644)');
  
 --
 UPDATE input_points
   SET geom = ST_Transform(ST_SetSRID(geom,4326), 3068);
   
  select * from input_points;
  
 --6
 
UPDATE t2019_kar_street_node 
SET geom = ST_Transform(ST_SetSRID(geom,4326), 3068);
 
with temp as(
	select st_makeline(geom) as l from input_points ip
)

select * from temp
cross join t2019_kar_street_node tksn 
where ST_CONTAINS(ST_BUFFER(temp.l, 0.002),tksn.geom)


--7
with parks as(
	select ST_Buffer(geom,0.003) as buf from t2019_kar_land_use_a tklua 
	where type='Park (City/County)'
)

select count(*) from parks 
cross join t2019_kar_poi_table tkpt
where tkpt."type" ='Sporting Goods Store' and 
ST_CONTAINS(parks.buf, tkpt.geom)


--8
select ST_INTERSECTION(tkwl.geom, tkr.geom)
as geom 
into T2019_KAR_BRIDGES
from t2019_kar_water_lines tkwl 
join t2019_kar_railways tkr 
on ST_Intersects(tkwl.geom, tkr.geom)