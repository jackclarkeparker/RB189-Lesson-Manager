require_relative "db_connectable"

class Database
  include DBConnectable

  ### AUTHENTICATION QUERIES

  def fetch_password_for(username)
    sql = <<~SQL
      SELECT password
        FROM user_credentials
       WHERE username=$1;
    SQL
    result = query(sql, username).first
    
    result["password"] if result
  end

  ### VENUE QUERIES

  def venue_selection(page)
    limit = Venue::PAGINATION_SIZE
    offset = limit * (page - 1)
    
    sql = <<~SQL
      SELECT *
        FROM venues
       ORDER BY entry_creation_timestamp
             LIMIT $1 OFFSET $2;
    SQL
    result = query(sql, limit, offset)

    result.map do |v|
      Venue.new(v["id"], v["name"], v["address"])
    end
  end

  def venue_count
    sql = "SELECT count(id) FROM venues;"
    query(sql).first["count"].to_i
  end

  def all_venues
    sql = "SELECT * FROM venues;"
    result = query(sql)

    result.map do |v|
      Venue.new(v["id"], v["name"], v["address"])
    end
  end

  def add_venue(venue)
    sql = "INSERT INTO venues(name, address) VALUES ($1, $2);"
    query(sql, venue.name, venue.address)
  end

  def find_venue(id)
    sql = "SELECT * FROM venues WHERE id=$1;"
    data = query(sql, id).first

    Venue.new(data["id"], data["name"], data["address"]) if data
  end

  def update_venue(venue)
    sql = "UPDATE venues SET name=$1, address=$2 WHERE id=$3;"
    query(sql, venue.name, venue.address, venue.id)
  end

  def drop_venue(venue)
    sql = "DELETE FROM venues WHERE id=$1;"
    query(sql, venue.id)
  end

  ### LESSON QUERIES

  def lesson_selection(page)
    limit = Lesson::PAGINATION_SIZE
    offset = limit * (page - 1)
    
    sql = <<~SQL
      SELECT *
        FROM lessons
       ORDER BY day_idx, venue_id, start_time
             LIMIT $1 OFFSET $2;
    SQL
    result = query(sql, limit, offset)

    result.map do |data|
      create_lesson(data)
    end
  end

  def lesson_count
    sql = "SELECT count(id) FROM lessons;"
    query(sql).first["count"].to_i
  end

  def student_count_in(lesson)
    sql = <<~SQL
      SELECT count(students.id)
        FROM students
       INNER JOIN lessons
          ON students.lesson_id = lessons.id
       WHERE lessons.id = $1;
    SQL
    query(sql, lesson.id).first["count"].to_i
  end

  def lessons_at_venue_on_day(venue, day_idx)
    sql = <<~SQL
      SELECT *
        FROM lessons
       WHERE venue_id=$1
         AND day_idx=$2;
    SQL
    result = query(sql, venue.id, day_idx)

    result.map do |data|
      create_lesson(data, venue)
    end
  end

  def add_lesson(lesson)
    sql = <<~SQL
      INSERT INTO lessons(venue_id, day_idx, start_time, duration, capacity)
        VALUES ($1, $2, $3, $4, $5);
    SQL

    query(sql,
          lesson.venue.id,
          lesson.day_idx,
          lesson.start_time,
          lesson.duration,
          lesson.capacity)
  end

  def find_lesson(id)
    sql = "SELECT * FROM lessons WHERE id=$1;"
    data = query(sql, id).first

    create_lesson(data) if data
  end

  def update_lesson(lesson)
    sql = <<~SQL
      UPDATE lessons
         SET venue_id=$1,
             day_idx=$2,
             start_time=$3,
             duration=$4,
             capacity=$5
       WHERE id=$6;
    SQL

    query(sql,
          lesson.venue.id,
          lesson.day_idx,
          lesson.start_time,
          lesson.duration,
          lesson.capacity,
          lesson.id)
  end

  def drop_lesson(lesson)
    sql = "DELETE FROM lessons WHERE id=$1;"
    query(sql, lesson.id)
  end

  def create_lesson(data, venue = nil)
    venue = find_venue(data["venue_id"]) unless venue

    Lesson.new(data["id"],
               venue,
               data["day_idx"],
               data["start_time"],
               data["duration"],
               data["capacity"])
  end
  private :create_lesson

  ### STUDENT QUERIES

  def student_selection(lesson, page)
    limit = Student::PAGINATION_SIZE
    offset = limit * (page - 1)

    sql = <<~SQL
      SELECT *
        FROM students
       WHERE lesson_id = $1
       ORDER BY UPPER(name)
             LIMIT $2 OFFSET $3;
    SQL
    result = query(sql, lesson.id, limit, offset)
    
    result.map do |s|
      Student.new(s["id"], s["lesson_id"], s["name"], s["age"])
    end
  end

  def add_student(student)
    sql = "INSERT INTO students(lesson_id, name, age) VALUES ($1, $2, $3);"
    query(sql, student.lesson_id, student.name, student.age)
  end

  def find_student(id)
    sql = "SELECT * FROM students WHERE id = $1;"
    data = query(sql, id).first

    if data
      Student.new(data["id"], data["lesson_id"], data["name"], data["age"])
    end
  end

  def update_student(student)
    sql = "UPDATE students SET name=$1, age=$2 WHERE id=$3;"
    query(sql, student.name, student.age, student.id)
  end

  def drop_student(student)
    sql = "DELETE FROM students WHERE id=$1;"
    query(sql, student.id)
  end
end
