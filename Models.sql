CREATE TABLE IF NOT EXISTS roles (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);


INSERT INTO roles (name) VALUES 
('Admin'), 
('User')
ON CONFLICT (name) DO NOTHING;


CREATE TABLE IF NOT EXISTS users (
	id SERIAL PRIMARY KEY,
	role_id INT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
	username VARCHAR(50) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE,
	created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP DEFAULT NOW()
);


---  id SERIAL PRIMARY KEY,
CREATE TABLE IF NOT EXISTS reviews_like (
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  review_id INT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  is_like BOOLEAN,
  PRIMARY KEY (review_id, user_id)
);


INSERT INTO reviews_like (user_id, review_id, is_like) VALUES
(1, 1, TRUE),
(2, 2, TRUE),
(3, 3, FALSE), 
(4, 4, TRUE)
ON CONFLICT DO NOTHING;


CREATE INDEX idx_users_email ON users(email);


INSERT INTO users (role_id, username, password, email, phone) VALUES
(1, 'admin', 'password1', 'admin@example.com', '1234567890'),
(2, 'user1', 'password2', 'user1@example.com', '0987654321'),
(2, 'user2', 'password3', 'user2@example.com', '1112223333'),
(2, 'user3', 'password4', 'user3@example.com', '4445556666'),
(1, 'superadmin', 'superpassword', 'superadmin@example.com', '7778889999')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS user_profiles (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100),
  sirname VARCHAR(100),
  gender VARCHAR(10),
  birth_date DATE,
  avatar_url VARCHAR(255)
);


INSERT INTO user_profiles (user_id, name, sirname, gender, birth_date, avatar_url) VALUES
(1, 'Admin', 'Adminson', 'M', '1990-01-01', 'https://example.com/avatar1.jpg'),
(2, 'John', 'Doe', 'M', '1992-02-02', 'https://example.com/avatar2.jpg'),
(3, 'Jane', 'Smith', 'F', '1994-03-03', 'https://example.com/avatar3.jpg'),
(4, 'Michael', 'Jordan', 'M', '1996-04-04', 'https://example.com/avatar4.jpg'),
(5, 'Super', 'Admin', 'M', '1985-05-05', 'https://example.com/superadmin.jpg')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS user_actions_log (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action_text VARCHAR(255) NOT NULL,
  action_time TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_user_actions_log_user_id ON user_actions_log(user_id);
CREATE INDEX idx_user_actions_log_action_time ON user_actions_log(action_time);


INSERT INTO user_actions_log (user_id, action_text) VALUES
(1, 'Logged in'),
(1, 'Added anime'),
(1, 'Logged out'),
(2, 'Logged in'),
(2, 'Like anime'),
(3, 'Logged in'),
(3, 'Viewed profile'),
(4, 'Logged in'),
(4, 'Commented on anime'),
(5, 'Logged in'),
(5, 'Added new user')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS publishers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255),
  wiki_link VARCHAR(255),
  photo_url VARCHAR(255)
);


INSERT INTO publishers (name, description, wiki_link, photo_url) VALUES
('Shonen Jump', 'Famous manga publisher', 'https://en.wikipedia.org/wiki/Shonen_Jump', 'https://example.com/shonenjump.jpg'),
('Масаши Кишимото', 'Create anime such as Naruto, Boruto, etc.', 'https://en.wikipedia.org/wiki/Masashi_Kishimoto', 'https://example.com/mashashi.jpg'),
('Hajime Isayama', 'Create anime such as Attack on Titan etc.', 'https://en.wikipedia.org/wiki/Hajime_Isayama', 'https://example.com/Hajime.jpg'),
('Studio Ghibli', 'Japanese animation studio', 'https://en.wikipedia.org/wiki/Studio_Ghibli', 'https://example.com/ghibli.jpg'),
('Toei Animation', 'Animation studio famous for Dragon Ball, One Piece', 'https://en.wikipedia.org/wiki/Toei_Animation', 'https://example.com/toei.jpg')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS anime (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  release_date DATE,
  poster_url VARCHAR(255),
  age_limit INT NOT NULL,
  publisher_id INT REFERENCES publishers(id) ON DELETE SET NULL
);


