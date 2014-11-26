/etc/hosts
127.0.0.1       localhost.localdomain localhost irrlab quickstart.cloudera

cd ~/remote/hadoop
scp -P 52222 -r cloudera@localhost:/etc/hadoop/conf .

sudo yum install hadoop-client

export HADOOP_USER_NAME=cloudera

hdfs --config ~/remote/hadoop/conf dfs -rm -r -f user/irocha/gutenberg*
hdfs --config ~/remote/hadoop/conf dfs -mkdir -p user/irocha
hdfs --config ~/remote/hadoop/conf dfs -copyFromLocal gutenberg user/irocha
hdfs --config ~/remote/hadoop/conf dfs -ls user/irocha/gutenberg
hadoop --config ~/remote/hadoop/conf jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input user/irr/gutenberg/* -output user/irocha/gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -ls user/irocha/gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -cat user/irocha/gutenberg-output/part-00000
hdfs --config ~/remote/hadoop/conf dfs -rm -r -f user/irocha
