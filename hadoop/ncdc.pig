records = LOAD 'ncdc'
  AS (year:chararray, temperature:int);
filtered_records = FILTER records BY temperature != 9999;
grouped_records = GROUP filtered_records BY year;
max_temp = FOREACH grouped_records GENERATE group,
  MAX(filtered_records.temperature);
DUMP max_temp;
