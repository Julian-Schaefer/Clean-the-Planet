from database import db
from geoalchemy2 import Geometry
from sqlalchemy.dialects.postgresql import UUID
import uuid

class Tour(db.Model):
    __tablename__ = 'tour'


    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    userId = db.Column(db.String())
    polyline = db.Column(Geometry('LINESTRING'))

    def __init__(self, userId, polyline):
        self.userId = userId
        self.polyline = polyline

    def __repr__(self):
        return f"<Tour {self.id},  {self.userId}>"
