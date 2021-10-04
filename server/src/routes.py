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
s3_client = boto3.resource('s3',
                           endpoint_url="http://0.0.0.0:4566/",
                           aws_access_key_id=ACCESS_KEY,
                           aws_secret_access_key=SECRET_KEY,
                           use_ssl=False)


@routes.route("/tour", methods=["POST"])
def addTour():
    #userId = request.user['user_id']
    userId = "testi"

    if request.is_json:
        data = request.get_json()
        tour = Tour(userId=userId, polyline=data['polyline'])
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
            functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline,
                                                     25832), 0.0001)),
        functions.ST_AsText(Tour.polyline)).filter_by(userId=userId)

    results = [{
        "id": id,
        "polygon": polygon,
        "polyline": polyline
    } for (id, polygon, polyline) in tours]

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
    file = request.files['files']
    file_content = file.read()

    picture_keys = []
    try:
        file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
        s3_client.Object(bucket, file_name).put(Body=file_content)
        picture_keys.append(file_name)
    except ClientError as e:
        logging.error(e)
        return "Error", 400
    return {"picture_keys": picture_keys}


@routes.route("/pictures", methods=["GET"])
def downloadFile():
    return s3_client.generate_presigned_url(
        'get_object',
        Params={
            'Bucket': bucket,
            'Key': "CAP_EAC11C74-C707-4CD7-B021-EAC2B209A391.jpg"
        },
        ExpiresIn=60)
