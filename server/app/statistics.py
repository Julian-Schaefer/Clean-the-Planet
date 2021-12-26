from flask import Blueprint, request, jsonify
from geoalchemy2 import functions
import logging
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
from shapely.geometry import Point, Polygon
import time

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
        reverse_locations = []

        for (_, centerPoint) in tours_query:
            reverse_location = getCenterPointReverseLocation(
                centerPoint, reverse_locations)
            if not reverse_location:
                centerPointString = centerPoint[6:-1]
                coordinates = centerPointString.split(" ")
                lat_lon = (float(coordinates[0]), float(coordinates[1]))
                reverse_location = reverse_geocode(lat_lon=lat_lon, zoom=zoom)
                if reverse_location:
                    reverse_locations.append(reverse_location)

            if reverse_location:
                if not tour_statistics.get(reverse_location.address):
                    tour_statistics[reverse_location.address] = {
                        "centerPoint":
                        "POINT(" + str(reverse_location.latitude) + " " +
                        str(reverse_location.longitude) + ")",
                        "address":
                        reverse_location.address,
                        "count":
                        1
                    }
                else:
                    tour_statistics[
                        reverse_location.address]["count"] = tour_statistics[
                            reverse_location.address]["count"] + 1

        tours = [{
            "id": "asd",
            "centerPoint": tour_statistics[key]['centerPoint'],
            "address": tour_statistics[key]['address'],
            "count": tour_statistics[key]['count'],
        } for key in tour_statistics.keys()]

        return jsonify(tours)

    return "Error", 400


def getCenterPointReverseLocation(centerPoint, reverse_locations):
    centerPointString = centerPoint[6:-1]
    coordinates = centerPointString.split(" ")
    point = Point(float(coordinates[0]), float(coordinates[1]))

    for reverse_location in reverse_locations:
        bounds = [
            float(bound) for bound in reverse_location.raw['boundingbox']
        ]
        southWest = (bounds[0], bounds[2])
        southEast = (bounds[0], bounds[3])
        northWest = (bounds[1], bounds[2])
        northEast = (bounds[1], bounds[3])
        boundingBox = Polygon(
            [southWest, southEast, northEast, northWest, southWest])
        if point.within(boundingBox):
            return reverse_location

    return None


nominatim_user_agent = "clean-the-planet"
geolocator = Nominatim(user_agent=nominatim_user_agent)


def reverse_geocode(lat_lon, zoom):
    try:
        time.sleep(1)
        location = geolocator.reverse(lat_lon,
                                      zoom=zoom,
                                      language="en",
                                      timeout=5)
        return location
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
