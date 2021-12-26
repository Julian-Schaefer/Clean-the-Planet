from geoalchemy2 import functions
from app.db import db
from app import create_app
from app.tour import Tour
from random import randint, uniform
from uuid import uuid4

app = create_app()


def get_centroid(geometry):
    return db.session.query(
        functions.ST_AsText(
            functions.ST_Centroid(
                functions.ST_SetSRID(functions.ST_GeomFromText(geometry),
                                     25832)))).one()[0]


with app.app_context():
    noOfTours = 200
    for _ in range(noOfTours):
        positions = []
        lastPos = (51.1657 + (uniform(-1, 1) * 15),
                   10.4515 + (uniform(-1, 1) * 15))
        positions.append(lastPos)

        for _ in range(randint(50, 1000)):
            lastPos = (lastPos[0] + (uniform(-1, 1) / 100),
                       lastPos[1] + (uniform(-1, 1) / 100))
            positions.append(lastPos)

        positionsString = list(
            map(lambda x: str(x[0]) + " " + str(x[1]), positions))
        positionsString = ', '.join(positionsString)
        polylineString = "LINESTRING(" + positionsString + ")"
        centerPoint = get_centroid(polylineString)

        tour = Tour(id=uuid4(),
                    userId="test_user",
                    polyline=polylineString,
                    centerPoint=centerPoint,
                    duration="12:44",
                    amount=13.5,
                    result_picture_keys=["asd.png"],
                    tour_pictures=[])

        db.session.add(tour)
        db.session.commit()
