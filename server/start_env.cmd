docker rm -f localstack
docker rm -f planet-postgis


docker run --rm -it -e SERVICES=s3 -d -p 4566:4566 -p 4571:4571 --name localstack localstack/localstack

docker run --rm -it -d -p 5433:5432 --name planet-postgis -e POSTGRES_PASSWORD=planetpassword postgis/postgis

timeout 10

pipenv run flask db upgrade

docker run --rm -it --link localstack amazon/aws-cli --no-sign-request --endpoint-url=http://localstack:4566/ s3 mb s3://clean-the-planet