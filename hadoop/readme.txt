export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386

export HADOOP_INSTALL=/opt/java/hadoop
export HADOOP_CLASSPATH=$JAVA_HOME/lib/tools.jar
export PATH=$HADOOP_INSTALL/bin:$HADOOP_INSTALL/sbin:$PATH

hadoop namenode -format
hdfs dfs -rm -r -f user/irr/gutenberg*
hdfs dfs -mkdir -p user/irr
hdfs dfs -copyFromLocal gutenberg user/irr
hdfs dfs -ls user/irr/gutenberg
hadoop jar hadoop-*streaming*.jar \
    -file mapper.lua -mapper mapper.lua \
    -file reducer.lua -reducer reducer.lua \
    -input user/irr/gutenberg/* -output user/irr/gutenberg-output
hdfs dfs -ls user/irr/gutenberg-output
hdfs dfs -cat user/irr/gutenberg-output/part-00000
hdfs dfs -rm -r -f user/irr/gutenberg*
