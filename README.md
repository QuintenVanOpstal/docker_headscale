# Docker container for running headscale

## overview

Enables you to run Headscale inside of a docker container, also generates a certificate to enable https://

## Prerequisites

- Docker

## Running the project

To create the proper directories and copy the config.yaml run the following command
If you want to use this as an external headscale server, you need to change the server url in the config.yaml
It also generates and adds certs so clients ronning on the same machine can safely connect to the headscale server via UDP
Certs are not generated if they already exist. To connect from a different device, you should trust the ca.crt en the cert file. 
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
