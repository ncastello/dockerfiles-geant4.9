# dockerfiles-geant4.9

Docker image to run Geant4.9. Creates the environment to run (or develop)
GEBIC (a MC simulation program developed using Geant4 which is used to
calculate detector efficiency for each measured sample). This image is based on an
ubuntu-16.04 and contains the necessary packages to run GEDIS.

## Install

Assuming `docker` and `docker-compose` is installed on your system (host-computer).

1. Clone the docker geant4.9 repository

```bash
$ git clone https://github.com/ncastello/dockerfiles-geant4.9
$ cd dockerfiles-geant4.9
```

2. The repository assumes a Linux user name called `ncastello` with an ID
number `1000` (hard coded!). This is just my user name in my host-computer.
Once you have cloned the repository, these hard coded information must be
replaced by your user name and its ID number.  In order to do that, just go
into the files

    `Dockerfile` and `docker-compose.yml`

    and replace

    `ncastello` by `your_linux_username` and,

    `1000` by `your_ID_namber`.


3. Create the docker image in your host-computer. Under `dockerfiles-geant4.9`
   folder run

```bash
$ docker-compose build
```

that process will take a few minutes.

4. Some additional instructions to check docker images and containers

```bash
$ docker
```

## RUN
1. The first to do is to give permissions to docker to access the X-server
```bash
$ xhost +local:docker
```

2. The recommended way to launch all needed services is with `docker-compose`.
```bash
docker-compose
```


