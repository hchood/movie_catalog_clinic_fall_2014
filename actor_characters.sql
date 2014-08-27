CREATE VIEW actor_characters AS
  SELECT actors.id, actors.name, movies.id AS movie_id,
    cast_members.character AS role, movies.title AS movie
    FROM actors
    JOIN cast_members ON cast_members.actor_id = actors.id
    JOIN movies ON cast_members.movie_id = movies.id;
