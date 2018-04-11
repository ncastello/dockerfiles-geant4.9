# dockerfiles-gebic-geant4.9

Docker __context__ to create docker Geant4.9 image to run (or develop)
GEBIC (a MC simulation program developed using Geant4 which is used to
calculate detector efficiency for each measured sample). This image is based on an
ubuntu-16.04 and contains the necessary packages to run GEBIC.

GEBIC code was developed initially by Iulian Bandac (Canfranc Underground Laboratory, Spain).

## Install

Assuming `docker` and `docker-compose` is installed on your system (host-computer).

1. Clone the docker geant4.9 repository

```bash
$ git clone https://github.com/ncastello/dockerfiles-geant4.9
$ cd dockerfiles-geant4.9
```

2. To get the docker container you can either download the image from he dockerhub
   ```bash
   $ docker pull ncastello/gebic-geant4.9
   ```
   or alternatively build the docker image from the Dockerfile:

   ```bash
   # Using docker
   $ docker build github.com/ncastello/gebic-geant4.9
   # Using docker-compose within the repo directory
   $ docker-compose build gebic-geant4.9
   ```

## USAGE

The first to do is to give permissions to docker to access the X-server
```bash
$ xhost +local:docker
```

1. __As user__

    The recommended way to run GEBIC is with docker-compose

    ```bash
    $ docker-compose run --rm <service_name>
    ```

    where <service_name> can be found in the docker-compose.yml file (i.e `damicdev`). This
    will allow you to run GEBIC under a __production environment__.
    The GEBIC software is installed under the path  `/gebic` (where the code for both
    detectors, GeLatuca and GeOroel, are installed in differents folders).

    Once you are in, you can just start to work!


2. __As developer__

    However, if what you need is to develop GEBIC, i.e. to use this container in a
    __development environment__ and consequently have a link to your host-computer,
    you should then include the file __docker-compose.override.yml__ into this repository.
    This file is as follows

    ```file
    version: "3.2"
	services:
        damicdev:
            volumes:
                - type: bind
                 source: @global_path_to_your_GEBIC_source_folder
                 target: /gebic
    ```
    where @global_path_to_your_GEBIC_source_folder is __the path in the host-computer__ to
    GEBIC.

    This means the folder /gebic (in the container) is linked to global_path_to_your_GEBIC_source_folder (in the host-computer).

## Note

Note that if you have both __docker-compose.override.yml__ and __docker-compose.yml__ files, to run the container with a
__production environment__ the following command must be executed\

```bash
$ docker-compose -f docker-compose.yml run --rm damicdev
```
By default, `docker-compose` use the override yml file.


## Usefull `docker` commands

1. List containers
    ```bash
    $ docker ps
    ```

2. Deleting ...
    ```bash
    $ docker image prune
    $ docker container prune
    $ docker system prune
    $ docker network prune
    ```





