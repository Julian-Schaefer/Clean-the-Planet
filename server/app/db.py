import os
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def init_app(app):
    DATABASE_URL = os.environ.get('DATABASE_URL', None)
    if DATABASE_URL:
        if DATABASE_URL.startswith("postgres://"):
            SQLALCHEMY_DATABASE_URI = DATABASE_URL.replace("://", "ql://", 1)
        else:
            SQLALCHEMY_DATABASE_URI = DATABASE_URL
        app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI

    db.init_app(app)
    migrate = Migrate()
    migrate.init_app(app, db)