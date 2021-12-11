from app import create_app
from tests.testconfig import TestConfig
from unittest.mock import patch


def test_factory():
    with patch('app.firebase.setUpFirebase'):
        assert not create_app().testing

    assert create_app(TestConfig).testing


def test__no_token(client):
    response = client.get('/tour')
    assert response.data == b'{"message":"No Token provided."}\n'


def test_token(client):
    response = client.get('/tour', headers={"Authorization": "Bearer test"})
    assert response.data == b'[]\n'