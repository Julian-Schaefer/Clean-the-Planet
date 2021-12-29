import json
from unittest.mock import patch
import uuid
from datetime import datetime, timedelta
from random import randint


def add_tour(client, id):
    body = {
        "polyline": {
            "type": "LineString",
            "coordinates": [[102.0, 0.0], [103.0, 1.0], [104.0, 0.0],
                            [105.0, 1.0]]
        },
        "duration":
        str(datetime.now() + timedelta(minutes=33, seconds=45)),
        "amount":
        5.5,
        "resultPictureKeys": ["1", "2", "3"],
        "tourPictures": [{
            "location": {
                "type": "Point",
                "coordinates": [105.742, 21.43]
            },
            "pictureKey": "key1",
            "comment": None
        }, {
            "location": {
                "type": "Point",
                "coordinates": [-20.123, -10.63]
            },
            "pictureKey": "key2",
            "comment": "Test-Comment"
        }]
    }

    with patch('uuid.uuid4', lambda: id):
        return client.post('/tour',
                           headers={"Authorization": "Bearer test"},
                           data=json.dumps(body),
                           content_type='application/json')


def test_add_tour(client):
    id = uuid.uuid4()
    response = add_tour(client, id)
    assert response.status_code == 200
    assert response.data == f'{{"message":"Tour {id} for User testuser has been created successfully."}}\n'.encode(
        encoding="utf-8")


def test_add_tour_fail_same_id(client):
    id = uuid.uuid4()
    response = add_tour(client, id)
    assert response.status_code == 200

    response = add_tour(client, id)
    assert response.status_code == 400


def test_get_empty_tours(client):
    response = client.get('/tour', headers={"Authorization": "Bearer test"})
    assert response.status_code == 200
    assert response.is_json
    assert response.data == b'[]\n'


def test_get_one_tour(client):
    id = uuid.uuid4()
    response = add_tour(client, id)
    assert response.status_code == 200

    response = client.get('/tour', headers={"Authorization": "Bearer test"})

    assert response.is_json
    data = response.get_json()
    assert len(data) == 1

    tour = data[0]
    assert len(tour) == 9
    assert tour['id'] == str(id)
    assert tour['polyline'] == {
        "type": "LineString",
        "coordinates": [[102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]]
    }
    assert tour['centerPoint'] == {
        "type": "LineString",
        "coordinates": [[102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]]
    }
    assert tour['polygon'] == {
        "type": "LineString",
        "coordinates": [[102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]]
    }
    assert tour['duration'] is not None
    assert tour['amount'] == 5.5
    assert tour['resultPictureKeys'] == ["1", "2", "3"]

    assert len(tour['tourPictures']) == 2
    firstTourPicture = tour['tourPictures'][0]
    assert len(firstTourPicture) == 4
    assert firstTourPicture['id'] is not None
    assert firstTourPicture['location'] == {
        "type": "Point",
        "coordinates": [105.742, 21.43]
    }
    assert firstTourPicture['pictureKey'] == 'key1'
    assert firstTourPicture['comment'] is None

    secondTourPicture = tour['tourPictures'][1]
    assert len(secondTourPicture) == 4
    assert secondTourPicture['id'] is not None
    assert secondTourPicture['location'] == {
        "type": "Point",
        "coordinates": [-20.123, -10.63]
    }
    assert secondTourPicture['pictureKey'] == 'key2'
    assert secondTourPicture['comment'] == 'Test-Comment'


def test_get_mulitple_tours(client):
    numberOfTours = randint(2, 10)
    for _ in range(numberOfTours):
        response = add_tour(client, uuid.uuid4())
        assert response.status_code == 200

    response = client.get('/tour', headers={"Authorization": "Bearer test"})

    assert response.status_code == 200
    assert response.is_json
    data = response.get_json()
    assert len(data) == numberOfTours
