from marshmallow import Schema, fields, ValidationError, post_load
import json
from geoalchemy2 import functions

from app.tour import Tour, TourPicture


def geom_from_geo_json(geo_json):
    return functions.ST_SetSRID(functions.ST_GeomFromGeoJSON(geo_json), 4326)


class Duration(fields.Field):
    """Field that serializes to a string of numbers and deserializes
    to a list of numbers.
    """
    def _serialize(self, value, attr, obj, **kwargs):
        if value is None:
            return None
        return str(value)

    def _deserialize(self, value, attr, data, **kwargs):
        return value
        if value is None:
            return None
        try:
            return [int(c) for c in value]
        except ValueError as error:
            raise ValidationError(
                "Pin codes must contain only digits.") from error


class GeoJSON(fields.Field):
    """Field that serializes to a string of numbers and deserializes
    to a list of numbers.
    """
    def _serialize(self, value, attr, obj, **kwargs):
        if value is None:
            return None

        parsed_json = json.loads(value)
        return parsed_json

    def _deserialize(self, value, attr, data, **kwargs):
        if value is None:
            return None

        dumped_json = json.dumps(value)
        return geom_from_geo_json(dumped_json)


class TourPictureSchema(Schema):
    id = fields.UUID(dump_only=True)
    location = GeoJSON()
    picture_key = fields.String(data_key="pictureKey")
    comment = fields.String(allow_none=True)

    @post_load
    def make_tour_picture(self, data, **_):
        return TourPicture(id=None, tour_id=self.context["tourId"], **data)


class TourSchema(Schema):
    id = fields.UUID(dump_only=True)
    userId = fields.UUID(dump_only=True, allow_none=True, missing=None)
    datetime = fields.DateTime('%Y-%m-%dT%H:%M:%S.%f')
    duration = Duration()
    amount = fields.Float()
    polyline = GeoJSON()
    polygon = GeoJSON(dump_only=True)
    centerPoint = GeoJSON(dump_only=True)
    result_picture_keys = fields.List(fields.String(),
                                      data_key="resultPictureKeys",
                                      required=True)
    tour_pictures = fields.List(fields.Nested(TourPictureSchema),
                                data_key="tourPictures",
                                required=True)

    @post_load
    def make_tour(self, data, **_):
        return Tour(id=self.context["tourId"],
                    userId=self.context['userId'],
                    centerPoint=None,
                    **data)
