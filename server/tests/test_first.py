# Third party modules
import pytest

from app import create_app


@pytest.fixture
def client():
    app = create_app()

    app.config["TESTING"] = True
    app.testing = True

    # This creates an in-memory sqlite db
    # See https://martin-thoma.com/sql-connection-strings/
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite://"

    client = app.test_client()
    #with app.app_context():
    # db.create_all()
    # author1 = Author(id=1, first_name="foo", last_name="bar")
    # db.session.add(author1)
    # db.session.commit()
    yield client


def test_empty_db(client):
    """Start with a blank database."""

    rv = client.get('/')
    assert b'No entries here so far' in rv.data