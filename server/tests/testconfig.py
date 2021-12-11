class TestConfig:
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    def get_token_verifier():
        class MockTokenVerifier:
            def verify(self, token):
                return {"user_id": "testuser_" + token}

        return MockTokenVerifier()