Build container
==============
```
$ docker build -t bigsea/collectd .
```
Run example
==========
Inserting a _collectd.conf_ into container and storing data on host file system
```
$ docker run -d \
  -v /srv/collectd:/var/lib/collectd \
  -v ${PWD}/conf.d:/etc/collectd/collectd.conf.d:ro \
  bigsea/collectd
```
