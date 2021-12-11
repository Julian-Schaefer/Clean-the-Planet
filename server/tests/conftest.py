import pytest
from tests.testconfig import TestConfig
from app import create_app
from app import db


@pytest.fixture
def app():
    app = create_app(TestConfig)

    with app.app_context():
        db.init_app(app)

    yield app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()