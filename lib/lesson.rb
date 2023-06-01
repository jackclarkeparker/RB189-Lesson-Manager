class Lesson
  PAGINATION_SIZE = 8
  WEEK_DAYS = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  SECONDS_PER_MINUTE = 60

  attr_reader :id, :venue, :day_idx, :day, :start_time, :duration, :capacity

  def initialize(id, venue, day_idx, start_time, duration, capacity)
    @id = id.to_i
    @venue = venue
    @day_idx = day_idx.to_i
    @day = WEEK_DAYS[@day_idx]
    @start_time = Time.parse(start_time)
    @duration = duration.to_i
    @capacity = capacity.to_i
  end

  def end_time
    start_time + (SECONDS_PER_MINUTE * duration)
  end

  def display_time
    start_time.strftime("%-l:%M%P")
  end

  def ==(other_lesson)
    self.id == other_lesson.id
    self.venue == other_lesson.venue &&
    self.day_idx == other_lesson.day_idx &&
    self.start_time == other_lesson.start_time &&
    self.duration == other_lesson.duration &&
    self.capacity == other_lesson.capacity
  end
end