---
layout: "default"
date: 2016-01-30
hasCode: true
---

## Quick Intro to Dockerfile

For a while I was using VirtualBox/Vagrant for development projects. More
recently I’ve moved to using Docker. I use Linux (lubuntu) on my dev computer
anyways, so it was an easy transition and the resource consumption is
significantly lower. I haven’t tried Docker in a Windows or Mac environment, so
I can’t speak to the performance or resource consumption on those platforms.

Docker is actually pretty straightforward to use. The one thing that I got hung
up on was the Dockerfile. It’s not very complex, but you do need to know what
you’re doing.

I’m working on a Meteor project right now, so I wanted to create a new
Dockerfile to make future projects quick to spin up. I’ll walk through each part
of the Dockerfile and explain what’s going on. Bolded lines are the commands in
the Dockerfile and the following text explains what the command is doing.

There is a [Github repo](https://github.com/techspringllc/docker-meteor) and a
[Docker Hub](https://hub.docker.com/r/techspring/meteor-dev/) page for this
Docker image.

```Dockerfile
FROM ubuntu
```

For this project I want to use the latest ubuntu base image. If I wanted to use
a specific version, like 14.04, I would use the command “FROM ubuntu:14.04”. You
can use any image from [Docker Hub](https://hub.docker.com/explore/) as your
base.

```Dockerfile
MAINTAINER Bill Broughton <email redacted>
```

The MAINTAINER command isn’t strictly necessary, but if you are going to publish
your image to Docker Hub it should be in your file. This just identifies who is
maintaining the image.

```Dockerfile
RUN <shell command>
```

RUN allows you to execute shell commands during the image creation. This is most
frequently used for ‘apt-get install’ commands, but it can be used for other
shell commands also.

My Dockerfile has three RUN commands.

```Dockerfile
# Fix MongoDB locale issue
RUN locale-gen en_US.UTF-8

# Update apt and install git, curl, python, and latest node
RUN apt-get update && apt-get install -y \
  git \
  curl \
  python \
  && (curl https://deb.nodesource.com/setup | sh) \
  && apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Meteor
RUN curl https://install.meteor.com/ |sh
```

The first RUN command sets the locale in Ubuntu. This is necessary because
MongoDB won’t work without having a locale set. The next RUN command installs
git, curl, python, and nodejs. It then clears the apt-cache and deletes the
contents of the apt lists directory. These steps are part of Docker’s best
practices and helps to keep image size down. Finally, the last RUN command
installs [Meteor](https://www.meteor.com/install) per the directions on their
site.

```Dockerfile
EXPOSE 3000
```

The default port that Meteor runs on in development is 3000, this command lets
the container know to watch for connections to port 3000.

```Dockerfile
VOLUME [“/app”]
```

VOLUME exposes directories to the container. Generally, you will want to expose
any directories that are intended to be user-serviceable.

```Dockerfile
WORKDIR /app
```

This sets the working directory to the volume that was exposed in the previous
command. When you enter the interactive shell of the container, you will be
located in /app.

```Dockerfile
CMD [“/bin/bash”]
```

The CMD command can be used to execute shell scripts in the container. In a
production application, this would be used to start the application with the
container. In a development environment, users of the image probably want to go
to the interactive shell. When the container is started with the ‘-it’ flag,
they will be taken to an interactive shell.

### How to use it

To build an image from the Dockerfile, run the following command from the
directory containing the Dockerfile:

```bash
docker build -t <image-name> .
```

The ‘-t’ flag allows you to give the image an easy to remember name rather than
a hash. The period at the end references the current working directory. You can
also build an image not in your current working directory by specifying a full
path instead.

To start the image in a new container, link the /app directory in the container
to your current working directory on your host, and start an interactive shell,
use this:
```bash
docker run -it --name <container-name> -v "$(pwd)":/app <image-name>
```
