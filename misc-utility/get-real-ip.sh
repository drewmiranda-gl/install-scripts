# this is useful to obtain the IP address to use for binding services to an IP
# This is needed because when docker is installed, binding to 0.0.0.0 binds to the docker interface
tmp_ip_bind=$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)