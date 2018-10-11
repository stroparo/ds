

dockeraccess () {
  sudo usermod -aG docker "$USER"
}

dockercleancontainers () {
  docker stop $(docker ps -q) && docker rm $(docker ps -a -q -f status=exited)
}

dockercleanimages () {
  docker rmi $(docker images -q -f dangling=true)
}

dockercleanvolumes () {
  docker volume rm $(docker volume ls -q -f dangling=true)
}

dockerprune () {
  docker system prune -a
}
