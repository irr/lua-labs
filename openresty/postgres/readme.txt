psql -h localhost -U postgres
create database postgis;

psql -h localhost -U postgres postgis
create extension postgis;

CREATE TABLE locations(loc_id integer primary key, loc_name varchar(70), geog geography(POINT));
INSERT INTO locations(loc_id, loc_name, geog) VALUES
    (0, 'Sao Paulo, SP', ST_GeogFromText('POINT(-23.6824124 -46.5952992)'));
INSERT INTO locations(loc_id, loc_name, geog) VALUES 
    (1, 'Waltham, MA', ST_GeogFromText('POINT(42.40047 -71.2577)')),
    (2, 'Manchester, NH', ST_GeogFromText('POINT(42.99019 -71.46259)')),
    (3, 'TI Blvd, TX', ST_GeogFromText('POINT(-96.75724 32.90977)'));

