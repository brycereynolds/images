# FROM https://registry.hub.docker.com/u/dockerfile/ubuntu/dockerfile/
FROM dockerfile/ubuntu
MAINTAINER Bryce Reynolds brycereynoldsdesign@gmail.com

RUN apt-get update -q \
    && apt-get install -qy wget

# Install Redis.
RUN \
  cd /tmp && \
  wget http://download.redis.io/releases/redis-2.6.17.tar.gz && \
  tar xvzf redis-2.6.17.tar.gz && \
  cd redis-2.6.17 && \
  make && \
  make install && \
  cp -f src/redis-sentinel /usr/local/bin && \
  mkdir -p /etc/redis && \
  cp -f *.conf /etc/redis && \
  rm -rf /tmp/redis-2.6.17* && \
  sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
  sed -i 's/^\(requirepass .*\)$/# \1\ndir \/mypwd/' /etc/redis/redis.conf && \
  sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# Expose ports.
EXPOSE 6379