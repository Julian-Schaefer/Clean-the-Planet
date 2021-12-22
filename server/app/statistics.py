from flask import Blueprint, request, jsonify
from geoalchemy2 import functions

from app.db import db
from app.tour import Tour

bp = Blueprint('statistics', __name__)


@bp.route("/statistics", methods=["GET"])
def getStatistics():
    bounds = request.args.get("bounds")
    if bounds:
        tours_query = db.session.query(
            Tour.id,
            functions.ST_AsText(
                functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline,
                                                         25832), 0.0001)),
            functions.ST_AsText(Tour.polyline),
            functions.ST_AsText(Tour.centerPoint), Tour.datetime,
            Tour.duration, Tour.amount, Tour.result_picture_keys).filter(
                functions.ST_Contains(functions.ST_Envelope(bounds),
                                      Tour.centerPoint))

        tours = [{
            "id": id,
            "polygon": polygon,
            "polyline": polyline,
            "centerPoint": centerPoint,
            "datetime": datetime.strftime('%Y-%m-%dT%H:%M:%S.%f'),
            "duration": str(duration),
            "amount": amount,
            "resultPictureKeys": result_picture_keys,
        } for (id, polygon, polyline, centerPoint, datetime, duration, amount,
               result_picture_keys) in tours_query]

        return jsonify(tours)

    return "Error", 400
