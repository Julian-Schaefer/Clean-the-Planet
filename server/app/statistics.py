from flask import Blueprint
# import sqlalchemy
# from geoalchemy2 import functions
# import logging
# from botocore.exceptions import ClientError
# import pathlib
# import uuid
# import json

# from sqlalchemy.sql.functions import user

# from app.db import db
# from app.tour import Tour

bp = Blueprint('statistics', __name__)


@bp.route("/statistics", methods=["GET"])
def getBuffer():
    # if request.is_json:
    #     data = request.get_json()
    #     polyline = data['polyline']

    # userId = request.user['user_id']

    # tours = []

    # tours_query = db.session.query(
    #    Tour.id,
    #     functions.ST_AsText(
    #         functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline,
    #                                                  25832), 0.0001)),
    #     functions.ST_AsText(Tour.polyline), Tour.datetime, Tour.duration,
    #     Tour.amount, Tour.result_picture_keys).filter(
    #         functions.ST_Contains(functions.ST_Envelope(polyline),
    #                               Tour.polyline))

    return "Error", 400
