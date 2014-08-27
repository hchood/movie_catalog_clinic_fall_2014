require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# USER VIEWS A LIST OF ACTORS:
# Visiting /actors will show a list of actors, sorted alphabetically by name.
# Each actor name is a link to the details page for that actor.

# USER VIEWS AN ACTOR'S PAGE:
# Visiting /actors/:id will show the details for a given actor.
# This page should contain a list of movies that the actor has starred in
# and what their role was.
# Each movie should link to the details page for that movie.

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

def get_actor_info(actor_id)
  query = %Q{
    SELECT actors.id, actors.name, movies.id AS movie_id,
    cast_members.character, movies.title AS movie
    FROM actors
    JOIN cast_members ON cast_members.actor_id = actors.id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE actors.id = $1;
  }

  results = db_connection do |conn|
    conn.exec_params(query, [actor_id])
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

get '/actors/:id' do
  @characters = get_actor_info(params[:id])
  @actor = {
    name: @characters[0]['name'],
    id: @characters[0]['id']
  }

  erb :'actors/show'
end









