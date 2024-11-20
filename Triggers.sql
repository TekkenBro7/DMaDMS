CREATE OR REPLACE FUNCTION log_profile_update()
RETURNS TRIGGER AS $$
DECLARE
    changes TEXT := '';
BEGIN
    IF NEW.name IS DISTINCT FROM OLD.name THEN
        changes := changes || 'Имя изменено с "' || OLD.name || '" на "' || NEW.name || '". ';
    END IF;
    IF NEW.sirname IS DISTINCT FROM OLD.sirname THEN
        changes := changes || 'Фамилия изменена с "' || OLD.sirname || '" на "' || NEW.sirname || '". ';
    END IF;
    IF NEW.gender IS DISTINCT FROM OLD.gender THEN
        changes := changes || 'Пол изменен с "' || OLD.gender || '" на "' || NEW.gender || '". ';
    END IF;
    IF NEW.birth_date IS DISTINCT FROM OLD.birth_date THEN
        changes := changes || 'Дата рождения изменена с "' || OLD.birth_date || '" на "' || NEW.birth_date || '". ';
    END IF;
    IF NEW.avatar_url IS DISTINCT FROM OLD.avatar_url THEN
        changes := changes || 'URL аватара изменен. ';
    END IF;
    IF changes <> '' THEN
        INSERT INTO user_actions_log (user_id, action_text)
        VALUES (NEW.user_id, 'Профиль обновлен: ' || changes);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE TRIGGER trigger_log_profile_update
AFTER UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION log_profile_update();



SELECT * FROM user_actions_log;

UPDATE user_profiles
SET name = 'Имя', sirname = 'Фамилия', gender = 'Mкуц', birth_date = '1931-01-01', avatar_url = 'https://example.com/new_avatar3.jpg'
WHERE user_id = 1;

SELECT * FROM user_profiles;
SELECT * FROM user_actions_log;




CREATE OR REPLACE FUNCTION add_bookmark_on_review()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO bookmarks (user_id, anime_id, status_id)
  SELECT NEW.user_id, NEW.anime_id, 1
  WHERE NOT EXISTS (
    SELECT 1
    FROM bookmarks
    WHERE user_id = NEW.user_id AND anime_id = NEW.anime_id
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_add_bookmark_on_review
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION add_bookmark_on_review();

INSERT INTO users (role_id, username, password, email, phone) 
VALUES (2, 'test_user', 'test_password', 'test@example.com', '12345678')
ON CONFLICT DO NOTHING;

SELECT * FROM bookmarks;
SELECT * FROM users;

SELECT * FROM reviews;

INSERT INTO reviews (user_id, anime_id, rating, content) 
VALUES (8, 1, 9.0, 'Great anime!')
ON CONFLICT DO NOTHING;

SELECT * FROM bookmarks;




-- ALTER TABLE anime ADD COLUMN average_rating REAL DEFAULT 0.0;

SELECT * FROM anime;


CREATE OR REPLACE FUNCTION recalculate_anime_average_rating()
RETURNS TRIGGER AS $$
BEGIN
    -- Если отзывов больше нет, сбрасываем рейтинг на 0.0
    IF (SELECT COUNT(*) FROM reviews WHERE anime_id = COALESCE(OLD.anime_id, NEW.anime_id)) = 0 THEN
        UPDATE anime
        SET average_rating = 0.0
        WHERE id = COALESCE(OLD.anime_id, NEW.anime_id);
    ELSE
        UPDATE anime
        SET average_rating = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2)
            FROM reviews
            WHERE anime_id = COALESCE(OLD.anime_id, NEW.anime_id)
        ), 0.0)
        WHERE id = COALESCE(OLD.anime_id, NEW.anime_id);
    END IF;
    RETURN NULL; -- AFTER-триггеры не требуют возврата значения
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE TRIGGER trigger_recalculate_anime_rating
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW
EXECUTE FUNCTION recalculate_anime_average_rating();


INSERT INTO anime (title, description, release_date, age_limit, publisher_id)
VALUES ('Anime Title', 'Description here', '2023-01-01', 12, NULL)
ON CONFLICT DO NOTHING;


