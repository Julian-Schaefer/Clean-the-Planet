from flask import Blueprint, request, jsonify
from geoalchemy2 import functions
import logging
from botocore.exceptions import ClientError
import pathlib
import uuid
import json

from app.db import db
from app.storage import s3_client, s3_resource, BUCKET
from app.tour import Tour, TourPicture

bp = Blueprint('routes', __name__)


@bp.route("/tour", methods=["POST"])
def addTour():
    userId = request.user['user_id']

    if request.is_json:
        data = request.get_json()
        id = uuid.uuid4()

        tour_pictures = []
        if data['tourPictures']:
            tour_pictures_json = data['tourPictures']
            for tour_picture_json in tour_pictures_json:
                tour_picture = TourPicture(
                    tour_id=id,
                    location=tour_picture_json['location'],
                    picture_key=tour_picture_json['pictureKey'],
                    comment=tour_picture_json['comment'])
                tour_pictures.append(tour_picture)

        centerPoint = get_centroid(data['polyline'])

        tour = Tour(id=id,
                    userId=userId,
                    polyline=data['polyline'],
                    centerPoint=centerPoint,
                    duration=data['duration'],
                    amount=data['amount'],
                    result_picture_keys=data["resultPictureKeys"],
                    tour_pictures=tour_pictures)

        db.session.add(tour)

        try:
            db.session.commit()
        except Exception as err:
            print(err)
            return {"error": "Could not insert Tour into database."}, 400

        return {
            "message":
            f"Tour {tour.id} for User {tour.userId} has been created successfully."
        }
    else:
        return {"error": "The request payload is not in JSON format"}, 400


@bp.route("/tour", methods=["GET"])
def getTours():
    userId = request.user['user_id']

    tours = []

    tours_query = db.session.query(
        Tour.id,
        functions.ST_AsText(
            functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline, 25832),
                                0.0001)), functions.ST_AsText(Tour.polyline),
        functions.ST_AsText(Tour.centerPoint), Tour.datetime, Tour.duration,
        Tour.amount, Tour.result_picture_keys).filter_by(userId=userId)

    for (id, polygon, polyline, centerPoint, datetime, duration, amount,
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
            "centerPoint":
            centerPoint,
            "datetime":
            datetime.strftime('%Y-%m-%dT%H:%M:%S.%f'),
            "duration":
            str(duration),
            "amount":
            amount,
            "resultPictureKeys":
            result_picture_keys,
            "tourPictures": [{
                "id": tour_picture.id,
                "location": location,
                "pictureKey": tour_picture.picture_key,
                "comment": tour_picture.comment
            } for (tour_picture, location) in tour_pictures_query]
        })

    return jsonify(tours)


@bp.route("/tour", methods=["DELETE"])
def deleteTour():
    userId = request.user['user_id']
    tourId = request.args.get('id')

    try:
        tours_query = db.session.query(Tour).filter_by(userId=userId,
                                                       id=tourId).one()
    except Exception:
        return {'message': 'Could not find appropriate Tour.'}, 400

    for result_picture_key in tours_query.result_picture_keys:
        s3_resource.Object(BUCKET, result_picture_key).delete()

    tour_pictures_query = db.session.query(TourPicture).filter_by(
        tour_id=tourId)

    for tour_picture in tour_pictures_query:
        s3_resource.Object(BUCKET, tour_picture.picture_key).delete()

    db.session.delete(tours_query)
    db.session.commit()

    return {
        "message":
        f"Tour {tourId} for User {userId} has been deleted successfully."
    }


@bp.route("/buffer", methods=["POST"])
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


def get_centroid(geometry):
    return db.session.query(
        functions.ST_AsText(
            functions.ST_Centroid(
                functions.ST_SetSRID(functions.ST_GeomFromText(geometry),
                                     25832)))).one()[0]


@bp.route("/result-pictures", methods=["POST"])
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


@bp.route("/tour-pictures", methods=["POST"])
def upload_tour_pictures():
    files = request.files.getlist("files")

    picture_json = []
    for file in files:
        try:
            file_json = json.loads(request.form[file.filename])

            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(BUCKET, file_name).put(Body=file_content)

            file_json['pictureKey'] = file_name
            picture_json.append(file_json)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_json) > 0:
        return jsonify(picture_json)

    return "Error", 400


@bp.route("/picture", methods=["GET"])
def get_picture_by_key():
    picture_key = request.args['key']
    picture_Url = get_url_from_picture_key(picture_key)

    return {"url": picture_Url}


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
