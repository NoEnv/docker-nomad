## docker-nomad

#### Description

Nomad Agent as Docker Image.

#### Run

most simple way of running the container

    docker run --rm noenv/nomad

advanced usage

    docker run --name nomad --net=host --privileged -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock -v ~/.nomad:/nomad noenv/nomad agent -config=/nomad/config

example config (~/.nomad/config/server.hcl)
```
data_dir   = "/nomad/data"
server {
  enabled          = true
  bootstrap_expect = 1
}
client {
  enabled = true
  node_class = "controller"
  options {
    "driver.whitelist" = "docker",
    "docker.auth.config" = "/nomad/.docker/config.json"
  }
}
consul {
  address = "172.17.0.1:8500"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
```          

#### Source

https://github.com/noenv/docker-nomad
