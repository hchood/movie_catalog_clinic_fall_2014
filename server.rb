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

# USER VIEWS A LIST OF MOVIES:
# Visiting /movies will show a table of movies, sorted alphabetically by title.
# The table includes the movie title, the year it was released, the rating, the genre,
# and the studio that produced it. Each movie title is a link to the details page
# for that movie.

# USER VIEWS A MOVIE'S PAGE:
# Visiting /movies/:id will show the details for the movie.
# This page should contain information about the movie (including genre and studio)
# as well as a list of all of the actors and their roles.
# Each actor name is a link to the details page for that actor.

# USER SORTS MOVIES:
# Allow different orderings for the /movies page.
# The user should be able to sort by year released or rating
# by visiting /movies?order=year or /movies?order=rating

# MOVIES AND ACTORS ARE PAGINATED:
# Paginate the /movies and /actors page using the LIMIT and OFFSET clauses in PostgreSQL.
# Each page should show up to 20 entries at a time. Visiting /movies?page=2 should show
# the next 20 movies.

# USER SEARCHES MOVIES:
# Add a search feature for /movies.
# Visiting /movies?query=troll+2 will only show movies
# that have the phrase troll 2 in the title or synopsis.
# This can be accomplished using the LIKE and ILIKE operators in PostgreSQL.

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
    SELECT * FROM actor_characters
    WHERE actors.id = $1;
  }

  results = db_connection do |conn|
    conn.exec_params(query, [actor_id])
  end

  results.to_a
end

def get_all_movies(order_param, offset, search_term)
  query = %Q{
    SELECT * FROM movie_information
    WHERE title ILIKE $1 or synopsis ILIKE $1
    ORDER BY #{order_param}
    LIMIT 20 OFFSET #{offset};
  }

  results = db_connection do |conn|
    conn.exec_params(query, ["%#{search_term}%"])
  end

  results.to_a
end

def get_movie_info(movie_id)
  query = %Q{
    SELECT * FROM movie_cast_members
    WHERE id = $1;
  }

  results = db_connection do |conn|
    conn.exec_params(query, [movie_id])
  end

  results.to_a
end

def count_movies
  query = "SELECT COUNT(*) FROM movies;"

  count = db_connection do |conn|
    conn.exec(query)
  end

  count.to_a.first["count"].to_i
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

get '/movies' do
  movie_count = count_movies

  if movie_count % 20 == 0
    @last_page = movie_count / 20
  else
    @last_page = movie_count / 20 + 1
  end

  @page_no = (params[:page] || 1).to_i
  offset = (@page_no - 1) * 20
  @order_param = params[:order] || 'title'
  @movies = get_all_movies(@order_param, offset, params[:query])

  erb :'movies/index'
end

get '/movies/:id' do
  @cast_members = get_movie_info(params[:id])

  @movie = {
    id: @cast_members[0]['id'],
    title: @cast_members[0]['title'],
    year: @cast_members[0]['year'],
    genre: @cast_members[0]['genre'],
    studio: @cast_members[0]['studio']
  }

  erb :'movies/show'
end








