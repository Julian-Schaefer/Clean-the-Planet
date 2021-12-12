import os
from io import StringIO
import json
import firebase_admin
from firebase_admin import credentials, auth


# Connect to Firebase
def setUpFirebase():
    serviceAccountJson = os.environ.get("SERVICE_ACCOUNT_JSON", None)
    if serviceAccountJson:
        serviceAccount = json.load(StringIO(serviceAccountJson))
        cred = credentials.Certificate(serviceAccount)
    else:
        cred = credentials.Certificate(os.environ.get("CERTIFICATE_PATH",
                                                      None))
    firebase_admin.initialize_app(cred)


class FirebaseTokenVerifier:
    def verify(self, token):
        return auth.verify_id_token(token)
