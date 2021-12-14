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
def no_ST_AsText():
    with patch('geoalchemy2.functions.ST_AsText', ST_AsText_placeholder):
        yield


@pytest.fixture(autouse=True)
def no_ST_SetSRID():
    with patch('geoalchemy2.functions.ST_SetSRID', SetSRID_placeholder):
        yield


@pytest.fixture(autouse=True)
def no_ST_Buffer():
    with patch('geoalchemy2.functions.ST_Buffer', ST_Buffer_placeholder):
        yield


@pytest.fixture(autouse=True)
def no_Geometry_from_text():
    with patch('geoalchemy2.Geometry.from_text', "upper"):
        yield


@pytest.fixture(autouse=True)
def no_Geometry_as_binary():
    with patch('geoalchemy2.Geometry.as_binary', "upper"):
        yield


@pytest.fixture(autouse=True)
def no_Interval_DataType():
    with patch('sqlalchemy.sql.sqltypes.Interval.bind_processor',
               lambda *_: lambda value: value):
        yield


def ST_AsText_placeholder(column):
    return Column(column.key)


def SetSRID_placeholder(first, _):
    return first


def ST_Buffer_placeholder(geo, _):
    return geo
