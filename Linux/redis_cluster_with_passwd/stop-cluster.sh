#!/bin/bash

# Stop and remove containers
docker-compose down

# Remove data directories
rm -rf redis-638*/data 