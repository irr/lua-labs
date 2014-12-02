records = LOAD 'hdfs://quickstart.cloudera:8020/user/cloudera/ncdc' AS (year:chararray, temperature:int);
filtered_records = FILTER records BY temperature > 0;
grouped_records = GROUP filtered_records BY year;
max_temp = FOREACH grouped_records GENERATE group, MAX(filtered_records.temperature);
DUMP max_temp;
STORE max_temp INTO 'ncdc/max_temp';
/*
export HADOOP_USER_NAME=cloudera
export HADOOP_CONF_DIR=~/remote/hadoop/conf

hdfs --config ~/remote/hadoop/conf dfs -rm -r -f ncdc*
hdfs --config ~/remote/hadoop/conf dfs -mkdir -p ncdc
hdfs --config ~/remote/hadoop/conf dfs -copyFromLocal ncdc

hdfs --config ~/remote/hadoop/conf dfs -ls ncdc
hdfs --config ~/remote/hadoop/conf dfs -ls ncdc/max_temp
hdfs --config ~/remote/hadoop/conf dfs -cat ncdc/max_temp/part-r-00000
hdfs --config ~/remote/hadoop/conf dfs -rm -r -f ncdc/max_temp
*/

pig -useHCatalog

hive --config ~/remote/hadoop/conf 
CREATE EXTERNAL TABLE ncdc (year STRING, temperature INT)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    LOCATION '/user/cloudera/ncdc';


records = LOAD 'ncdc' USING org.apache.hcatalog.pig.HCatLoader();
...
DUMP...
STORE...


