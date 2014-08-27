require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# USER VIEWS A LIST OF ACTORS:
# Visiting /actors will show a list of actors, sorted alphabetically by name.
# Each actor name is a link to the details page for that actor.

#####################################
              # METHODS
#####################################

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)
  ensure
    connection.close
  end
end

def get_all_actors
  query = %Q{
    SELECT * FROM actors
    ORDER BY name;
  }

  results = db_connection do |conn|
    conn.exec(query)
  end

  results.to_a
end

#####################################
              # ROUTES
#####################################

get '/actors' do
  @actors = get_all_actors

  erb :'actors/index'
end
