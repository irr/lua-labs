/etc/hosts
127.0.0.1       localhost.localdomain localhost irrlab quickstart.cloudera

cd ~/remote/hadoop
scp -P 52222 -r cloudera@localhost:/etc/hadoop/conf .

sudo yum install hadoop-client hive-hcatalog
sudo apt-get install hadoop-client pig hive

export HADOOP_USER_NAME=cloudera
export HADOOP_CONF_DIR=/home/irocha/lua/hadoop/quickstart/hadoop-conf

hdfs --config /home/irocha/lua/hadoop/quickstart/hadoop-conf dfs -rm -r -f gutenberg*

hdfs dfs -mkdir -p gutenberg
hdfs dfs -copyFromLocal gutenberg 
hdfs dfs -ls gutenberg
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input gutenberg/* -output gutenberg-output
hdfs dfs -ls gutenberg-output
hdfs dfs -cat gutenberg-output/part-00000

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
    LOCATION '/user/cloudera/catalog';

SELECT * FROM catalog ORDER BY word;
