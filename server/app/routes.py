from flask import Blueprint, request, jsonify
from geoalchemy2 import functions
import uuid
import json

from app.db import db
from app.storage import s3_resource, BUCKET
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
                location = json.dumps(tour_picture_json['location'])
                tour_picture = TourPicture(
                    tour_id=id,
                    location=geom_from_geo_json(location),
                    picture_key=tour_picture_json['pictureKey'],
                    comment=tour_picture_json['comment'])
                tour_pictures.append(tour_picture)

        polyline = json.dumps(data['polyline'])
        centerPoint = get_centroid(polyline)

        tour = Tour(id=id,
                    userId=userId,
                    polyline=geom_from_geo_json(polyline),
                    centerPoint=geom_from_geo_json(centerPoint),
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
        Tour.id, functions.ST_AsGeoJSON(get_buffer(Tour.polyline)),
        functions.ST_AsGeoJSON(Tour.polyline),
        functions.ST_AsGeoJSON(Tour.centerPoint), Tour.datetime, Tour.duration,
        Tour.amount, Tour.result_picture_keys).filter_by(userId=userId)

    for (id, polygon, polyline, centerPoint, datetime, duration, amount,
         result_picture_keys) in tours_query:
        tour_pictures_query = db.session.query(
            TourPicture,
            functions.ST_AsGeoJSON(TourPicture.location)).filter_by(tour_id=id)

        tours.append({
            "id":
            id,
            "polygon":
            string_to_json(polygon),
            "polyline":
            string_to_json(polyline),
            "centerPoint":
            string_to_json(centerPoint),
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
                "location": string_to_json(location),
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
        polyline_json = json.dumps(data['polyline'])
        polyline = geom_from_geo_json(polyline_json)

        polygon = db.session.query(functions.ST_AsGeoJSON(
            get_buffer(polyline))).one()
        return jsonify({"polygon": string_to_json(polygon[0])})

    return "Error", 400


def get_centroid(geometry):
    return db.session.query(
        functions.ST_AsGeoJSON(
            functions.ST_Centroid(geom_from_geo_json(geometry)))).one()[0]


def geom_from_geo_json(geo_json):
    return functions.ST_SetSRID(functions.ST_GeomFromGeoJSON(geo_json), 4326)


def get_buffer(polyline):
    meters = 10
    return functions.ST_Buffer(
        functions.ST_GeogFromWKB(functions.ST_AsBinary((polyline))), meters)


def string_to_json(geometry):
    parsed_json = json.loads(geometry)
    return parsed_json
