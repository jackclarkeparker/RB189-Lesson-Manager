dropdb keyboard_lesson_manager --if-exists
createdb keyboard_lesson_manager
psql -d keyboard_lesson_manager < seed.sql
