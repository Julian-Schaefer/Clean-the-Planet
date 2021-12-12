DROP TABLE IF EXISTS tour;
DROP TABLE IF EXISTS tour_picture;

CREATE TABLE tour (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  datetime DATETIME NOT NULL,
  duration DATETIME NOT NULL,
  amount FLOAT NOT NULL,
  polyline TEXT NOT NULL,
  result_picture_keys TEXT
);

CREATE TABLE tour_picture (
  id TEXT PRIMARY KEY,
  tour_id TEXT,
  location TEXT NOT NULL,
  picture_key TEXT NOT NULL,
  comment TEXT,
  FOREIGN KEY (tour_id) REFERENCES tour (id)
);
