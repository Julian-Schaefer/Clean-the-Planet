DROP TABLE IF EXISTS tour;
DROP TABLE IF EXISTS tour_picture;

CREATE TABLE tour (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId TEXT NOT NULL,
  datetime TIMESTAMP NOT NULL,
  duration TEXT NOT NULL,
  amount FLOAT NOT NULL,
  polyline TEXT NOT NULL,
  result_picture_keys TEXT NOT NULL
);

CREATE TABLE tour_picture (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tour_id INTEGER,
  location TEXT NOT NULL,
  picture_key TEXT NOT NULL,
  comment TEXT NOT NULL,
  FOREIGN KEY (tour_id) REFERENCES tour (id)
);
