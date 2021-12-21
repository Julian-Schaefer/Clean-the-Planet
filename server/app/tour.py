from geoalchemy2 import Geometry
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
import uuid

from app.db import db


class Tour(db.Model):
    __tablename__ = 'tour'

    id = db.Column(UUID(as_uuid=True), primary_key=True)
    userId = db.Column(db.String())
    datetime = db.Column(db.DateTime(), default=func.now())
    duration = db.Column(db.Interval())
    amount = db.Column(db.Float())
    polyline = db.Column(Geometry('LINESTRING'))
    centerPoint = db.Column(Geometry('POINT'))
    result_picture_keys = db.Column(JSONB)
    tour_pictures = db.relationship("TourPicture", cascade="all, delete")

    def __init__(self, id, userId, polyline, centerPoint, duration, amount,
                 result_picture_keys, tour_pictures):
        self.id = id
        self.userId = userId
        self.polyline = polyline
        self.centerPoint = centerPoint
        self.duration = duration
        self.amount = amount
        self.result_picture_keys = result_picture_keys
        self.tour_pictures = tour_pictures

    def __repr__(self):
        return f"<Tour {self.id},  {self.userId}>"


class TourPicture(db.Model):
    __tablename__ = 'tour_picture'

    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tour_id = db.Column(UUID(as_uuid=True),
                        db.ForeignKey('tour.id'),
                        primary_key=True)
    location = db.Column(Geometry('POINT'))
    picture_key = db.Column(db.String())
    comment = db.Column(db.String())

    def __init__(self, tour_id, location, picture_key, comment):
        self.tour_id = tour_id
        self.location = location
        self.picture_key = picture_key
        self.comment = comment

    def __repr__(self):
        return f"<Tour-Picture {self.id},  {self.location}, {self.comment}>"
