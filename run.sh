#/bin/bash
# ref : http://stackoverflow.com/questions/794728/variables-as-commands-in-bash-scripts
set -e
db_user=beanj
db_password=
db_host=localhost
db_name=testing
data_dir=/Users/beanj/dev/git/quick_n_dirty_etl


#Create temp storage
export PGPASSWORD="$db_password" && \
export PGOPTIONS='--client-min-messages=warning' && \
'/Applications/Postgres.app/Contents/Versions/9.4/bin'/psql -p5432 -U "$db_user" \
-h "$db_host" \
-d "$db_name" \
-v ON_ERROR_STOP=1 \
-a -f 1_create_temp_storage.sql

#Import Raw Data
export PGPASSWORD="$db_password" && \
export PGOPTIONS='--client-min-messages=warning' && \
'/Applications/Postgres.app/Contents/Versions/9.4/bin'/psql -p5432 -U "$db_user" \
-h "$db_host" \
-d "$db_name" \
-v ON_ERROR_STOP=1 \
-c "COPY tmp_fruit FROM STDIN with CSV HEADER ;" < "$data_dir/fruit.csv"

#Process Raw Data .. do something to it and integrate results in database
export PGPASSWORD="$db_password" && \
export PGOPTIONS='--client-min-messages=notice' && \
'/Applications/Postgres.app/Contents/Versions/9.4/bin'/psql -p5432 -U "$db_user" \
-h "$db_host" \
-d "$db_name" \
-v ON_ERROR_STOP=1 \
-a -f 2_process_raw_data.sql

export PGPASSWORD="$db_password" && \
export PGOPTIONS='--client-min-messages=warning' && \
'/Applications/Postgres.app/Contents/Versions/9.4/bin'/psql -U "$db_user" \
-h "$db_host" \
-d "$db_name" \
-v ON_ERROR_STOP=1 \
-c "COPY (select * from tmp_processed) TO STDOUT WITH CSV HEADER; " > processed_fruit.csv

export PGPASSWORD="$db_password" && \
export PGOPTIONS='--client-min-messages=notice' && \
'/Applications/Postgres.app/Contents/Versions/9.4/bin'/psql -p5432 -U "$db_user" \
-h "$db_host" \
-d "$db_name" \
-v ON_ERROR_STOP=1 \
-a -f 3_drop_temp_items.sql