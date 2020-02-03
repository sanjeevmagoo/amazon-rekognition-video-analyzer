Create a Serverless Pipeline for Video Frame Analysis and Alerting
========

## Introduction
This example builds on the prototype created by [@moanany](https://github.com/moanany), https://github.com/aws-samples/amazon-rekognition-video-analyzer.

Imagine being able to capture live video streams, identify objects using deep learning, and then trigger actions or notifications based on the identified objects -- all with low latency and without a single server to manage.

This is exactly what the project created by [@moanany](https://github.com/moanany) does. It has been extended to check also check the largest face in the video frame with a Rekognition collection that the application administrator can teach to learn specific faces.

You will be able to build the video analysis solution, teach it to learn faces and check the results of the analysis.

The prototype was conceived to address a specific use case, which is alerting based on a live video feed from an IP security camera. At a high level, the solution works as follows. The user creates a collection and index of faces they want to match. A camera surveils a particular area, streaming video over the network to a video capture client. The client samples video frames and sends them over to AWS, where they are analyzed and stored along with metadata. If certain objects or faces from the user created collection are detected in the analyzed video frames, SMS alerts are sent out. Once a person receives an SMS alert, they will likely want to know what caused it. For that, sampled video frames can be monitored with low latency using a web-based user interface.

Here's the prototype's conceptual architecture:

![Architecture](https://moanany-share.s3.amazonaws.com/serverless_pipeline_arch_2.png?AWSAccessKeyId=AKIAJZICANBOQ5ADZ7YQ&Expires=1532717705&Signature=z1MT0CWAPhDjc9YI5wx25WqlVLQ%3D)

Let's go through the steps necessary to get this prototype up and running. Please note that a lot of the detailed information describing the setup is avaialble in the original project and it is worth reading through the readme to understand the solution better.

## Preparing your development environment
Here’s a high-level checklist of what you need to do to setup your development environment.

1. Sign up for an AWS account if you haven't already and create an Administrator User. The steps are published [here](http://docs.aws.amazon.com/lambda/latest/dg/setting-up.html).

2. Ensure that you have docker install on machine.

3. Make sure you choose a region where all of the above services are available. Regions us-east-1 (N. Virginia), us-west-2 (Oregon), and eu-west-1 (Ireland) fulfill this criterion. Visit [this page](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) to learn more about service availability in AWS regions.

9. Use docker to pull down the container that contains all the pre-reqs required to deploy the solution.

```bash
docker run -p 8080:8080 -ti charliejllewellyn/rekognition-demo
```

10. Setup your AWS account by running

```bash
aws configure
``` 

11. Finally, obtain an IP camera capable of output MJEPG connected and accessful from the machine running the docker container.

# Building the prototype

## Overview
Common interactions with the project have been simplified for you. Using pynt, the following tasks are automated with simple commands: 

- Packaging lambda code into .zip files and deploying them into an Amazon S3 bucket
- Creating, deleting, and updating the AWS infrastructure stack with AWS CloudFormation
- Creating a Rekognition index of faces you wish to match.
- Running the video capture client to stream from a built-in laptop webcam or a USB camera
- Running the video capture client to stream from an IP camera (MJPEG stream)
- Build a simple web user interface (Web UI)
- Run a lightweight local HTTP server to serve Web UI for development and demo purposes

*Note:* All these tasks assume you are running them from the docker image deployed during the pre-req setup. 

## Implementation Steps

### Package lambda
The following commands package the lambda functions, create an S3 bucket to store them and push upload them to the new bucket.

```bash
cd amazon-rekognition-video-analyzer/
pynt packagelambda
pynt deploylambda
```

### Create the stack
The following command will deploy the described architecture via CloudFormations.

```
pynt createstack
```

### Create a Rekognition index
*Note:* you need to find the name of the watchlist bucket created during the stack location, you can find it via the [AWS S3 console](https://s3.console.aws.amazon.com/s3/home). It'll be named "rek-demo-watchlist-<id>". 

You first need to upload an image of the face you want to match to the bucket named "rek-demo-watchlist-<id>". You can do this via the AWS console following this [guide](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/upload-objects.html).

Once you have uploaded the image(s) you create an index of the images.

```bash
export watchlistBucketName="rek-demo-watchlist-<id>"
export watchlistImageName="<name of file you uploaded previously"
aws rekognition create-collection --collection-id rek-demo
aws rekognition index-faces --image '{"S3Object":{"Bucket":"'$watchlistBucketName'","Name":"'$watchlistImageName'"}}' --collection-id "rek-demo"
```

### Run a local webserver to review the results
This will deploy a local web service to show the results of the video analysis.

```bash
pynt webui ; pynt webuiserver &
```

## Using the application

### Stream video data to your service
The videocaptureip command fires up the MJPEG-based video capture client (source code under the client/ directory). This command accepts, as parameters, an MJPEG stream URL and an optional frame capture rate. The capture rate is defined as 1 every X number of frames. Captured frames are packaged, serialized, and sent to the Kinesis Frame Stream. The video capture client for IP cameras uses Open CV 3 to do simple image processing operations on captured frame images – mainly image rotation.

Here’s a sample command invocation.

```
pynt videocaptureip["http://192.168.0.2/video",20] # Captures 1 frame every 20.
```

### Access the web console

Browse to "http://localhost:8080" on the docker host to see the results of the anaylytics service.
