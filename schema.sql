CREATE TABLE venues(
    id serial PRIMARY KEY,
    entry_creation_timestamp timestamp NOT NULL DEFAULT NOW(),
    name text NOT NULL UNIQUE,
    address text NOT NULL
);

CREATE TABLE lessons(
    id serial PRIMARY KEY,
    venue_id int NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_idx int NOT NULL CHECK(day_idx BETWEEN 0 AND 6),
    start_time time NOT NULL,
    duration int NOT NULL,
    capacity int NOT NULL    
);

CREATE TABLE students(
    id serial PRIMARY KEY,
    lesson_id int NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    name text NOT NULL,
    age int NOT NULL
);

CREATE TABLE user_credentials(
    id serial PRIMARY KEY,
    username text UNIQUE NOT NULL,
    password text NOT NULL
);
