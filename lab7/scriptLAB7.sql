--3
SELECT ST_Union(rast)
from rasters.uk_250k uk

SELECT ST_Union(rast)
from rasters.uk_250k uk
LIMIT 15

SELECT ST_Union(rast)
from rasters.uk_250k uk
LIMIT 5


--6
create table uk_lake_disctrict as
	select st_union(st_clip(uk.rast, n.geom, true))
	from uk_250k uk
	inner join national_parks as n on st_intersects(n.geom,uk.rast)
	where n.gid=1

--7
create table out_clip as
	select lo_from_bytea(0, ST_AsGDALRaster(ST_Union(u.rast), 'GTiff', 
	array['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])) as lo
	from uk_lake_disctrict u;
	
select lo_export(lo, 'out7.tiff')
from out_clip;

select lo_unlink(lo)
from out_clip;


--10

create table ndvi as
WITH temp AS (
    SELECT s.rid,ST_Clip(s.rast, st_transform(u.geom, 32630)) as rast
    FROM sentinel s
    INNER JOIN uk_lake_district	u ON st_intersects(st_transform(u.geom, 32630), s.rast)
    WHERE u.gid = 1
)
SELECT temp.rid,
	ST_MapAlgebra(
    temp.rast, 1,
    temp.rast, 4,
    '(([rast2.val] - [rast1.val]) / ([rast2.val])) + [rast1.val])'::float,
    '32BF'::text	
) as rast
from temp;

--11 
create table out_ndvi as
	select lo_from_bytea(0, ST_AsGDALRaster(ST_Union(n.rast), 'GTiff', 
	array['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])) as lo
	from ndvi n;
	
select lo_export(lo, 'out11.tiff')
from out_ndvi;

select lo_unlink(lo)
from out_ndvi;

