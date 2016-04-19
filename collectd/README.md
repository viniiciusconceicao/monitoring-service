Run example
==========
### Inserting a _collectd.conf_ file inside the container
docker run -v ${PWD}/collectd.conf:/etc/collectd/collectd.conf:ro -d vini/collectd
