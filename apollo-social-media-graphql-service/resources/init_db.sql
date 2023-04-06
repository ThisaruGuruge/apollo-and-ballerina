CREATE DATABASE IF NOT EXISTS apollo_social_media;


USE apollo_social_media;


CREATE TABLE
  IF NOT EXISTS user (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    age INT NOT NULL,
    name VARCHAR(255) NOT NULL
  );


CREATE TABLE
  IF NOT EXISTS post (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
  );


INSERT INTO
  user (id, age, name)
VALUES
  ('91c7571c-5524-4f88-9e75-743fb94c3b48', 20, 'John'),
  ('e2e842d2-be51-454d-92b3-16e8e83a491a', 25, 'Jane'),
  ('d344a243-849d-4e60-915b-c1a432b6dd1d', 30, 'Jack');


INSERT INTO
  post (id, title, content, user_id)
VALUES
  (
    'c1a432b6-dd1d-4e60-915b-849d4e6081b6',
    'Hello World',
    'This is my first post - John',
    '91c7571c-5524-4f88-9e75-743fb94c3b48'
  ),
  (
    'c1a432b6-dd1d-4e60-915b-849d4e6081b7',
    'Hello World',
    'This is my first post - Jane',
    'e2e842d2-be51-454d-92b3-16e8e83a491a'
  ),
  (
    'c1a432b6-dd1d-4e60-915b-849d4e6081b8',
    'Hello World',
    'This is my first post - Jack',
    'd344a243-849d-4e60-915b-c1a432b6dd1d'
  );


328200190013178
328200190013178
