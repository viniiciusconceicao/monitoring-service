FROM frolvlad/alpine-oraclejdk8

ENV RIENMANN_VERSION=0.2.13
ENV RIEMANN_PATH_CONF=/home/riemann
ENV RIEMANN_CONFIG=/home/riemann/riemann.config
RUN apk -U add curl bash
RUN apk add ca-certificates wget && update-ca-certificates

RUN adduser -D riemann
USER riemann
WORKDIR /home/riemann

RUN wget  https://github.com/riemann/riemann/releases/download/${RIENMANN_VERSION}/riemann-${RIENMANN_VERSION}.tar.bz2 && tar xvfj riemann-${RIENMANN_VERSION}.tar.bz2

RUN mv riemann-${RIENMANN_VERSION} riemann

ADD ./riemann.config riemann.config

ADD ./riemann-rabbitmq-input.jar riemann/lib/riemann-rabbitmq-input.jar

ENV EXTRA_CLASSPATH=/home/riemann/riemann/lib/riemann-rabbitmq-input.jar

CMD ["riemann/bin/riemann", "riemann.config"]
