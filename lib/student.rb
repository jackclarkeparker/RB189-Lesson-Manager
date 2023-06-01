require_relative "escapable"

class Student
  include Escapable
  PAGINATION_SIZE = 4

  attr_reader :id, :lesson_id, :name, :age

  def initialize(id, lesson_id, name, age)
    @id = id.to_i
    @lesson_id = lesson_id.to_i
    @name = name.strip
    @age = age.to_i
  end

  def ==(other_student)
    self.id == other_student.id &&
    self.lesson_id == other_student.lesson_id &&
    self.name == other_student.name &&
    self.age == other_student.age
  end

  def to_s
    h self.name
  end
end
