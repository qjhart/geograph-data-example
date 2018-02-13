\set us_nodes `tr -d "\n" < us_nodes.geojson`

-- Create my links to the countries

create or replace view us_link_features as
with j as (
 select jsonb_array_elements(j->'features') as f
 from (VALUES (:'us_nodes'::jsonb)) as v(j)
),
g as (
 select f->'properties' as properties,
 st_transform(st_setsrid(st_geomfromGeoJSON((f->'geometry')::text),4269),3785) as point
 from j
)
select
 jsonb_build_object(
 'type','Feature',
 'id',properties->>'name'||'->'||(properties->>'country')::text,
  'properties',properties,
  'geometry',(st_AsGeoJSON(
   st_transform(node_to_country(point,gid),4269)))::jsonb
 ) as feature
from g join countries on (properties->>'country'=code);

create view us_node_country_link_features as
with f as (
select feature from us_link_features
union
select * from
country_features(
(with a as (select feature->'properties'->>'country' as code
from us_link_features)
select array_agg(gid) from a join countries using (code)),0.5)
)
select
jsonb_build_object('type','FeatureCollection',
'features', jsonb_agg(feature)
)
FROM f;
