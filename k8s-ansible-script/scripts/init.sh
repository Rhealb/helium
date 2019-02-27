echo "Load installer image to docker"
docker load -i wizard.tar
echo "Done"
echo "Start installer backend"
docker run -d -p 8080:8080 -v "${PWD}/../":/project/deployment/ wizard:latest
echo "Done"
echo "Start installer frontend"
docker run -d -p 8081:80 wizard-front:latest
echo "Done"
