import os
from flask import Flask, request
from flask_cors import CORS
from routes import routes
from utils import db
from flask_migrate import Migrate
from io import StringIO
import json
import firebase_admin
from firebase_admin import credentials, auth

#Connect to Firebase
serviceAccountJson = os.environ.get("SERVICE_ACCOUNT_JSON", None)
if serviceAccountJson:
    serviceAccount = json.load(StringIO(serviceAccountJson))
    cred = credentials.Certificate(serviceAccount)
else:
    cred = credentials.Certificate(
        "/Users/julian/Google Drive/Programming/Clean the Planet/firebase-admin-sdk.json"
    )
firebase_admin.initialize_app(cred)

app = Flask(__name__)
CORS(app)
DATABASE_URL = os.environ.get('DATABASE_URL', None)
if DATABASE_URL:
    if DATABASE_URL.startswith("postgres://"):
        SQLALCHEMY_DATABASE_URI = DATABASE_URL.replace("://", "ql://", 1)
    else:
        SQLALCHEMY_DATABASE_URI = DATABASE_URL
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
else:
    app.config[
        'SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:planetpassword@localhost:5432/postgres"
app.register_blueprint(routes)
db.init_app(app)
migrate = Migrate(app, db)


@app.before_request
def authenticateUser():
    if request.method == "OPTIONS":
        return {"message": "Check succeeded."}, 200

    authHeader = request.headers.get("Authorization")
    if not authHeader:
        return {"message": "No Token provided."}, 400
    try:
        token = authHeader.split()[1]
        user = auth.verify_id_token(token)
        request.user = user
    except:
        return {"message": "Invalid Token provided."}, 400
