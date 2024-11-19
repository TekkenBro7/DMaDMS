SELECT * FROM public.publishers;


SELECT * FROM public.anime;


SELECT * FROM public.watch_links;


SELECT * FROM public.users;


SELECT * FROM public.reviews;


SELECT * FROM public.reviews_like;


SELECT * FROM public.bookmark_statuses;


SELECT * FROM public.bookmarKS;


SELECT * FROM public.reviews_like;


 -- ALTER TABLE public.reviews
 -- ADD CONSTRAINT rating_check CHECK (rating >= 0 AND rating <= 10);


SELECT * FROM users WHERE email = 'admin@example.com';


SELECT * FROM user_actions_log WHERE user_id = 1;


SELECT * FROM user_actions_log WHERE action_time BETWEEN '2024-01-01' AND '2024-12-31';


SELECT g.title FROM genres g
JOIN anime_genres ag ON g.id = ag.genre_id;


SELECT g.title FROM genres g
JOIN anime_genres ag ON g.id = ag.genre_id
WHERE ag.anime_id = 1;


SELECT anime.title, age_limit FROM anime WHERE age_limit > 12;


SELECT * FROM anime WHERE release_date > '2010-01-01';


UPDATE anime
SET age_limit = age_limit + 1
WHERE title = 'Attack on Titan' and age_limit = 17;


SELECT * FROM anime WHERE release_date > '2010-01-01';


DELETE FROM anime
WHERE age_limit = 13;


SELECT DISTINCT action_text FROM user_actions_log;


SELECT * FROM users
ORDER BY username ASC;


SELECT * FROM anime
ORDER BY title DESC;


SELECT users.username, reviews.content
FROM users
FULL JOIN reviews
ON users.id = reviews.user_id;


SELECT u.username, r.name AS role_name
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY r.name ASC, u.username DESC;


SELECT * FROM anime
ORDER BY release_date DESC
LIMIT 5 OFFSET 1;


SELECT * FROM users
WHERE role_id IN (1, 2);



SELECT title, description
FROM anime;


SELECT * FROM user_actions_log WHERE action_time BETWEEN '2024-01-01' AND '2024-12-31';

SELECT * FROM publishers;

SELECT * FROM anime
WHERE publisher_id = (
SELECT id FROM publishers
WHERE name = 'Studio Ghibli');

SELECT a.title, a.description FROM anime a, user_actions_log;

SELECT * FROM anime
WHERE release_date BETWEEN '2000-01-01' AND '2010-12-31';


SELECT * FROM anime
WHERE title LIKE '%Naruto%';


SELECT * FROM users
WHERE email LIKE '%user%';


SELECT title, age_limit FROM anime
WHERE age_limit BETWEEN 14 AND 16;


SELECT * FROM anime
WHERE release_date <= '2010-12-31';


SELECT a.title, g.title AS genre
FROM anime a
JOIN anime_genres ag ON a.id = ag.anime_id
JOIN genres g ON ag.genre_id = g.id
WHERE g.title = 'Adventure'
ORDER BY a.release_date ASC
LIMIT 3 OFFSET 0;


SELECT u.username, r.name AS role_name
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name = 'User';


SELECT a.title, ap.platform_name
FROM anime a
JOIN watch_links wl ON a.id = wl.anime_id
JOIN anime_platforms ap ON wl.platform_id = ap.id
WHERE ap.platform_name = 'Netflix'; 


SELECT * FROM USERS;


UPDATE users
SET email = 'newemail@example.com', updated_at = NOW()
WHERE id = 2;


SELECT * FROM USERS;

INSERT INTO anime (title, description, release_date, age_limit, poster_url, publisher_id)
VALUES ('Demon Slayer', 'A story about demon hunters', '2019-04-06', 14, 'https://example.com/demonslayer.jpg', 1)
ON CONFLICT DO NOTHING;

INSERT INTO anime (title, description, release_date, age_limit, poster_url, publisher_id)
VALUES ('One Punch Man', 'The story follows Saitama, a hero who can defeat any opponent with a single punch. Bored with his overwhelming strength, he seeks a worthy opponent while navigating the challenges of being a hero in a world filled with monsters and villains.', '2015-10-05', 14, 'https://example.com/onepunchman.jpg', 1)
ON CONFLICT DO NOTHING;

SELECT * FROM anime;


SELECT a.title, a.release_date, a.age_limit, p.name AS publisher
FROM anime a
JOIN publishers p ON a.publisher_id = p.id
WHERE a.release_date > '2000-01-01'
  AND a.age_limit >= 12
  AND p.name = 'Shonen Jump';


SELECT a.title, STRING_AGG(g.title, ', ') AS genres
FROM anime a
JOIN anime_genres ag ON a.id = ag.anime_id
JOIN genres g ON ag.genre_id = g.id
WHERE g.title IN ('Action', 'Adventure')
GROUP BY a.title;


SELECT u.username, ua.action_text, ua.action_time
FROM users u
JOIN user_actions_log ua ON u.id = ua.user_id
WHERE u.username LIKE 'a%';


SELECT COUNT(*) AS total_anime FROM anime;


SELECT ROUND(AVG(rating)::numeric, 2) AS average_rating FROM reviews;


SELECT publisher_id, COUNT(*) AS total_anime FROM anime
GROUP BY publisher_id;

SELECT anime.title, AVG(rating) AS average_rating 
FROM reviews
INNER JOIN anime ON reviews.id = anime.id
GROUP BY anime.title;


