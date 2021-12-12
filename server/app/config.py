from app.firebase import FirebaseTokenVerifier


class Config:
    TESTING = False
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:planetpassword@localhost:5433/postgres"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    def get_token_verifier():
        return FirebaseTokenVerifier()
