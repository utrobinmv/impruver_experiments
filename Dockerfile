FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel
# Install necessary system packages 
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -yq && apt-get install -yq \
                build-essential \
                git-core \
                git \
                pkg-config \
                git-lfs \
                libtool \
                zlib1g-dev \
                libbz2-dev \
                automake \
                python3-dev \
                wget \
                curl

# Setup SSH with secure root loginn
RUN apt-get update \
 && apt-get install -y openssh-server netcat sudo
 
RUN mkdir /var/run/sshd \
 && sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN useradd -mG sudo,cdrom,users,dip,plugdev -p app -s /bin/bash app

RUN apt-get install -y mc tmux

RUN echo 'app:app' | chpasswd

RUN mkdir /home/app/.config

RUN chown -R app:users /home/app/.config

RUN apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl libgtk2.0-dev

RUN apt-get install -y libjpeg-dev zlib1g-dev

RUN apt-get install -y curl git-core gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev tk-dev libffi-dev liblzma-dev

RUN apt-get install -y build-essential zlib1g-dev libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev libncurses-dev tk-dev python3-pip

RUN sed -re 's/^(\#)(AllowAgentForwarding)([[:space:]]+)(.*)/\2\3\4/' -i.`date -I` /etc/ssh/sshd_config
RUN sed -re 's/^(AllowAgentForwarding)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config

RUN sed -re 's/^(\#)(AllowTcpForwarding)([[:space:]]+)(.*)/\2\3\4/' -i.`date -I` /etc/ssh/sshd_config
RUN sed -re 's/^(AllowTcpForwarding)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config

RUN sed -re 's/^(\#)(X11Forwarding)([[:space:]]+)(.*)/\2\3\4/' -i.`date -I` /etc/ssh/sshd_config
RUN sed -re 's/^(X11Forwarding)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config

RUN sed -re 's/^(\#)(X11DisplayOffset)([[:space:]]+)(.*)/\2\3\4/' -i.`date -I` /etc/ssh/sshd_config

RUN sed -re 's/^(\#)(X11UseLocalhost)([[:space:]]+)(.*)/\2\3\4/' -i.`date -I` /etc/ssh/sshd_config
RUN sed -re 's/^(X11UseLocalhost)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/sshd_config

RUN apt-get install -y libaio-dev python3-dev python3-venv

USER app

WORKDIR /home/app

RUN python3 -m venv ~/.pyvenv/base

ENV PATH="/home/app/.pyvenv/base/bin:$PATH"

RUN pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121

#RUN DS_BUILD_FUSED_ADAM=1 pip install deepspeed==0.14.5

COPY ../requirements.txt .

RUN pip install -r requirements.txt

RUN echo "" >> ~/.bashrc
RUN echo "#python3.11 base" >> ~/.bashrc
RUN echo "source ~/.pyvenv/base/bin/activate" >> ~/.bashrc

USER root

RUN usermod --uid 777897245 app

RUN chown -R app:users /home/app/

CMD /usr/sbin/sshd -D
