docker load -i wizard/wizard.tar
docker rm -f wizard 
docker run --name wizard -d -v $PWD/:/opt wizard:latest
CONTAINERID=`docker ps  | grep wizard:latest | awk '{print $1}'`
docker exec -it  $CONTAINERID bash
