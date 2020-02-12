FROM ubuntu:16.04
RUN apt-get update -y
RUN apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install opencv-python
RUN pip install boto3
RUN pip install awscli
RUN pip install pytz 	
RUN pip install pynt
RUN apt-get install -y openssh-client vim
RUN apt-get install -y libglib2.0-0 libsm6 libxrender1
RUN apt-get install -y git
RUN git clone https://github.com/aws-samples/amazon-rekognition-video-analyzer
RUN pip install pytz -t amazon-rekognition-video-analyzer/lambda/imageprocessor/
RUN sed -i '141s/if "=" in part:/if "|" in part:/g' /usr/local/lib/python2.7/dist-packages/pynt/_pynt.py
RUN echo $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1) > /tmp/random
RUN export random=$(cat /tmp/random) ; sed -i "s/\(SourceS3BucketParameter.*\)<NO-DEFAULT>/\1rek-demo-lambda-$random/g" amazon-rekognition-video-analyzer/config/cfn-params.json
RUN export random=$(cat /tmp/random) ; sed -i "s/\(FrameS3BucketNameParameter.*\)<NO-DEFAULT>/\1rek-demo-frames-$random/g" amazon-rekognition-video-analyzer/config/cfn-params.json
RUN export random=$(cat /tmp/random) ; sed -i "s/\(s3_bucket.*\)<NO-DEFAULT>/\1rek-demo-frames-$random/g" amazon-rekognition-video-analyzer/config/imageprocessor-params.json
