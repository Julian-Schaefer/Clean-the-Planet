from app import create_app
from tests.testconfig import TestConfig


def test_config():
    assert not create_app().testing
    assert create_app(TestConfig).testing


def test_token(client):
    response = client.get('/tour')
    assert response.data == b'{"message":"No Token provided."}\n'