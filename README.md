# container-logs

[![Build Status](https://drone.cryptic.systems/api/badges/volker.raschek/container-logs/status.svg)](https://drone.cryptic.systems/volker.raschek/container-logs)
[![PkgGoDev](https://pkg.go.dev/badge/git.cryptic.systems/volker.raschek/container-logs)](https://pkg.go.dev/git.cryptic.systems/volker.raschek/container-logs)

container-log is a utility program. It writes the logs from docker container to
stdout. The containers can be specified by ame or ID like the `docker logs`
command. In addition, `container-logs` offers the possibility to search for
containers by their labels.

## Usage

The following chapter contains examples how to use `container-logs`.

All examples are about an nginx and oracle container. The nginx container has
the name `nginx` and the id `59a6358197ef`. The oracle container has the name
`oracle` and the id `9d0bb88fa6a1`

### Logs without any restrictions

When container-logs is run without restriction, the logs that write the
containers to stdout and stderr are printed on standard system output.

```bash
$ container-logs
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:16 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:56 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:58:37 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
...
SQL*Plus: Release 11.2.0.2.0 Production on Fri Nov 20 14:56:25 2020
Copyright (c) 1982, 2011, Oracle.  All rights reserved.
Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
```

### Logs by container name

Containers whose logs write to standard output and standard error output can
also be selected by name.

In the following example only the logs of the container nginx are output. The
container is selected by its name.

```bash
$ container-logs --name nginx
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:16 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:56 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:58:37 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
...
```

The flag `--n, --name` can be used multiple times to select multiple containers.

### Logs by container id

The behaviour of `-i, --id` is similar to `-n, --name`. It can be specified
multiple times. It selects the container by thir ID instead of their name. The
ID does not need to be specified by their full length. The first characters of
the ID are sufficient.

For example to select the container oracle.

```bash
$ container-logs --id 9d0bb88fa6a1
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:16 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:56 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:58:37 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
```

### Logs by container labels

Outputting the logs of containers, selected by their labels, is the real reason
for implementing this little program. Containers are only selected if all
labels, which were passed, are also defined in the container image.

In the following example the container nginx is selected by one of its labels.

```bash
$ container-logs --label "maintainer=NGINX Docker Maintainers <docker-maint@nginx.com>"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:16 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:57:56 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
[0.000] 127.0.0.1 - - [20/Nov/2020:18:58:37 +0000] "HEAD /index.html HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
```

To find the labels of a container, you can use the inspect sub-command of
docker. Here is an example:

```bash
$ docker inspect nginx:alpine
...
 "Labels": {
    "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
  },
...
```
