CREATE VIEW movie_cast_members AS
  SELECT movies.title, movies.year, movies.id, movies.rating, genres.name AS genre, studios.name AS studio,
  actors.id AS actor_id, actors.name AS actor, cast_members.character AS role
  FROM movies
  JOIN genres ON genres.id = movies.genre_id
  JOIN studios ON studios.id = movies.studio_id
  JOIN cast_members ON cast_members.movie_id = movies.id
  JOIN actors ON actors.id = cast_members.actor_id;
