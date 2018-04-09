FROM us.gcr.io/google-containers/ubuntu-slim:0.14

RUN mkdir /home/notroot && groupadd -r notroot -g 433 && \
useradd -u 431 -r -g notroot -d /home/notroot -s /sbin/nologin -c "Docker image user" notroot && \
chown -R notroot:notroot /home/notroot
USER notroot
