PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL

);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id TEXT NOT NULL,
  parent_reply TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  likes INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES quesitons(id)
);

INSERT INTO
  users(fname,lname)
VALUES
  ('Kevin', 'Choy'), ('Jason', 'Wong'), ('Bob', 'Lee');


INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Classes', 'How do classes work', (SELECT id FROM users WHERE fname = 'Kevin' AND lname = 'Choy')),
  ('Lunchtime', 'Can we get extended lunches?',(SELECT id FROM users WHERE fname = 'Jason' AND lname = 'Wong')),
  ('SQL', 'Lorem epsum how do you do this',(SELECT id FROM users WHERE fname = 'Bob' AND lname = 'Lee'));

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (3, 1),
  (2, 3),
  (1, 2);
