from flask import Blueprint, request, jsonify
import sqlalchemy
from geoalchemy2 import functions

from database import db
from tour import Tour

routes = Blueprint('Routes', __name__)


@routes.route("/tour", methods=["POST"])
def addTour():
    #userId = request.user['user_id']
    userId = "testi"

    if request.is_json:
        data = request.get_json()
        tour = Tour(
            userId=userId, polygon=data['polygon'], polyline=data['polyline'])
        db.session.add(tour)
        
        try:
            db.session.commit()
        except sqlalchemy.exc.InternalError as err:
            print(err)
            return {"error": "Could not insert Tour into database."}, 400

        return {"message": f"Tour {tour.id} for User {tour.userId} has been created successfully."}
    else:
        return {"error": "The request payload is not in JSON format"}, 400


@routes.route("/tour", methods=["GET"])
def getTours():
    #userId = request.user['user_id']
    userId = "testi"

    tours = db.session.query(
        Tour.id, functions.ST_AsText(functions.ST_Buffer(functions.ST_SetSRID(Tour.polyline,25832),0.0001)), functions.ST_AsText(Tour.polyline)).filter_by(userId=userId)

    results = [
        {
            "id": id,
            "polygon": polygon,
            "polyline": polyline
        } for (id, polygon, polyline) in tours]

    return jsonify(results)