# jenkins-golang-agent
Jenkins agent for "attach" that contains golang and some other pre-reqs.

# build
`sudo docker build --tag jenkins-golang-agent .`

# helpful commands
```sh
sudo docker run -it jenkins-golang-agent /bin/bash
sudo docker rm $(sudo docker ps -a -q)
```