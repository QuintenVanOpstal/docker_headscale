# Docker container for running headscale

## overview

Enables you to run Headscale inside of a docker container

## Prerequisites

- Docker

## Running the proyect

To create the proper directories and copy the config.yaml run the following command
If you want to use this as an external headscale server, you need to change the server url in the config.yaml

```bash
./build.sh
```

Next to run the server, and create an account: myfirstuser. 

```bash
./run.sh tag:sender,tag:receiver,tag:rtmp,tag:webcam,tag:stream
```

This command also creates 5 pre auth keys, that last for 720h.
Each with a different tag: sender, reciever, rtmp, webcam, stream. 
If you need more tags, you can add them by adding a , and then tag:[name of tag]

You can exit the headscale server by pressing ctrl+c, this deletes the containers.

To run them agian without creating the keys, you can run docker compose up

To delete the headscale data and start over, you can run
```bash
rm -fr headscale
```
