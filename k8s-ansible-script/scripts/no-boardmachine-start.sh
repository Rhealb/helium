docker -H 127.0.0.1:2375 load -i wizard/wizard.tar
docker rm -f wizard 
docker -H 127.0.0.1:2375 run --name wizard -d -v $PWD/:/opt wizard:latest
docker -H 127.0.0.1:2375 exec -it  wizard bash
