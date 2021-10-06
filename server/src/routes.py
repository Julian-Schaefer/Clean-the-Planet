from flask import Blueprint, request, jsonify
import sqlalchemy
from geoalchemy2 import functions
import logging
import boto3
from botocore.exceptions import ClientError
import pathlib
import uuid

from database import db
from tour import Tour

routes = Blueprint('Routes', __name__)

ACCESS_KEY = '123'
SECRET_KEY = 'abc'
bucket = "clean-the-planet"
s3_resource = boto3.resource(
    's3',
    endpoint_url="https://clean-the-planet-s3.loca.lt/",
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    use_ssl=False)
s3_client = boto3.client('s3',
                         endpoint_url="https://clean-the-planet-s3.loca.lt/",
                         aws_access_key_id=ACCESS_KEY,
                         aws_secret_access_key=SECRET_KEY,
                         use_ssl=False)


@routes.route("/tour", methods=["POST"])
def addTour():
    #userId = request.user['user_id']
    userId = "testi"

    if request.is_json:
        data = request.get_json()
        tour = Tour(userId=userId,
                    polyline=data['polyline'],
                    result_picture_keys=data["picture_keys"])
        db.session.add(tour)

        try:
            db.session.commit()
        except sqlalchemy.exc.InternalError as err:
            print(err)
            return {"error": "Could not insert Tour into database."}, 400

        return {
            "message":
            f"Tour {tour.id} for User {tour.userId} has been created successfully."
        }
    else:
        return {"error": "The request payload is not in JSON format"}, 400


@routes.route("/tour", methods=["GET"])
def getTours():
    #userId = request.user['user_id']
    userId = "testi"

    tours = db.session.query(
        Tour.id,
        functions.ST_AsText(
            functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline, 25832),
                                0.0001)), functions.ST_AsText(Tour.polyline),
        Tour.result_picture_keys).filter_by(userId=userId)

    results = [{
        "id": id,
        "polygon": polygon,
        "polyline": polyline,
        "picture_keys": picture_keys,
        "result_pictures": get_urls_from_picture_key(picture_keys)
    } for (id, polygon, polyline, picture_keys) in tours]

    return jsonify(results)


@routes.route("/buffer", methods=["POST"])
def getBuffer():
    if request.is_json:
        data = request.get_json()
        polyline = data['polyline']

        polygon = db.session.query(
            functions.ST_AsText(
                functions.ST_Buffer(
                    functions.ST_SetSRID(functions.ST_GeomFromText(polyline),
                                         25832), 0.0001))).one()
        return jsonify({"polygon": polygon[0]})

    return "Error", 400


@routes.route("/pictures", methods=["POST"])
def upload_file():
    files = request.files.getlist("files")

    picture_keys = []
    for file in files:
        try:
            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(bucket, file_name).put(Body=file_content)
            picture_keys.append(file_name)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_keys) > 0:
        return {"picture_keys": picture_keys}

    return "Error", 400


def get_urls_from_picture_key(picture_keys):
    if not picture_keys:
        return

    pictures = []
    for picture_key in picture_keys:
        pictures.append(
            s3_client.generate_presigned_url('get_object',
                                             Params={
                                                 'Bucket': bucket,
                                                 'Key': picture_key
                                             },
                                             ExpiresIn=60))
    return pictures