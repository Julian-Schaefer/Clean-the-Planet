from app.db import db
from app import create_app
from app.tour import Tour
from random import randint, random
from uuid import uuid4

app = create_app()

with app.app_context():
    noOfTours = 200
    for _ in range(100):
        positions = []
        lastPos = (51.1657 + (random() * 15), 10.4515 + (random() * 15))
        positions.append(lastPos)

        for _ in range(randint(50, 1000)):
            lastPos = (lastPos[0] + (random() / 100),
                       lastPos[1] + (random() / 100))
            positions.append(lastPos)

        positionsString = list(
            map(lambda x: str(x[0]) + " " + str(x[1]), positions))
        positionsString = ', '.join(positionsString)
        polylineString = "LINESTRING(" + positionsString + ")"

        tour = Tour(id=uuid4(),
                    userId="test_user",
                    polyline=polylineString,
                    duration="12:44",
                    amount=13.5,
                    result_picture_keys=["asd.png"],
                    tour_pictures=[])

        db.session.add(tour)
        db.session.commit()
