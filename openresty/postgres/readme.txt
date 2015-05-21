CENTOS 6.6
sudo yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
sudo vi /etc/yum.repos.d/remi.repo
> exclude=memcached
sudo yum remove libevent-last
sudo yum install postgis2_94 postgis2_94-docs postgresql94-devel postgresql94-server postgresql94-docs pgadmin3_94-docs pgadmin3_94

sudo service postgresql-9.4 initdb
sudo service postgresql-9.4 start
sudo chkconfig postgresql-9.4 on

Ubuntu 15.04
sudo apt-get install postgresql-9.4-postgis-2.1 postgis-doc postgresql-doc pgadmin3

Ubuntu 14.04
sudo apt-get install postgresql-9.3-postgis-2.1 postgis-doc postgresql-doc pgadmin3

sudo -u postgres psql postgres
\password postgres

sudo vi /var/lib/pgsql/9.4/data/pg_hba.conf
local   all all md5
host    all 127.0.0.1/32    md5

psql -h localhost -U postgres
create database postgis;

psql -h localhost -U postgres postgis
create extension postgis;
create extension postgis_topology;

CREATE TABLE locations(loc_id integer primary key, loc_name varchar(70), geog geography(POINT));
CREATE INDEX locations_gix ON locations USING GIST(geog);

INSERT INTO locations(loc_id, loc_name, geog) VALUES
  (0, 'Vila do Rossio, Sao Paulo, SP', ST_GeogFromText('POINT(-23.643439 -46.759648)')),
  (1, 'UOL, Sao Paulo, SP', ST_GeogFromText('POINT(-23.569582 -46.691784)')),
  (2, 'Ladrillo, Sao Paulo, SP', ST_GeogFromText('POINT(-23.604196 -46.671072)')),
  (3, 'Shopping Jardim Sul, Sao Paulo, SP', ST_GeogFromText('POINT(-23.630906 -46.735837)'));

COMMIT;

SELECT loc_id, loc_name, ST_AsGeoJSON(geog)::json as loc_json FROM locations;

SELECT * FROM locations WHERE ST_DWithin(geog, ST_GeogFromText('POINT(-23.643439 -46.759648)'), 3000);
SELECT * FROM locations WHERE ST_DWithin(geog, ST_GeogFromText('SRID=4326;POINT(-23.643439 -46.759648)'), 5000);

