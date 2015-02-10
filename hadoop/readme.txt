export HADOOP_USER_NAME=cloudera
export HADOOP_CONF_DIR=/home/irocha/lua/hadoop/cloudera/hadoop-conf

hdfs dfs -ls /user
hdfs dfs -ls /user/admin

hdfs dfs -rm -r -f /user/admin/gutenberg*
hdfs dfs -copyFromLocal gutenberg /user/admin
hdfs dfs -ls /user/admin/gutenberg

hadoop jar hadoop-*streaming*.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input /user/admin/gutenberg/* -output /user/admin/gutenberg-output

hdfs dfs -ls /user/admin/gutenberg-output
hdfs dfs -cat /user/admin/gutenberg-output/part-00000
hdfs dfs -rm -r -f /user/admin/gutenberg*
hdfs dfs -rm -r -f /user/admin/.Trash
hdfs dfs -ls /user/admin

hdfs dfs -rm -r -f ncdc*
hdfs dfs -mkdir -p ncdc
hdfs dfs -copyFromLocal ncdc
hdfs dfs -ls ncdc

hdfs fs -mkdir -p words
hdfs dfs -copyFromLocal words 
hdfs dfs -ls words
hdfs dfs -cat words/pocket.txt

hdfs dfs -mkdir -p catalog
hdfs dfs -copyFromLocal catalog 
hdfs dfs -ls catalog
hdfs dfs -cat catalog/words.txt

CREATE EXTERNAL TABLE catalog (word STRING)
    LOCATION '/user/admin/catalog';

SELECT * FROM catalog ORDER BY word;
