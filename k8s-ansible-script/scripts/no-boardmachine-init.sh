echo "Load installer image to docker"
docker -H 127.0.0.1:2375 load -i wizard.tar
echo "Done"
echo "Start installer backend"
docker -H 127.0.0.1:2375 run -d -p 8080:8080 -v "${PWD}/../":/project/deployment/ wizard:latest
echo "Done"
echo "Start installer frontend"
docker -H 127.0.0.1:2375 run -d -p 8081:80 wizard-front:latest
echo "Done"
