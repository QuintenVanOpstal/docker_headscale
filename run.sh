#! /bin/bash
# Function to clean up containers
cleanup() {
  echo "Caught Ctrl+C! Stopping containers..."
  docker compose down
  exit 1
}

# Trap SIGINT (Ctrl+C) and call cleanup()
trap cleanup SIGINT


docker compose up -d


until [ "`docker inspect -f {{.State.Running}} headscale`"=="true" ]; do
    sleep 0.1;
done;


if ! docker exec headscale headscale users list | grep -q '1'; then
    docker exec headscale headscale users create myfirstuser
fi

IFS=',' read -r -a array <<< "$1"

for i in "${array[@]}"
do
    echo "Autnetication Key machine $i"
    docker exec headscale headscale preauthkeys create --user 1 \
        --reusable \
        --output json \
        --expiration 720h \
        --tags $i
done

tail -f /dev/null
