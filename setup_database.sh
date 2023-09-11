PGPASSWORD=$DATABASE_PASSWORD psql $DATABASE_URL -c 'DROP DATABASE IF EXISTS keyboard_lesson_manager';
PGPASSWORD=$DATABASE_PASSWORD psql $DATABASE_URL -c 'CREATE DATABASE keyboard_lesson_manager';
psql "postgres://$DB_USER:$DATABASE_PASSWORD@$DB_HOST:$DB_PORT/keyboard_lesson_manager"
