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