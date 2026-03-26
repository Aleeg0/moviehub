#!/bin/sh

echo "Waiting for postgres..."
while ! nc -z postgres 5432; do
  sleep 0.1
done
echo "PostgreSQL started"

echo "Running alembic migrations..."
alembic upgrade head

echo "Starting uvicorn server..."
exec uvicorn main:app --host 0.0.0.0 --port ${MOVIEHUB_CORE:-8000} --http h11 --reload