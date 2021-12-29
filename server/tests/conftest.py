import json
import pytest
from sqlalchemy import Column
from tests.testconfig import TestConfig
from app import create_app
from app import db
from unittest.mock import patch


@pytest.fixture
def app():
    app = create_app(TestConfig)

    with app.app_context():
        db.init_app(app)

        with open('./tests/schema.sql', encoding="utf-8") as f:
            engine = db.db.get_engine()
            engine.raw_connection().executescript(f.read())

    yield app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()


@pytest.fixture(autouse=True)
def no_ST_SetSRID():
    with patch('geoalchemy2.functions.ST_SetSRID', SetSRID_placeholder):
        yield


def SetSRID_placeholder(first, _):
    return first


@pytest.fixture(autouse=True)
def no_ST_Buffer():
    with patch('geoalchemy2.functions.ST_Buffer', ST_Buffer_placeholder):
        yield


def ST_Buffer_placeholder(geo, _):
    return geo


@pytest.fixture(autouse=True)
def no_get_centroid():
    with patch('app.routes.get_centroid', get_centroid_placeholder):
        yield


def get_centroid_placeholder(geo):
    return json.dumps(json.loads(geo))


@pytest.fixture(autouse=True)
def no_ST_GeomFromGeoJSON():
    with patch('geoalchemy2.functions.ST_GeomFromGeoJSON',
               ST_GeomFromGeoJSON_placeholder):
        yield


def ST_GeomFromGeoJSON_placeholder(geo):
    return geo


@pytest.fixture(autouse=True)
def no_ST_AsGeoJSON():
    with patch('geoalchemy2.functions.ST_AsGeoJSON', ST_AsGeoJSON_placeholder):
        yield


def ST_AsGeoJSON_placeholder(column):
    return Column(column.key)


@pytest.fixture(autouse=True)
def no_Geometry_from_text():
    with patch('geoalchemy2.Geometry.from_text', "TRIM"):
        yield


@pytest.fixture(autouse=True)
def no_Geometry_as_binary():
    with patch('geoalchemy2.Geometry.as_binary', "TRIM"):
        yield


@pytest.fixture(autouse=True)
def no_Interval_DataType():
    with patch('sqlalchemy.sql.sqltypes.Interval.bind_processor',
               lambda *_: lambda value: value):
        yield
