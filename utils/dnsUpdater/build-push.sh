TAG=$1
echo TAG: $TAG
docker build -t registry.gitlab.com/nullxx/dns-updater:$TAG .
docker push registry.gitlab.com/nullxx/dns-updater:$TAG
