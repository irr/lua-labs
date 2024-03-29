records = LOAD 'hdfs://cdh:8020/user/admin/ncdc' AS (year:chararray, temperature:int);
filtered_records = FILTER records BY temperature > 0;
grouped_records = GROUP filtered_records BY year;
max_temp = FOREACH grouped_records GENERATE group, MAX(filtered_records.temperature);
DUMP max_temp;
STORE max_temp INTO 'ncdc/max_temp';

/*
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -rm -r -f ncdc*
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -mkdir -p ncdc
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -copyFromLocal ncdc

hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -ls ncdc
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -ls ncdc/max_temp
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -cat ncdc/max_temp/part-r-00000
hdfs --config /home/irocha/lua/hadoop/cloudera/hadoop-conf dfs -rm -r -f ncdc/max_temp
*/

pig -useHCatalog

hive --config /home/irocha/lua/hadoop/cloudera/hadoop-conf
CREATE EXTERNAL TABLE ncdc (year STRING, temperature INT)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    LOCATION '/user/admin/ncdc';


records = LOAD 'ncdc' USING org.apache.hcatalog.pig.HCatLoader();
...
DUMP...
STORE...

pig -x local 
records = LOAD 'ncdc' AS (year:chararray, temperature:int);
years = STREAM records THROUGH `cut -f 1`;
DUMP years;

DEFINE transform `transform.lua` SHIP ('transform.lua');

years = STREAM records THROUGH transform;
DUMP years;

hive:
list FILES;
ADD FILE transform.lua;
FROM ncdc SELECT TRANSFORM(year, temperature) USING 'transform.lua' AS year, temperature;
