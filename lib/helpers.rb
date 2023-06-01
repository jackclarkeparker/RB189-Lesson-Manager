### View Helpers
FLASH_CATEGORIES = [:success, :error, :neutral]

def signed_in?
  !!session[:username]
end

def list_page?
  paths = [/\A\/venues\z/, /\A\/lessons\z/, /\A\/lessons\/\d+\/students\z/]
  paths.any? { |path| path.match? request.path_info }
end

def current_page
  page = params[:page]
  if page
    numeric_string?(page) ? page.to_i : 0
  else
    1
  end
end

def numeric_string?(str)
  /\A\d+\z/.match? str
end

def current_path
  request.path_info
end

def no_venues?
  @database.venue_count.zero?
end

def no_lessons?
  @database.lesson_count.zero?
end

def results_per_page(path)
  case path
  when /\A\/lessons\/\d+\/students/ then Student::PAGINATION_SIZE
  when /\A\/lessons/                then Lesson::PAGINATION_SIZE
  when /\A\/venues/                 then Venue::PAGINATION_SIZE  
  end
end

def item_count(path)
  case path
  when /\A\/lessons\/\d+\/students/
    lesson_id = path.slice(/(?<=lessons\/)\d+/)
    lesson = @database.find_lesson(lesson_id)
    lesson.capacity
  when /\A\/lessons/
    @database.lesson_count
  when /\A\/venues/
    @database.venue_count
  end
end

def occupancy(lesson)
  @database.student_count_in(lesson)
end

def selected_venue_check(venue, updated_v_id, original = nil)
  if (try_to_i(updated_v_id) || original.venue.id) == venue.id
    "selected"
  else
    ""
  end
end

def selected_day_idx_check(index, updated_d_idx, original = nil)
  if (try_to_i(updated_d_idx) || original.day_idx) == index
    "selected"
  else
    ""
  end
end

def try_to_i(num_str)
  num_str.to_i if num_str
end

def try_to_24h(str)
  Time.parse(str).strftime("%H:%M") if str
end

def displayed_lesson_slot_count
  if @lesson.capacity >= (Student::PAGINATION_SIZE * current_page)
    Student::PAGINATION_SIZE
  else
    @lesson.capacity % Student::PAGINATION_SIZE
  end
end

### Route Helpers
def signed_in_check
  unless signed_in? || ["/", "/signin"].include?(request.path_info)
    set_return_path
    session[:error] = "Signin required."
    redirect "/signin"
  end
end

def set_return_path
  path = request.path_info
  path += "?page=#{request["page"]}" if request["page"]
  session[:return_path] = path
end

def redirect_to_return_path
  redirect session[:return_path]
end

def set_student_roster_return_path
  path = request.path_info
  path += "?page=#{request["page"]}" if request["page"]
  session[:student_roster_return_path] = path
end

def redirect_to_student_roster
  redirect session[:student_roster_return_path]
end

### Credential Validation
require "bcrypt"

def valid_credentials?(username, password)
  stored_password = @database.fetch_password_for(username)
  BCrypt::Password.new(stored_password) == password if stored_password
end

### Page Validation
def invalid_page_check
  if invalid_page_number?(current_page, request.path_info)
    session[:error] = "Specified page not found."
    params[:page] = '1'
  end
end

def invalid_page_number?(page, path)
  return false if page == 1

  page < 1 || page_number_too_high?(page, path)
end

def page_number_too_high?(page, path)
  (page - 1) * results_per_page(path) >= item_count(path)
end

# Adjusts the page param of the return_path where necessary after deleting an item
def return_path_page_check
  path = session[:return_path]
  page = page_param_from_path(path)
  
  if page && invalid_page_number?(page, path)
    page -= 1
    updated_path = path.sub(/(?<=page=)\d+/, page.to_s) 
    session[:return_path] = updated_path
  end
end

def page_param_from_path(path)
  query_string = path.split('?')[1]
  return nil if query_string.nil?

  params = query_string.split("&").map do |pair|
    pair.split('=')
  end.to_h

  try_to_i(params["page"])
end

### Venue Details - Parsing and Validation
def venue_from_params
  Venue.new(@original&.id, params[:name], params[:address])
end

def load_venue
  if numeric_string?(params[:venue_id])
    id = params[:venue_id].to_i
    venue = @database.find_venue(id)
    return venue if venue
  end

  status 422
  session[:error] = "Venue not found."
  redirect "/venues"
end

def venue_details_error(original_venue: nil)
  name = params[:name]
  address = params[:address]

  case
  when only_whitespace?(name)
    "Venue name must contain non-whitespace characters."
  when !(1..100).cover?(name.strip.length)
    "Venue name must be between 1 and 100 characters in length."
  when venue_name_already_in_use?(name.strip, original_venue)
    "Venue name already in use."
  when only_whitespace?(address)
    "Venue address must contain non-whitespace characters."
  when !(1..200).cover?(address.strip.length)
    "Venue address must be between 1 and 200 characters in length."
  end
end

def only_whitespace?(string)
  !!(string =~ /\A {1,}\z/)
end

def venue_name_already_in_use?(name, original_venue)
  venues_to_check = @database.all_venues
  
  if original_venue
    venues_to_check.reject! { |v| v.id == original_venue.id }
  end

  venues_to_check.any? { |v| v.name == name }
end

# Lesson Details - Parsing and Validation
def lesson_from_params
  Lesson.new(
    @original&.id,
    load_venue,
    params[:day_idx].to_i,
    params[:start_time],
    params[:duration].to_i, 
    params[:capacity].to_i
  )
end

def load_lesson
  if numeric_string?(params[:lesson_id])
    id = params[:lesson_id].to_i
    lesson = @database.find_lesson(id)
    return lesson if lesson
  end

  status 422
  session[:error] = "Lesson not found."
  redirect "/lessons"
end

def lesson_details_error(lesson)
  case
  when lesson_overlap?(lesson)
    "<b>#{lesson.venue}</b> in use at that time."
  when lesson.day_idx < 0 || lesson.day_idx > 6
    "Day input not understood."
  when lesson.duration < 15 || lesson.duration > 60
    "Lesson duration must be between 15 and 60 minutes."
  when lesson.capacity < 1 || lesson.capacity > 12
    "Lesson capacity cannot be less than one or greater than twelve."
  when (lesson.capacity < occupancy(@original) if @original)
    "Capacity cannot be reduced below existing student occupancy."
  end
end

def lesson_overlap?(new_lesson)
  lessons_to_check = @database.lessons_at_venue_on_day(
    new_lesson.venue, new_lesson.day_idx
  )

  if @original
    lessons_to_check.reject! { |l| l.id == @original.id }
  end

  lessons_to_check.any? do |existing|
    (existing.start_time...existing.end_time).cover?(new_lesson.start_time) ||
    ((existing.start_time + 1)..existing.end_time).cover?(new_lesson.end_time)
  end
end

# Student Details - Parsing and Validation

def student_from_params
  Student.new(@original&.id, params[:lesson_id], params[:name], params[:age])
end

def load_student
  if numeric_string?(params[:student_id])
    id = params[:student_id].to_i
    student = @database.find_student(id)
    return student if student
  end

  status 422
  session[:error] = "Student not found."
  redirect_to_student_roster
end

def student_details_error
  name = params[:name]
  age = params[:age].to_i

  case
  when only_whitespace?(name)
    "Student name must contain non-whitespace characters."
  when !(1..100).cover?(name.strip.length)
    "Student name must be between 1 and 100 characters in length."
  when age < 4 || age > 99
    "Students must be aged between 4 and 99 years."
  end
end
