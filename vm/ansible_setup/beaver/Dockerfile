FROM    centos:centos7
RUN     rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN     yum -y update
RUN     yum -y install python-pip
RUN     pip install beaver
RUN     mkdir /app
RUN     mkdir /app/log
ADD     conf/beaver.conf /app/beaver.conf

VOLUME ["/app/log"]

CMD ["beaver -c /app/beaver.conf -t rabbitmq"]
