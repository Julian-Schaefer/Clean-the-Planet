class TestConfig:
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    def get_token_verifier():
        class MockTokenVerifier:
            def verify(self, _):
                return {"user_id": "testuser"}

        return MockTokenVerifier()
