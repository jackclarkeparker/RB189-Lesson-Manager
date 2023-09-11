psql $DATABASE_URL -c 'DROP DATABASE IF EXISTS keyboard_lesson_manager';
psql $DATABASE_URL -c 'CREATE DATABASE keyboard_lesson_manager';
psql $DATABASE_URL -d keyboard_lesson_manager < seed.sql;