SELECT id, title, average_rating FROM anime;
SELECT * FROM reviews;

--INSERT INTO reviews (user_id, anime_id, rating, content)
--VALUES 
--(1, 363, 9, 'Great anime!');

SELECT id, title, average_rating FROM anime;

DELETE FROM reviews WHERE id = 61;

-- DELETE FROM reviews WHERE anime_id = 363;

-- UPDATE reviews SET rating = 6.5 WHERE id = 63;

SELECT id, title, average_rating FROM anime;




CREATE OR REPLACE FUNCTION protect_admin_user()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') AND OLD.role_id = 1 THEN
        RAISE EXCEPTION 'Нельзя изменять или удалять пользователя с ролью Admin.';
    END IF;
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_protect_admin_user
BEFORE UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION protect_admin_user();

-- DELETE FROM users WHERE id = 1;




CREATE OR REPLACE FUNCTION log_anime_update()
RETURNS TRIGGER AS $$
DECLARE
    changes TEXT := '';
BEGIN
    IF NEW.title IS DISTINCT FROM OLD.title THEN
        changes := changes || 'Название изменено с "' || OLD.title || '" на "' || NEW.title || '". ';
    END IF;
    IF NEW.description IS DISTINCT FROM OLD.description THEN
        changes := changes || 'Описание обновлено. ';
    END IF;
    IF NEW.age_limit IS DISTINCT FROM OLD.age_limit THEN
        changes := changes || 'Возрастное ограничение изменено с "' || OLD.age_limit || '" на "' || NEW.age_limit || '". ';
    END IF;
    IF NEW.publisher_id IS DISTINCT FROM OLD.publisher_id THEN
        changes := changes || 'Издатель изменён. ';
    END IF;
    IF changes <> '' THEN
        INSERT INTO user_actions_log (user_id, action_text)
        VALUES (1, 'Изменения в аниме: ' || changes); -- Для простоты логируем от имени пользователя admin.
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_log_anime_update
AFTER UPDATE ON anime
FOR EACH ROW
EXECUTE FUNCTION log_anime_update();


UPDATE anime
SET title = 'Naruto: Shippuden', age_limit = 16
WHERE id = 1;

SELECT * FROM user_actions_log;




CREATE OR REPLACE FUNCTION log_bookmark_status_update()
RETURNS TRIGGER AS $$
DECLARE
    changes TEXT := '';
BEGIN
    IF NEW.status_id IS DISTINCT FROM OLD.status_id THEN
        changes := 'Пользователь с ID ' || NEW.user_id || ' изменил статус закладки с "' || OLD.status_id || '" на "' || NEW.status_id || '".';
        INSERT INTO user_actions_log (user_id, action_text)
        VALUES (NEW.user_id, changes);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_log_bookmark_status_update
AFTER UPDATE ON bookmarks
FOR EACH ROW
EXECUTE FUNCTION log_bookmark_status_update();


SELECT * FROM bookmarks;


UPDATE bookmarks
SET status_id = 1
WHERE id = 1;

SELECT * FROM user_actions_log;




