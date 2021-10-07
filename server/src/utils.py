import os
from flask_sqlalchemy import SQLAlchemy
import boto3

db = SQLAlchemy()

BUCKET = "clean-the-planet"
ENDPOINT_URL = None
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID', None)
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY', None)
USE_SSL = True
if not (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID):
    ENDPOINT_URL = "https://clean-the-planet-s3.loca.lt/"
    AWS_ACCESS_KEY_ID = '123'
    AWS_SECRET_ACCESS_KEY = 'abc'
    USE_SSL = False

bucket = "clean-the-planet"
s3_resource = boto3.resource('s3',
                             endpoint_url=ENDPOINT_URL,
                             aws_access_key_id=AWS_ACCESS_KEY_ID,
                             aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                             use_ssl=USE_SSL)

s3_client = boto3.client('s3',
                         endpoint_url=ENDPOINT_URL,
                         aws_access_key_id=AWS_ACCESS_KEY_ID,
                         aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                         use_ssl=USE_SSL)