/etc/hosts
127.0.0.1       localhost.localdomain localhost irrlab quickstart.cloudera

cd ~/remote/hadoop
scp -P 52222 -r cloudera@localhost:/etc/hadoop/conf .

sudo yum install hadoop-client

export HADOOP_USER_NAME=cloudera

hdfs --config ~/remote/hadoop/conf dfs -rm -r -f user/irr/gutenberg*
hdfs --config ~/remote/hadoop/conf dfs -mkdir -p user/irr
hdfs --config ~/remote/hadoop/conf dfs -copyFromLocal gutenberg user/irr
hdfs --config ~/remote/hadoop/conf dfs -ls user/irr/gutenberg
hadoop --config ~/remote/hadoop/conf jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input user/irr/gutenberg/* -output user/irr/gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -ls user/irr/gutenberg-output
hdfs --config ~/remote/hadoop/conf dfs -cat user/irr/gutenberg-output/part-00000
hdfs --config ~/remote/hadoop/conf dfs -rm -r -f user/irr/gutenberg*
