#Default compose args
COMPOSE_ARGS="-f docker-compose.yml -p jenkins"

#Make sure old containers are gone
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

#build the system
echo "build"
sudo docker-compose $COMPOSE_ARGS build --no-cache

#unit Test
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=TEST live_monitor
ERR=$?

if [ $ERR -eq 0 ]; then

    #Rename
    echo "rename"
    HASH=$(git rev-parse --short HEAD)
    sudo docker tag jenkins_live_monitor localhost:5000/live_monitor:$HASH
    sudo docker tag jenkins_live_monitor localhost:5000/live_monitor:latest

    #Pushing
    echo "Pushing"
    sudo docker push localhost:5000/live_monitor:$HASH
    sudo docker push localhost:5000/live_monitor:latest

    #Delete Images
    echo "Delete Images"
    sudo docker rmi localhost:5000/live_monitor:$HASH
    sudo docker rmi localhost:5000/live_monitor:latest
else
    echo "error"
    ERR=1
fi

#Pull down the system
echo "Pull down the system"
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm  --force -v

sudo docker rmi jenkins_live_monitor --force

return $ERR
