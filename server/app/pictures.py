from flask import Blueprint, request, jsonify
import logging
from botocore.exceptions import ClientError
import pathlib
import uuid
import json

from app.storage import s3_client, s3_resource, BUCKET

bp = Blueprint('pictures', __name__)


@bp.route("/result-pictures", methods=["POST"])
def upload_result_pictures():
    files = request.files.getlist("files")

    picture_keys = []
    for file in files:
        try:
            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(BUCKET, file_name).put(Body=file_content)
            picture_keys.append(file_name)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_keys) > 0:
        return {"picture_keys": picture_keys}

    return "Error", 400


@bp.route("/tour-pictures", methods=["POST"])
def upload_tour_pictures():
    files = request.files.getlist("files")

    picture_json = []
    for file in files:
        try:
            file_json = json.loads(request.form[file.filename])

            file_content = file.read()
            file_name = str(uuid.uuid4()) + pathlib.Path(file.filename).suffix
            s3_resource.Object(BUCKET, file_name).put(Body=file_content)

            file_json['pictureKey'] = file_name
            picture_json.append(file_json)
        except ClientError as e:
            logging.error(e)
            return "Error", 400

    if len(picture_json) > 0:
        return jsonify(picture_json)

    return "Error", 400


@bp.route("/picture", methods=["GET"])
def get_picture_by_key():
    picture_key = request.args['key']
    picture_Url = get_url_from_picture_key(picture_key)

    return {"url": picture_Url}


def get_urls_from_picture_keys(picture_keys):
    if not picture_keys:
        return

    pictures = []
    for picture_key in picture_keys:
        pictures.append(get_url_from_picture_key(picture_key))
    return pictures


def get_url_from_picture_key(picture_key):
    return s3_client.generate_presigned_url('get_object',
                                            Params={
                                                'Bucket': BUCKET,
                                                'Key': picture_key
                                            },
                                            ExpiresIn=60)
