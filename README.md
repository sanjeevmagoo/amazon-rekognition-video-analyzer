
docker build -t openhack-redhat-aws-2020 .

docker run -p 8080:8080 -ti openhack-redhat-aws-2020

aws configure

cd amazon-rekognition-video-analyzer/

pynt packagelambda

pynt deploylambda

pynt createstack

pynt webui ; pynt webuiserver &

pynt videocaptureip["http://192.168.1.3:8081",20] # Captures 1 frame every 20.

