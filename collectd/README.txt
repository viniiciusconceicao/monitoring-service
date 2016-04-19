Run example inserting a collectd.conf file insite the container
docker run -v /home/openstack/Desktop/collectd.conf.d:/etc/collectd/collectd.conf:ro -d vini/collectd:v2