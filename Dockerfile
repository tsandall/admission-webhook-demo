FROM alpine

MAINTAINER Torin Sandall torinsandall@gmail.com

ADD bin/linux_amd64/admission-webhook-demo /admission-webhook-demo

ENTRYPOINT ["/admission-webhook-demo"]
