module DBConnectable
  require "pg"

  def initialize(logger = nil)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'keyboard_lesson_manager')
          end
    @logger =logger
  end

  def query(statement, *params)
    @logger&.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end

  def close_connection
    @db.close
  end
end
