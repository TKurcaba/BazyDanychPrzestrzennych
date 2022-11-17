create database lab5;


create extension postgis;
drop table if exists obiekty;
create  table obiekty (id int, geom geometry, name varchar);

insert into obiekty values
	(1,ST_Collect(ARRAY[ 
	ST_GeomFromText('LINESTRING(0 1,1 1)'),
	ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(1 1, 2 0,3 1)')),
	ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(3 1, 4 2,5 1)')),
			ST_GeomFromText('LINESTRING(5 1 ,6 1)') ] ),'obiekt1'),
	(2,ST_Collect(ST_Collect(ARRAY[ 
	ST_GeomFromText('LINESTRING(10 6,14 6)'),
	ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 6, 16 4,14 2)')),
	ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 2, 12 0,10 2)')),
			ST_GeomFromText('LINESTRING(10 2, 10 6)') ] ),
	ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2)'))),'obiekt2'),
	(3,ST_MakePolygon(ST_GeomFromText('LINESTRING(7 15, 10 17,12 13, 7 15)'))
	,'obiekt3'),
	(4,ST_LineFromMultiPoint('MULTIPOINT(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'  )
	,'obiekt4'),
	(5,ST_Collect(ST_GeomFromText('POINT(30 30 59)'),ST_GeomFromText('POINT(38 32 234)'))
	,'obiekt5'),
	(6,ST_Collect(ST_GeomFromText('POINT(4 2)'),ST_GeomFromText('LINESTRING(1 1, 3 2)'))
	,'obiekt6')


-- zad 2
with obiekt3 as (select geom from obiekty o where name = 'obiekt3'),
	obiekt4 as (select geom from obiekty o where name = 'obiekt4')


select ST_Area(ST_Buffer( ST_ShortestLine(obiekt3.geom,obiekt4.geom),5)) from obiekt3, obiekt4;
	

--zad 3

update obiekty 
set geom = ST_MakePolygon(ST_MakeLine(ST_LineMerge(geom), ST_PointN(ST_LineMerge(geom), 1)))
where name='obiekt4';

select * from obiekty o 
where name='obiekt4';


--zad 4

insert into obiekty(id,geom,name)
SELECT 7,ST_Collect(tmp.geom,tmp2.geom),'obiekt7'
FROM (SELECT geom FROM obiekty WHERE name = 'obiekt3') as tmp,	
(SELECT geom FROM obiekty WHERE name = 'obiekt4') as tmp2
	
select * from obiekty o 
where name='obiekt7';
-- zad 5

select ST_Area(ST_Buffer(geom, 5)) from obiekty o
where ST_HasArc(ST_LineToCurve(geom))=false;