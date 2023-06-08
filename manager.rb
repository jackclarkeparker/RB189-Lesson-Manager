require "sinatra"
require "sinatra/reloader"
require "time"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, :escape_html => true
end

root = File.expand_path("..", __FILE__)
libraries = Dir.glob(File.join(root, "/lib/*"))
libraries.each { |file| require file }

configure(:development) do
  require "sinatra/reloader"
  libraries.each { |file| also_reload file }
  also_reload "/stylesheets/main.css"
end

before do
  @database = Database.new(logger)
  signed_in_check
end

after do
  @database.close_connection
end

not_found do
  redirect "/lessons"
end

### SIGN IN ROUTES

# View sign in portal
get "/signin" do
  @title = "Sign In"
  erb :signin
end

# Sign In
post "/signin" do
  username = params[:username]
  password = params[:password]

  if valid_credentials?(username, password)
    session[:username] = username
    session[:success] = "Welcome to Keyboard Lesson Manager"
    
    if !session[:return_path]
      session[:return_path] = "/venues"
    end
    redirect_to_return_path
  else
    status 422
    session[:error] = "The username or password was incorrect."
    erb :signin
  end
end

# Sign Out
post "/signout" do
  session.delete(:username)
  session[:success] = "You have been signed out."
  redirect "/signin"
end

# Index redirect
get "/" do
  redirect "/signin"
end

### VENUE ROUTES

# View venue list
get "/venues" do
  invalid_page_check
  set_return_path
  @venues = @database.venue_selection(current_page)
  @title = "All Venues"
  erb :venues
end

# Page for adding venue
get "/venues/new" do
  @title = "Add Venue"
  erb :new_venue
end

# Create venue
post "/venues" do
  venue = venue_from_params
  error = venue_details_error

  if error
    status 422
    session[:error] = error
    erb :new_venue
  else
    @database.add_venue(venue)
    session[:success] = "<b>#{venue}</b> has been added to the list of venues."
    redirect_to_return_path
  end
end

# Page for editing venue details
get "/venues/:venue_id/edit" do
  @original = load_venue
  @title = "Edit Venue"
  erb :edit_venue
end

# Update venue details
post "/venues/:venue_id/edit" do
  @original = load_venue
  updated = venue_from_params

  error = venue_details_error(original_venue: @original)
  if error
    status 422
    session[:error] = error
    erb :edit_venue
  elsif updated == @original
    session[:neutral] = "No changes made to <b>#{@original}</b>."
    redirect_to_return_path
  else
    @database.update_venue(updated)
    session[:success] = "<b>#{updated}</b> has been updated."
    redirect_to_return_path
  end
end

# Page for dropping venue
get "/venues/:venue_id/destroy" do
  @venue = load_venue
  @title = "Drop Venue"
  erb :drop_venue
end

# Remove venue
post "/venues/:venue_id/destroy" do
  venue = load_venue
  @database.drop_venue(venue)
  session[:success] = "#{venue} was removed from Lesson Manager."
  return_path_page_check
  redirect_to_return_path
end

### LESSON ROUTES

# View lesson list
get "/lessons" do
  invalid_page_check
  set_return_path
  @lessons = @database.lesson_selection(current_page)
  @title = "All Lessons"
  erb :lessons
end

# Page for adding a lesson
get "/lessons/new" do
  if no_venues?
    session[:error] = "Venue must be added before lesson can be created."
    redirect "/venues"
  else
    @venues = @database.all_venues
    @title = "Add Lesson"
    erb :new_lesson
  end
end

# Create lesson
post "/lessons" do
  lesson = lesson_from_params
  error = lesson_details_error(lesson)

  if error
    status 422
    @venues = @database.all_venues
    session[:error] = error
    erb :new_lesson
  else
    @database.add_lesson(lesson)
    session[:success] = "<b>#{lesson.display_time} #{lesson.day}s</b> at "\
                        "<b>#{lesson.venue}</b> added to lesson list."
    redirect_to_return_path
  end
end

# Page for editing lesson details
get "/lessons/:lesson_id/edit" do
  @original = load_lesson
  @venues = @database.all_venues
  @title = "Edit Lesson"
  erb :edit_lesson
end

# Update lesson details
post "/lessons/:lesson_id/edit" do
  @original = load_lesson
  updated = lesson_from_params

  error = lesson_details_error(updated)
  if error
    status 422
    @venues = @database.all_venues
    session[:error] = error
    erb :edit_lesson
  elsif updated == @original
    session[:neutral] = "No changes made to lesson."
    redirect_to_return_path
  else
    @database.update_lesson(updated)
    session[:success] = "Lesson updated."
    redirect_to_return_path
  end
end

# Page for dropping lesson
get "/lessons/:lesson_id/destroy" do
  @lesson = load_lesson
  @title = "Drop Lesson"
  erb :drop_lesson
end

# Remove lesson
post "/lessons/:lesson_id/destroy" do
  lesson = load_lesson
  @database.drop_lesson(lesson)
  session[:success] = "<b>#{lesson.display_time} #{lesson.day}s</b> at "\
                      "<b>#{lesson.venue}</b> removed from Lesson Manager."
  return_path_page_check
  redirect_to_return_path
end

### STUDENT ROUTES

# View student roster for lesson
get "/lessons/:lesson_id/students" do
  invalid_page_check
  set_student_roster_return_path
  @lesson = load_lesson
  @students = @database.student_selection(@lesson, current_page)
  @title = "Student Roster"
  erb :student_roster
end

# Page for adding student
get "/lessons/:lesson_id/students/new" do
  @lesson = load_lesson
  @title = "Add Student"
  erb :new_student
end

# Create student
post "/lessons/:lesson_id/students/new" do
  @lesson = load_lesson
  student = student_from_params
  error = student_details_error

  if error
    status 422
    session[:error] = error
    erb :new_student
  else
    @database.add_student(student)
    session[:success] = "<b>#{student}</b> added to the roster."
    redirect session[:student_roster_return_path]
  end
end

# Page for editing student details
get "/lessons/:lesson_id/students/:student_id/edit" do
  @lesson = load_lesson
  @original = load_student
  @title = "Edit Student Details"
  erb :edit_student
end

# Update student details
post "/lessons/:lesson_id/students/:student_id/edit" do
  @lesson = load_lesson
  @original = load_student
  updated = student_from_params

  error = student_details_error
  if error
    status 422
    session[:error] = error
    erb :edit_student
  elsif updated == @original 
    session[:neutral] = "No changes made to #{@original}'s details."
    redirect_to_student_roster
  else
    @database.update_student(updated)
    session[:success] = "<b>#{updated}'s</b> details have been updated."
    redirect_to_student_roster
  end
end

# Page for removing student
get "/lessons/:lesson_id/students/:student_id/destroy" do
  @lesson = load_lesson
  @student = load_student
  @title = "Terminate Student"
  erb :drop_student
end

# Remove student
post "/lessons/:lesson_id/students/:student_id/destroy" do
  lesson = load_lesson
  student = load_student
  @database.drop_student(student)
  session[:success] = "<b>#{student}</b> has been terminated."
  redirect_to_student_roster
end
