DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS questions_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE questions_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    user_id INTEGER NOT NULL,
    body TEXT NOT NULL,
    
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO users (fname, lname)
VALUES
('Jasmine', 'Kobata'),
('Claus', 'Jespersen'),
('John', 'Smith'),
('Jane', 'Doe');

INSERT INTO questions (title, body, user_id)
VALUES
('AppAcademy', 'Is this working?', (SELECT id from users WHERE lname = 'Doe')),
('SQL', 'Is this fun?', (SELECT id from users WHERE lname = 'Doe'));

INSERT INTO questions_follows(question_id, user_id)
VALUES
((SELECT id FROM questions WHERE title = 'AppAcademy'),
(SELECT id from users WHERE lname = 'Doe')),
((SELECT id FROM questions WHERE title = 'SQL'),
(SELECT id from users WHERE lname = 'Smith'));

INSERT INTO replies (question_id, parent_reply_id, user_id, body)
VALUES
(
    (SELECT id FROM questions WHERE title = 'AppAcademy'),
    NULL,
    (SELECT id from users WHERE lname = 'Smith'),
    'Yes, it is.'
),
(
    (SELECT id FROM questions WHERE title = 'AppAcademy'),
    1,
    (SELECT id from users WHERE lname = 'Smith'),
    'Maybe not.'
),
(
    (SELECT id FROM questions WHERE title = 'AppAcademy'),
    1,
    (SELECT id from users WHERE lname = 'Smith'),
    'You sure?.'
),
(
    (SELECT id FROM questions WHERE title = 'AppAcademy'),
    2,
    (SELECT id from users WHERE lname = 'Smith'),
    'Grandchild reply.'
);

INSERT INTO question_likes (user_id, question_id)
VALUES
((SELECT id from users WHERE lname = 'Kobata'),
(SELECT id FROM questions WHERE title = 'AppAcademy')
),
((SELECT id from users WHERE lname = 'Jespersen'),
(SELECT id FROM questions WHERE title = 'AppAcademy')
);

