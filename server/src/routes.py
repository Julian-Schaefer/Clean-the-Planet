from flask import Blueprint, request, jsonify
import sqlalchemy
from geoalchemy2 import functions
import logging
from botocore.exceptions import ClientError
import pathlib
import uuid
import json

from utils import db, s3_client, s3_resource, BUCKET
from tour import Tour, TourPicture

routes = Blueprint('Routes', __name__)


@routes.route("/tour", methods=["POST"])
def addTour():
    userId = request.user['user_id']

    if request.is_json:
        data = request.get_json()
        id = uuid.uuid4()

        tour_pictures = []
        if data['tour_pictures']:
            tour_pictures_json = data['tour_pictures']
            for tour_picture_json in tour_pictures_json:
                tour_picture = TourPicture(
                    tour_id=id,
                    location=tour_picture_json['location'],
                    picture_key=tour_picture_json['imageKey'])
                tour_pictures.append(tour_picture)

        tour = Tour(id=id,
                    userId=userId,
                    polyline=data['polyline'],
                    duration=data['duration'],
                    amount=data['amount'],
                    result_picture_keys=data["result_picture_keys"],
                    tour_pictures=tour_pictures)
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
    userId = request.user['user_id']

    tours = []

    tours_query = db.session.query(
        Tour.id,
        functions.ST_AsText(
            functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline,
                                                     25832), 0.0001)),
        functions.ST_AsText(Tour.polyline), Tour.datetime, Tour.duration,
        Tour.amount, Tour.result_picture_keys).filter_by(userId=userId)

    for (id, polygon, polyline, datetime, duration, amount,
         result_picture_keys) in tours_query:
        tour_pictures_query = db.session.query(
            TourPicture,
            functions.ST_AsText(TourPicture.location)).filter_by(tour_id=id)

        tours.append({
            "id":
            id,
            "polygon":
            polygon,
            "polyline":
            polyline,
            "datetime":
            datetime.strftime('%Y-%m-%dT%H:%M:%S.%f'),
            "duration":
            str(duration),
            "amount":
            amount,
            "result_picture_keys":
            result_picture_keys,
            "result_pictures_urls":
            get_urls_from_picture_keys(result_picture_keys),
            "tour_pictures": [{
                "id":
                tour_picture.id,
                "location":
                location,
                "imageUrl":
                get_url_from_picture_key(tour_picture.picture_key),
                "comment":
                None
            } for (tour_picture, location) in tour_pictures_query]
        })

    return jsonify(tours)


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


@routes.route("/result-pictures", methods=["POST"])
def upload_result_pictures():
    files = request.files.getlist("files")

    picture_keys = []
    for file in files:
        try:
            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(BUCKET, file_name).put(Body=file_content)
            picture_keys.append(file_name)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_keys) > 0:
        return {"picture_keys": picture_keys}

    return "Error", 400


@routes.route("/tour-pictures", methods=["POST"])
def upload_tour_pictures():
    files = request.files.getlist("files")

    picture_json = []
    for file in files:
        try:
            file_json = json.loads(request.form[file.filename])

            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(BUCKET, file_name).put(Body=file_content)

            file_json['imageKey'] = file_name
            picture_json.append(file_json)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_json) > 0:
        return jsonify(picture_json)

    return "Error", 400


def get_urls_from_picture_keys(picture_keys):
    if not picture_keys:
        return

    pictures = []
    for picture_key in picture_keys:
        pictures.append(get_url_from_picture_key(picture_key))
    return pictures


def get_url_from_picture_key(picture_key):
    return s3_client.generate_presigned_url('get_object',
                                            Params={
                                                'Bucket': BUCKET,
                                                'Key': picture_key
                                            },
                                            ExpiresIn=60)
