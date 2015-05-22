CENTOS 6.6
sudo yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
sudo vi /etc/yum.repos.d/remi.repo
> exclude=memcached
sudo yum remove libevent-last
sudo service postgresql-9.4 initdb
sudo service postgresql-9.4 start
sudo chkconfig postgresql-9.4 on

CENTOS 6.6/7
sudo yum install postgis2_94 postgis2_94-docs postgresql94-devel postgresql94-server postgresql94-docs pgadmin3_94-docs pgadmin3_94 postgresql94-contrib

CENTOS 7
sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
sudo systemctl restart postgresql-9.4
sudo systemctl enable postgresql-9.4

firewall-cmd --permanent --add-port=5432/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
setsebool -P httpd_can_network_connect_db 1

su -
su - postgres
psql
\password postgres
\q

sudo vi /var/lib/pgsql/9.4/data/pg_hba.conf
# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5

Ubuntu 15.04
sudo apt-get install postgresql-9.4-postgis-2.1 postgis-doc postgresql-doc pgadmin3

Ubuntu 14.04
sudo apt-get install postgresql-9.3-postgis-2.1 postgis-doc postgresql-doc pgadmin3

...
Setting up postgresql-9.3 (9.3.6-0ubuntu0.14.04) ...
Creating new cluster 9.3/main ...
  config /etc/postgresql/9.3/main
  data   /var/lib/postgresql/9.3/main
  locale en_US.UTF-8
  port   5432
...

sudo -u postgres psql postgres
\password postgres
\q

psql -h localhost -U postgres
create extension adminpack;
create database postgis;

psql -h localhost -U postgres postgis
create extension postgis;
create extension postgis_topology;

CREATE TABLE locations(loc_id integer primary key, loc_name varchar(70), geog geography(POINT));
CREATE INDEX locations_gix ON locations USING GIST(geog);

INSERT INTO locations(loc_id, loc_name, geog) VALUES
  (0, 'Vila do Rossio, Sao Paulo, SP', ST_GeogFromText('POINT(-46.759648 -23.643439)')),
  (1, 'UOL, Sao Paulo, SP', ST_GeogFromText('POINT(-46.691784 -23.569582)')),
  (2, 'Ladrillo, Sao Paulo, SP', ST_GeogFromText('POINT(-46.671072 -23.604196)')),
  (3, 'Shopping Jardim Sul, Sao Paulo, SP', ST_GeogFromText('POINT(-46.735837 -23.630906)'));

COMMIT;

SELECT loc_id, loc_name, ST_AsGeoJSON(geog)::json as loc_json FROM locations;

SELECT * FROM locations WHERE ST_DWithin(geog, ST_GeogFromText('SRID=4326;POINT(-46.759648 -23.643439)'), 5000);

