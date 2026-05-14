#!/bin/sh

if [ -n "$REDIS_PASSWORD" ]; then
    echo "Starting Redis with password authentication"
    redis-server /usr/local/etc/redis/redis.conf --requirepass "$REDIS_PASSWORD"
else
    echo "Starting Redis without password"
    redis-server /usr/local/etc/redis/redis.conf
fi