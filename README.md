# jenkins-golang-agent
Jenkins agent for "attach" that contains golang and some other pre-reqs.

# build
`sudo docker build --tag jenkins-golang-agent .`

# helpful commands
```sh
sudo docker run -it jenkins-golang-agent /bin/bash
sudo docker rm $(sudo docker ps -a -q)
```

# publish
[build](#build) the image first!

1. list images with `docker images` find the latest id
2. tag the image with the remote `docker tag 8f6d259f8d67 tucker01/jenkins-golang-agent`
3. login to docker hub `docker login --username tucker01` (must use token)
4. push `docker push tucker01/jenkins-golang-agent`