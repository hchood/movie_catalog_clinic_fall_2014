CREATE VIEW movie_information AS
  SELECT movies.title, movies.year, movies.id, movies.rating, genres.name AS genre, studios.name AS studio
  FROM movies
  JOIN genres ON genres.id = movies.genre_id
  JOIN studios ON studios.id = movies.studio_id;
