# dockerfiles-geant4.9

Docker image to run Geant4.9. Creates the environment to run (or develop)
GEBIC (a MC simulation program developed using Geant4 which is used to
calculate detector efficiency for each measured sample). This image is based on an
ubuntu-16.04 and contains the necessary packages to run GEDIS.

### Installation

Assuming `docker` and `docker-compose` is installed on your system (host-computer).

Clone the docker geant4.9 repository and configure it
```bash
$ git clone https://github.com/ncastello/dockerfiles-geant4.9
$ cd dockerfiles-geant4.9
```

Note that a geant4.9 reposity assume a Linux user named `ncastello` with ID `1000`.
This is just my local user name in my host-computer and should be replaced by your
user name and its ID number.




Remember to give permissions to docker to access the X-server
```bash
$ xhost +local:docker
```
