from flask import Blueprint, request, jsonify
from geoalchemy2 import functions
import logging
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError

from app.db import db
from app.tour import Tour

bp = Blueprint('statistics', __name__)


@bp.route("/statistics", methods=["GET"])
def getStatistics():
    bounds = request.args.get("bounds")
    zoom = int(request.args.get("zoom"))

    if bounds and zoom:
        tours_query = db.session.query(
            Tour.id, functions.ST_AsText(Tour.centerPoint)).filter(
                functions.ST_Contains(functions.ST_Envelope(bounds),
                                      Tour.centerPoint))

        tour_statistics = {}

        for (_, centerPoint) in tours_query:
            centerPointString = centerPoint[6:-1]
            coordinates = centerPointString.split(" ")
            lat_lon = (float(coordinates[0]), float(coordinates[1]))
            reverse_location = reverse_geocode(lat_lon=lat_lon, zoom=zoom)

            if not tour_statistics.get(reverse_location.address):
                tour_statistics[reverse_location.address] = {
                    "latitude": reverse_location.latitude,
                    "longitude": reverse_location.longitude,
                    "count": 1
                }
            else:
                tour_statistics[reverse_location.address] = tour_statistics[
                    reverse_location.address]["count"] + 1

            print(tour_statistics)

        tour_statistics = jsonify(tour_statistics)

        tours = [{
            "id": id,
            "centerPoint": centerPoint
        } for (id, centerPoint) in tours_query]

        return jsonify(tours)

    return "Error", 400


nominatim_user_agent = "clean-the-planet"
geolocator = Nominatim(user_agent=nominatim_user_agent)


def reverse_geocode(lat_lon, zoom):
    try:
        return geolocator.reverse(lat_lon, zoom=zoom, language="en")
    except GeocoderTimedOut:
        logging.info('TIMED OUT: GeocoderTimedOut: Retrying...')
        return None
    except GeocoderServiceError as e:
        logging.info('CONNECTION REFUSED: GeocoderServiceError encountered.')
        logging.error(e)
        return None
    except Exception as e:
        logging.info('ERROR: Terminating due to exception {}'.format(e))
        return None