CREATE INDEX idx_anime_title ON anime(title);
CREATE INDEX idx_anime_release_date ON anime(release_date);


INSERT INTO anime (title, description, release_date, age_limit, poster_url, publisher_id) VALUES
('Naruto', 'A story about a young ninja', '2002-10-03', '14', 'https://example.com/naruto.jpg', 2),
('Attack on Titan', 'Humans vs Titans', '2013-04-07', '16', 'https://example.com/aot.jpg', 3),
('Spirited Away', 'A young girl trapped in a mysterious world', '2001-07-20', 12, 'https://example.com/spirited_away.jpg', 4),
('One Piece', 'A pirate crew searches for the ultimate treasure', '1999-10-20', 12, 'https://example.com/onepiece.jpg', 5)
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS genres (
  id SERIAL PRIMARY KEY,
  title VARCHAR(50) NOT NULL UNIQUE
);


INSERT INTO genres (title) VALUES
('Action'),
('Adventure'),
('Fantasy'),
('Drama'),
('Comedy')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS anime_genres (
  anime_id INT NOT NULL REFERENCES anime(id) ON DELETE CASCADE,
  genre_id INT NOT NULL REFERENCES genres(id) ON DELETE RESTRICT,
  PRIMARY KEY (anime_id, genre_id)
);


INSERT INTO anime_genres (anime_id, genre_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(3, 1),  
(3, 2),  
(4, 1),  
(4, 3)   
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS anime_platforms (
  id SERIAL PRIMARY KEY,
  platform_name VARCHAR(50) NOT NULL UNIQUE
);


INSERT INTO anime_platforms (platform_name) VALUES
('Crunchyroll'),
('Netflix'),
('Funimation'),
('Hulu')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS watch_links (
  id SERIAL PRIMARY KEY,
  anime_id INT NOT NULL REFERENCES anime(id) ON DELETE CASCADE,
  platform_id INT NOT NULL REFERENCES anime_platforms(id) ON DELETE RESTRICT,
  watch_link VARCHAR(255)
);


INSERT INTO watch_links (anime_id, platform_id, watch_link) VALUES
(1, 1, 'https://example.com/watch-naruto'),
(2, 1, 'https://example.com/watch-aot'),
(2, 2, 'https://www.netflix.com/tw-en/title/70299043'),
(3, 2, 'https://www.netflix.com/tw-en/title/60023642'),  
(4, 3, 'https://www.hulu.com/series/one-piece')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  anime_id INT NOT NULL REFERENCES anime(id) ON DELETE CASCADE,
  rating REAL NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_anime_id ON reviews(anime_id);


INSERT INTO reviews (user_id, anime_id, rating, content) VALUES
(1, 1, 9.5, 'Great anime!'),
(2, 2, 9.0, 'Amazing story and action.'),
(3, 3, 8.5, 'Beautiful and emotional anime!'),
(4, 4, 9.2, 'A long but amazing adventure. Worth watching.')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS bookmark_statuses (
  id SERIAL PRIMARY KEY,
  status VARCHAR(50) NOT NULL UNIQUE
);


INSERT INTO bookmark_statuses (status) VALUES
('Watching'),
('Completed'),
('Want to start')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS bookmarks (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status_id INT NOT NULL REFERENCES bookmark_statuses(id) ON DELETE RESTRICT,
  anime_id INT NOT NULL REFERENCES anime(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_anime_id ON bookmarks(anime_id);


INSERT INTO bookmarks (user_id, status_id, anime_id) VALUES
(1, 3, 1),
(2, 2, 2),
(3, 1, 3),
(4, 2, 4)
ON CONFLICT DO NOTHING;

