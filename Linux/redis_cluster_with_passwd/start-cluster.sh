#!/bin/bash

# Start the containers
docker-compose up -d

# Wait for containers to be ready
sleep 5

# Create the cluster with password authentication
docker exec -it redis-6381 redis-cli -a 123456 --cluster create \
  172.30.0.2:6381 \
  172.30.0.3:6382 \
  172.30.0.4:6383 \
  172.30.0.5:6384 \
  172.30.0.6:6385 \
  172.30.0.7:6386 \
  --cluster-replicas 1 --cluster-yes

# Check cluster status
echo "Checking cluster status..."
sleep 2
docker exec -it redis-6381 redis-cli -a 123456 cluster info 