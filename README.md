# Keyboard Lesson Manager

The basic idea with this app was to build a management tool for storing information about
keyboard lessons. The app allows the user to perform CRUD operations on three entities associated with keyboard lessons:
  - The venues for teaching lessons,
  - The lessons themselves,
  - The students that attend lessons   

## How to run the application

1. To begin, install all dependencies with `$ bundle install`
2. Next, set up the database with `$ bash setup_database.sh`
3. Then run the application with `$ bundle exec ruby manager.rb`.    
   The application should now be listening for requests at `localhost:4567`
4. Issue a request to `/` or `/signin` to be directed to the signin page.   
   Here you can provide a username of `admin` and password of `password123` to get started :)

## The setup I used when testing / building the app

Ruby              | 2.7.6p219   
psql (PostgreSQL) | 14.3   
Chrome            | Version 103.0.5060.134 (Official Build) (x86_64)   

## Organization of Code

- Routes and some configuration is written in `manager.rb`
- Much of the other code is stored in files in the `/lib` subdirectory
    - `db_connectable.rb` contains a module that allows for classes to mix in a database connection.
    - `escapable.rb` contains a module that provides an `#h` method for escaping html.
    - `database.rb` contains the class that implements all of the methods that interact directly with 
      the PostgreSQL database. Any storage, retrieval, updating, or deleting of data is written here.
    - `lesson.rb`, `student.rb`, and `venue.rb` contain classes that standardize the way in 
      which the data relating to these entities is initialized, and also how they are compared for
      equality with one another.
    - `helpers.rb` contains a range of methods. This includes:
        - view helpers for simplifying view templates.
        - route helpers that smooth out the route defining of `manager.rb`. These address issues
          such as authentication, pagination, validation of user input, and the parsing of params into objects.

## Routes

GET  /signin                                           View signin portal   
POST /signin                                           Sign In   
POST /signout                                          Sign Out   

GET  /venues                                           View venue list   
GET  /venues/new                                       Page for adding venue   
POST /venues                                           Create venue   
GET  /venues/:venue_id/edit                            Page for editing venue details   
POST /venues/:venue_id/edit                            Update venue details   
GET  /venues/:venue_id/destroy                         Page for removing venue   
POST /venues/:venue_id/destroy                         Remove venue   

GET  /lessons                                          View lesson list   
GET  /lessons/new                                      Page for adding lesson   
POST /lessons                                          Create lesson   
GET  /lessons/:lesson_id/edit                          Page for editing lesson details   
POST /lessons/:lesson_id/edit                          Update lesson details   
GET  /lessons/:lesson_id/destroy                       Page for removing lesson   
POST /lessons/:lesson_id/destroy                       Remove lesson   

GET  /lessons/:lesson_id/students                      View student roster for lesson   
GET  /lessons/:lesson_id/students/new                  Page for adding student   
POST /lessons/:lesson_id/students                      Create student   
GET  /lessons/:lesson_id/students/:student_id/edit     Page for editing student details   
POST /lessons/:lesson_id/students/:student_id/edit     Update student details   
GET  /lessons/:lesson_id/students/:student_id/destroy  Page for removing student   
POST /lessons/:lesson_id/students/:student_id/destroy  Remove student   