CREATE OR REPLACE FUNCTION log_review_action()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_actions_log (user_id, action_text, action_time)
    VALUES (NEW.user_id, CONCAT('Added a review for anime ID: ', NEW.anime_id), NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION log_review_action();

INSERT INTO reviews (user_id, anime_id, rating, content)
VALUES (2, 1, 8.8, 'Enjoyed this anime a lot!');

SELECT * FROM user_actions_log;




CREATE OR REPLACE FUNCTION log_review_like_dislike()
RETURNS TRIGGER AS $$
DECLARE
	anime_title VARCHAR(150);
	action_text VARCHAR(150);
BEGIN
	SELECT a.title INTO anime_title
	FROM reviews r
	JOIN anime a on a.id = r.id
	WHERE r.id = NEW.review_id;

	action_text := CASE
		WHEN NEW.is_like = TRUE THEN 'Liked'
		WHEN NEW.is_like = FALSE THEN 'Disliked'
		ELSE 'Reacted to'
	END || ' the review for anime "' || anime_title || '"';

	INSERT INTO user_actions_log (user_id, action_text, action_time)
	VALUES (NEW.user_id, action_text, NOW());

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trg_log_review_like_dislike
AFTER INSERT ON reviews_like
FOR EACH ROW
EXECUTE FUNCTION log_review_like_dislike();


SELECT * FROM reviews_like;
SELECT * FROM reviews;


-- INSERT INTO reviews_like (review_id, user_id, is_like)
-- VALUES (1, 3, TRUE); -- Пользователь 1 лайкает отзыв 1

-- Проверка логов действий пользователя
SELECT * FROM user_actions_log;

SELECT * FROM anime;




CREATE OR REPLACE FUNCTION get_reviews_by_anime_id(anime_id_input INT)
RETURNS TABLE (
    review_id INT,
    user_id INT,
    username VARCHAR,
    rating REAL,
    content TEXT,
    created_at TIMESTAMP,
	like_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id AS review_id,
        r.user_id,
        u.username,
        r.rating,
        r.content,
        r.created_at,
		COUNT(*) FILTER (WHERE rl.is_like =TRUE) AS like_count
    FROM reviews r
	LEFT JOIN reviews_like rl on r.id = rl.review_id AND rl.is_like = TRUE
    JOIN users u ON r.user_id = u.id
    WHERE r.anime_id = anime_id_input
	GROUP BY r.id, u.username
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- DROP FUNCTION IF EXISTS get_reviews_by_anime_id(integer);

SELECT * FROM get_reviews_by_anime_id(2);




CREATE OR REPLACE FUNCTION get_anime_by_genre(genre_name VARCHAR)
RETURNS TABLE (
    anime_id INT,
    title VARCHAR,
    description TEXT,
    release_date DATE,
    age_limit INT,
    poster_url VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id AS anime_id,
        a.title,
        a.description,
        a.release_date,
        a.age_limit,
        a.poster_url
    FROM 
        anime a
    INNER JOIN 
        anime_genres ag ON a.id = ag.anime_id
    INNER JOIN 
        genres g ON ag.genre_id = g.id
    WHERE 
        g.title = genre_name;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_anime_by_genre('Adventure');




CREATE OR REPLACE FUNCTION get_anime_ratings()
RETURNS TABLE (
    anime_id INT,
    anime_title VARCHAR,
    average_rating REAL,
    total_reviews BIGINT,
    total_likes BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id AS anime_id,
        a.title AS anime_title,
        COALESCE(AVG(r.rating)::real, 0) AS average_rating,
        COUNT(r.id) AS total_reviews,
        COALESCE(SUM(CASE WHEN rl.is_like = TRUE THEN 1 ELSE 0 END), 0) AS total_likes
    FROM anime a
    LEFT JOIN reviews r ON a.id = r.anime_id
    LEFT JOIN reviews_like rl ON r.id = rl.review_id
    GROUP BY a.id, a.title
    ORDER BY average_rating DESC, total_reviews DESC;
END;
$$ LANGUAGE plpgsql;


-- DROP FUNCTION IF EXISTS get_anime_ratings();

SELECT * FROM get_anime_ratings();



CREATE OR REPLACE PROCEDURE delete_old_logs(p_days_ago INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM user_actions_log
    WHERE action_time < NOW() - INTERVAL '1 day' * p_days_ago;

    RAISE NOTICE 'Удалены логи старше % дней.', p_days_ago;
END;
$$;

select  * from user_actions_log;


CALL delete_old_logs(30);




CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION user_insert()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM users 
		WHERE username = NEW.username
	) THEN
        RAISE EXCEPTION 'Пользователь уже существует';
    END IF;

	IF NOT (NEW.email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE EXCEPTION 'Некорректный формат электронной почты: %', NEW.email;
    END IF;

	NEW.password := crypt(NEW.password, gen_salt('md5'));

	RAISE NOTICE 'Пользователь успешно добавлен.';
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_user_insert
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION user_insert();

SELECT * FROM users;

INSERT INTO users (role_id, username, password, email, phone) 
VALUES (1, 'unique_user234', 'secure_password', 'maks234@mail.com', '12235234567890');


SELECT * FROM users;