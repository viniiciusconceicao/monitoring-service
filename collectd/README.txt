Run example inserting a collectd.conf file inside the container
docker run -v /home/openstack/Desktop/collectd.conf.d:/etc/collectd/collectd.conf:ro -d vini/collectd:v2