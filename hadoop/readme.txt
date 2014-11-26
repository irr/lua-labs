/etc/hosts
127.0.0.1       localhost.localdomain localhost irrlab quickstart.cloudera

cd ~/remote/hadoop
scp -P 52222 -r cloudera@localhost:/etc/hadoop/conf .

sudo yum install hadoop-client

export HADOOP_USER_NAME=cloudera

hdfs --config ~/remote/hadoop/conf dfs -rm -r -f gutenberg*
hdfs --config ~/remote/hadoop/conf dfs -mkdir -p gutenberg
hdfs --config ~/remote/hadoop/conf dfs -copyFromLocal gutenberg 
hdfs --config ~/remote/hadoop/conf dfs -ls gutenberg
hadoop --config ~/remote/hadoop/conf jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input gutenberg/* -output gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -ls gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -cat gutenberg-output/part-00000
