from utils import db
from geoalchemy2 import Geometry
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid


class Tour(db.Model):
    __tablename__ = 'tour'

    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    userId = db.Column(db.String())
    polyline = db.Column(Geometry('LINESTRING'))
    result_picture_keys = db.Column(JSONB)

    def __init__(self, userId, polyline, result_picture_keys):
        self.userId = userId
        self.polyline = polyline
        self.result_picture_keys = result_picture_keys

    def __repr__(self):
        return f"<Tour {self.id},  {self.userId}>"
