import os
from flask import Flask, request
from flask_cors import CORS
from io import StringIO
import json
import firebase_admin
from firebase_admin import credentials, auth

from . import config

#Connect to Firebase
serviceAccountJson = os.environ.get("SERVICE_ACCOUNT_JSON", None)
if serviceAccountJson:
    serviceAccount = json.load(StringIO(serviceAccountJson))
    cred = credentials.Certificate(serviceAccount)
else:
    cred = credentials.Certificate(os.environ.get("CERTIFICATE_PATH", None))
firebase_admin.initialize_app(cred)


def create_app(config_class=config.Config):
    app = Flask(__name__)
    CORS(app)
    app.config.from_object(config_class)

    DATABASE_URL = os.environ.get('DATABASE_URL', None)
    if DATABASE_URL:
        if DATABASE_URL.startswith("postgres://"):
            SQLALCHEMY_DATABASE_URI = DATABASE_URL.replace("://", "ql://", 1)
        else:
            SQLALCHEMY_DATABASE_URI = DATABASE_URL
        app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI

    from . import routes
    app.register_blueprint(routes.bp)

    from . import db
    db.init_app(app)

    @app.before_request
    def _():
        if request.method == "OPTIONS":
            return {"message": "Check succeeded."}, 200

        authHeader = request.headers.get("Authorization")
        if not authHeader:
            return {"message": "No Token provided."}, 401
        try:
            token = authHeader.split()[1]
            user = auth.verify_id_token(token)
            request.user = user
        except:
            return {"message": "Invalid Token provided."}, 401

    return app