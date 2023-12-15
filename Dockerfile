FROM debian:11

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -qy \
	&& apt-get full-upgrade -qy \
	&& apt-get dist-upgrade -qy \
	&& apt-get install -qy \
        sudo wget curl unzip tar git xz-utils apt-utils openssh-server build-essential software-properties-common \
        nano python3-pip lsb-release ca-certificates apt-transport-https 

# Install tor
RUN wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | apt-key add - \
    && apt-add-repository --yes -s https://deb.torproject.org/torproject.org \
    && apt-get update \
    && apt-get install tor deb.torproject.org-keyring torsocks -y \
    && sed -i 's\#SocksPort 9050\SocksPort 9058\ ' /etc/tor/torrc \
    && sed -i 's\#ControlPort 9051\ControlPort 9059\ ' /etc/tor/torrc \
    && sed -i 's\#HashedControlPassword\HashedControlPassword\ ' /etc/tor/torrc \
    && sed -i 's\#CookieAuthentication 1\CookieAuthentication 1\ ' /etc/tor/torrc \
    && sed -i 's\#HiddenServiceDir /var/lib/tor/hidden_service/\HiddenServiceDir /var/lib/tor/hidden_service/\ ' /etc/tor/torrc \
    && sed -i '72s\#HiddenServicePort 80 127.0.0.1:80\HiddenServicePort 80 127.0.0.1:80\ ' /etc/tor/torrc \
    && sed -i '73 i HiddenServicePort 22 127.0.0.1:22' /etc/tor/torrc \
    && sed -i '74 i HiddenServicePort 8080 127.0.0.1:8080' /etc/tor/torrc \
    && sed -i '75 i HiddenServicePort 4000 127.0.0.1:4000' /etc/tor/torrc \
    && sed -i '76 i HiddenServicePort 8000 127.0.0.1:8000' /etc/tor/torrc \
    && sed -i '77 i HiddenServicePort 9000 127.0.0.1:9000' /etc/tor/torrc \
    && sed -i '78 i HiddenServicePort 3389 127.0.0.1:3389' /etc/tor/torrc \
    && sed -i '79 i HiddenServicePort 5901 127.0.0.1:5901' /etc/tor/torrc \
    && sed -i '80 i HiddenServicePort 5000 127.0.0.1:5000' /etc/tor/torrc \
    && sed -i '81 i HiddenServicePort 6080 127.0.0.1:6080' /etc/tor/torrc \
    && sed -i '82 i HiddenServicePort 8888 127.0.0.1:8888' /etc/tor/torrc \
    && sed -i '83 i HiddenServicePort 8888 127.0.0.1:7777' /etc/tor/torrc \
    && sed -i '84 i HiddenServicePort 12345 127.0.0.1:12345' /etc/tor/torrc \
    && sed -i '85 i HiddenServicePort 10000 127.0.0.1:10000' /etc/tor/torrc \
    && sed -i '86 i HiddenServicePort 40159 127.0.0.1:40159' /etc/tor/torrc 

# cleanup and fix
RUN apt-get autoremove --purge -qy \
	&& apt-get --fix-broken install \
	&& apt-get clean 
 
 # Install gotty
RUN wget https://github.com/sorenisanerd/gotty/releases/download/v1.5.0/gotty_v1.5.0_linux_amd64.tar.gz \
    && tar -xf gotty_v1.5.0_linux_amd64.tar.gz \
    && rm -rf gotty_v1.5.0_linux_amd64.tar.gz \
	&& chmod +x gotty \
    && mv gotty /usr/local/bin/gotty

# user and groups
ENV USER shakugan
ENV PASSWORD AliAly032230
RUN useradd -m $USER -p $(openssl passwd $PASSWORD) \
    && usermod -aG sudo $USER \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && chsh -s /bin/bash $USER

EXPOSE 8080 22 12345

COPY gotty.sh /
CMD ["/gotty.sh"]
