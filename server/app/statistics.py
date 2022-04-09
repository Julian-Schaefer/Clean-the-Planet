from flask import Blueprint, request, jsonify
from geoalchemy2 import functions
import logging
import googlemaps
from shapely.geometry import Point, Polygon

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
                functions.ST_Contains(
                    functions.ST_Envelope(
                        functions.ST_SetSRID(functions.ST_GeomFromText(bounds),
                                             4326)), Tour.centerPoint))

        tour_statistics = {}
        reverse_locations = []

        for (_, centerPoint) in tours_query:
            reverse_location = getCenterPointReverseLocation(
                centerPoint, reverse_locations)
            if not reverse_location:
                reverse_location = reverse_geocode(
                    lat_lon=getLatLngFromPoint(centerPoint), zoom=zoom)
                if reverse_location:
                    reverse_locations.append(reverse_location)

            if reverse_location:
                if not tour_statistics.get(
                        reverse_location['formatted_address']):
                    tour_statistics[reverse_location['formatted_address']] = {
                        "centerPoint":
                        f'POINT({str(reverse_location["geometry"]["location"]["lat"])} {str(reverse_location["geometry"]["location"]["lng"])})',
                        "address": reverse_location['formatted_address'],
                        "count": 1
                    }
                else:
                    tour_statistics[reverse_location['formatted_address']][
                        "count"] = tour_statistics[
                            reverse_location['formatted_address']]["count"] + 1

        tours = [{
            "id": "asd",
            "centerPoint": tour_statistics[key]['centerPoint'],
            "address": tour_statistics[key]['address'],
            "count": tour_statistics[key]['count'],
        } for key in tour_statistics.keys()]

        return jsonify(tours)

    return "Error", 400


def getCenterPointReverseLocation(centerPoint, reverse_locations):
    lat_lon = getLatLngFromPoint(centerPoint)
    point = Point(lat_lon[0], lat_lon[1])

    for reverse_location in reverse_locations:
        northEastRaw = reverse_location["geometry"]["bounds"]["northeast"]
        southWestRaw = reverse_location["geometry"]["bounds"]["southwest"]

        southWest = (southWestRaw["lat"], southWestRaw["lng"])
        northEast = (northEastRaw["lat"], northEastRaw["lng"])
        southEast = (northEast[0], southWest[1])
        northWest = (southWest[0], northEast[1])
        boundingBox = Polygon(
            [southWest, southEast, northEast, northWest, southWest])
        if point.within(boundingBox):
            return reverse_location

    return None


def getLatLngFromPoint(centerPoint):
    centerPointString = centerPoint[6:-1]
    coordinates = centerPointString.split(" ")
    lat_lon = (float(coordinates[0]), float(coordinates[1]))
    return lat_lon


google_maps = googlemaps.Client(key='tbd')


def get_zoom_level(zoom):
    # 3	country
    # 5	state
    # 8	county
    # 10 city
    # 14 suburb
    # 16 major streets
    # 17 major and minor streets
    # 18 building
    if zoom == 18:
        return ["street_address"]
    elif zoom <= 17 and zoom >= 15:
        return ["route", "intersection"]
    elif zoom <= 14 and zoom >= 11:
        return ["sublocality, locality"]
    elif zoom <= 10 and zoom >= 9:
        return ["locality", "political"]
    elif zoom == 8:
        return [
            "administrative_area_level_7", "administrative_area_level_6",
            "administrative_area_level_5", "administrative_area_level_4",
            "administrative_area_level_3", "administrative_area_level_2",
            "administrative_area_level_1"
        ]
    elif zoom == 7:
        return [
            "administrative_area_level_3", "administrative_area_level_2",
            "administrative_area_level_1"
        ]
    elif zoom == 6:
        return ["administrative_area_level_2", "administrative_area_level_1"]
    elif zoom == 5:
        return ["administrative_area_level_1"]
    elif zoom <= 4:
        return ["country"]


def reverse_geocode(lat_lon, zoom, lan="de"):
    try:
        result_types = get_zoom_level(zoom)
        reverse_geocode_result = google_maps.reverse_geocode(
            lat_lon, result_type=result_types, language=lan)
        location = reverse_geocode_result[0]
        return location
    except Exception as e:
        logging.info('ERROR: Terminating due to exception {}'.format(e))
        return None
