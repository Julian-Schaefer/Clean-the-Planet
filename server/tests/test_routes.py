import json
from unittest.mock import patch
import uuid
from datetime import datetime, timedelta


def test_add_tour(client):
    body = {
        "polyline":
        'POLYLINE(1 1)',
        "duration":
        str(datetime.now() + timedelta(minutes=33, seconds=45)),
        "amount":
        5.5,
        "resultPictureKeys": ["1", "2", "3"],
        "tourPictures": [{
            "location": "POINT(1 1)",
            "pictureKey": "key1",
            "comment": None
        }, {
            "location": "POINT(2 2)",
            "pictureKey": "key2",
            "comment": "Test-Comment"
        }]
    }

    id = uuid.uuid4()
    with patch('uuid.uuid4', lambda: id):
        response = client.post('/tour',
                               headers={"Authorization": "Bearer test"},
                               data=json.dumps(body),
                               content_type='application/json')
        assert response.data == f'{{"message":"Tour {id} for User testuser has been created successfully."}}\n'.encode(
            encoding="utf-8")


def test_empty_tours(client):
    response = client.get('/tour', headers={"Authorization": "Bearer test"})
    assert response.data == b'[]\n'
