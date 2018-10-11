

dockeraccess () {
  sudo usermod -aG docker "$USER"
}

dockercleancontainers () {
  docker stop $(docker ps -q) && docker rm $(docker ps -a -q -f status=exited --no-trunc)
}

dockercleanimages () {
  docker rmi $(docker images -q -f dangling=true --no-trunc)
}

dockercleanimagesnone () {
  docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
}

dockercleannetworks () {
  docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
}

dockercleanvolumes () {
  docker volume rm $(docker volume ls -q -f dangling=true)
}

dockerprune () {
  docker system prune -a
}