SELECT a.title, COUNT(r.id) AS review_count
FROM anime a
JOIN reviews r ON a.id = r.anime_id
GROUP BY a.id
HAVING COUNT(r.id) = (
  SELECT MAX(review_count)
  FROM (
    SELECT COUNT(r.id) AS review_count
    FROM reviews r
    GROUP BY r.anime_id
  ) AS review_counts
);


SELECT a.title, AVG(r.rating) AS average_rating, COUNT(r.id) AS total_reviews
FROM anime a
JOIN reviews r ON a.id = r.anime_id
GROUP BY a.id
ORDER BY average_rating DESC;


SELECT u.username, a.title
FROM users u
JOIN bookmarks b ON u.id = b.user_id
JOIN anime a ON b.anime_id = a.id
WHERE b.status_id = (
  SELECT id FROM bookmark_statuses WHERE status = 'Want to start'
);


SELECT a.title, AVG(r.rating) AS average_rating, COUNT(r.id) AS review_count
FROM anime a
JOIN reviews r ON a.id = r.anime_id
GROUP BY a.id
HAVING COUNT(r.id) > 3 AND AVG(r.rating) > 8.0;


SELECT a.title, g.title AS genre, p.platform_name, wl.watch_link
FROM anime a
JOIN anime_genres ag ON a.id = ag.anime_id
JOIN genres g ON ag.genre_id = g.id
JOIN watch_links wl ON a.id = wl.anime_id
JOIN anime_platforms p ON wl.platform_id = p.id;


SELECT u.username, r.rating, r.content, r.anime_id
FROM users u
LEFT OUTER JOIN reviews r ON u.id = r.user_id;


SELECT a.title AS anime_title, u.username
FROM anime a
RIGHT JOIN bookmarks b ON a.id = b.anime_id
RIGHT JOIN users u ON b.user_id = u.id;


SELECT u.username, a.title AS anime_title
FROM users u
CROSS JOIN anime a;


SELECT a.title, AVG(r.rating) AS average_rating
FROM anime a
LEFT JOIN reviews r ON a.id = r.anime_id
GROUP BY a.id;


SELECT a.title, COUNT(b.id) AS bookmark_count
FROM anime a
JOIN bookmarks b ON a.id = b.anime_id
GROUP BY a.id
HAVING COUNT(b.id) > 1;


SELECT a.title, AVG(r.rating) AS average_rating, a.release_date
FROM anime a
JOIN reviews r ON a.id = r.anime_id
GROUP BY a.id, a.title, a.release_date
HAVING AVG(r.rating) > 8 AND a.release_date BETWEEN '2000-01-01' AND '2010-12-31';


(SELECT title, release_date, age_limit
 FROM anime
 WHERE age_limit < 14)
UNION 
(SELECT anime.title, anime.release_date, anime.age_limit
 FROM anime
 JOIN reviews ON anime.id = reviews.anime_id
 WHERE reviews.rating > 8);


SELECT title, publisher_id, 
       ROW_NUMBER() OVER (PARTITION BY publisher_id) AS row_num
FROM anime;


SELECT a.title, p.name AS publisher_name, r.rating, 
       RANK() OVER (PARTITION BY a.publisher_id ORDER BY r.rating DESC) AS rank
FROM anime a
JOIN reviews r ON a.id = r.anime_id
JOIN publishers p ON a.publisher_id = p.id;


SELECT title, publisher_id, 
       COUNT(*) OVER (PARTITION BY publisher_id) AS anime_count_per_publisher
FROM anime;


SELECT content, rating, 
       LAG(rating) OVER (ORDER BY rating) AS previous_rating
FROM reviews;


SELECT title, publisher_id, rating,
       AVG(rating) OVER (PARTITION BY publisher_id) AS avg_rating_per_publisher
FROM anime
JOIN reviews ON anime.id = reviews.anime_id;


SELECT a.title
FROM anime a
WHERE NOT EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.anime_id = a.id
);


SELECT title,
       CASE 
           WHEN age_limit <= 12 THEN 'Family Friendly'
           WHEN age_limit BETWEEN 13 AND 16 THEN 'Teen'
           ELSE 'Adult'
       END AS age_category
FROM anime;


SELECT title, age_limit
FROM anime
ORDER BY 
  CASE 
      WHEN age_limit <= 12 THEN 1
      WHEN age_limit BETWEEN 13 AND 15 THEN 2
      ELSE 3
  END;



EXPLAIN 
SELECT a.title, r.rating 
FROM anime a 
JOIN reviews r ON a.id = r.anime_id;


EXPLAIN ANALYZE
SELECT a.title, r.rating 
FROM anime a 
JOIN reviews r ON a.id = r.anime_id;


-- CREATE INDEX idx_reviews_anime_id ON reviews(anime_id); 

SELECT title, description
FROM anime;

INSERT INTO anime (title, description, release_date, age_limit, poster_url, publisher_id) 
VALUES ('Naruto', 'New description of Naruto', '2002-10-03', 14, 'https://example.com/naruto_new.jpg', 2)
ON CONFLICT (title) 
DO UPDATE SET 
    description = EXCLUDED.description
WHERE anime.description IS DISTINCT FROM EXCLUDED.description;


SELECT a.title, r.rating 
FROM anime a 
FULL JOIN reviews r ON a.id = r.anime_id;

SELECT a.title, r.rating 
FROM anime a 
CROSS JOIN reviews r;