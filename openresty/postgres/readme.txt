sudo yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
sudo vi /etc/yum.repos.d/remi.repo
> exclude=memcached
sudo yum remove libevent-last

sudo yum install postgis2_94 postgis2_94-docs postgresql94-devel postgresql94-server postgresql94-docs

sudo service postgresql-9.4 initdb
sudo service postgresql-9.4 start
sudo chkconfig postgresql-9.4 on

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
INSERT INTO locations(loc_id, loc_name, geog) VALUES
    (0, 'Sao Paulo, SP', ST_GeogFromText('POINT(-23.6824124 -46.5952992)'));
INSERT INTO locations(loc_id, loc_name, geog) VALUES 
    (1, 'Waltham, MA', ST_GeogFromText('POINT(42.40047 -71.2577)')),
    (2, 'Manchester, NH', ST_GeogFromText('POINT(42.99019 -71.46259)')),
    (3, 'TI Blvd, TX', ST_GeogFromText('POINT(-96.75724 32.90977)'));

