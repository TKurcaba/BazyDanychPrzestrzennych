create database lab2;

drop table if exists buildings;
drop table if exists roads;
drop table if exists poi;

CREATE TABLE buildings (id int, geom geometry, name varchar);
CREATE TABLE roads (id int, geom geometry, name varchar);
CREATE TABLE poi (id int, geom geometry, name varchar);


INSERT INTO buildings VALUES
  (1, 'POLYGON((8 4, 10.5 4, 10.5 1.5 ,8 1.5, 8 4))', 'BuildingA'),
  (2, 'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 'BuildingB'),
  (3, 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
  (4, 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 'BuildingD'),
  (5, 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingE');
 
 INSERT INTO roads VALUES
  (1, 'LINESTRING(7.5 10.5, 7.5 0)', 'RoadY'),
  (2, 'LINESTRING(0 4.5, 12 4.5)', 'RoadX');
 
 
 INSERT INTO poi VALUES
  (1, 'POINT(1 3.5)', 'G'),
  (2, 'POINT(5.5 1.5)', 'H'),
  (3, 'POINT(9.5 6)', 'I'),
  (4, 'POINT(6.5 6)', 'J'),
  (5, 'POINT(6 9.5)', 'K');
  
-- 6 
 
-- a
SELECT sum(ST_Length(geom)) as długość_dróg from roads r;

--b
select ST_AsText(geom) as geometria, ST_Area(geom) as pole, ST_Perimeter(geom) as obwód 
from buildings b where name='BuildingA';

--c 
select name as nazwa, ST_Area(geom) 
from buildings b 
order by name;
  
--d
with t as (select name, ST_Perimeter(geom) as odwód, ST_Area(geom) as pole from buildings b)

select name as nazwa, odwód from t 
order by pole desc 
limit 2;
  
--e
with buildingC as (select geom from buildings where name = 'BuildingC'),
 	pointK as ( select geom from poi where name = 'K')

select ST_Distance(buildingC.geom, pointK.geom) from buildingC, pointK;

--f
with C as (select geom from buildings where name = 'BuildingC'),
	B as ( select geom from buildings where name = 'BuildingB')
	
select ST_Area (ST_Difference(c.geom, ST_Buffer(B.geom, 0.5)) ) from C,B;
  
--g 
with X as (select ST_Y(ST_Centroid(geom)) as road_y from roads where name = 'RoadX')
select name from buildings, X where ST_Y(ST_Centroid(geom)) > road_y;

--h
select ST_Area(ST_SymDifference(geom,  ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) from buildings
where name = 'BuildingC';