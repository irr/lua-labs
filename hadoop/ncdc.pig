records = LOAD 'hdfs://quickstart.cloudera:8020/user/cloudera/ncdc' AS (year:chararray, temperature:int);
filtered_records = FILTER records BY temperature > 0;
grouped_records = GROUP filtered_records BY year;
max_temp = FOREACH grouped_records GENERATE group, MAX(filtered_records.temperature);
DUMP max_temp;
