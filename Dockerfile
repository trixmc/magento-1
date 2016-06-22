FROM      ubuntu:14.04.4
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>


RUN apt-get install -y openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc
COPY configs/.bashrc /root/.bashrc

#Install locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

#Add colorful command line
RUN echo "force_color_prompt=yes" >> .bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc

#Unzip console magento
RUN rm -rf /var/www/*
RUN unzip -d /var/www /home/magento.zip
RUN chown -R www-data:www-data /var/www
RUN rm /home/magento.zip

#etcKeeper
RUN mkdir -p /root/etckeeper
COPY configs/etckeeper.sh /root/etckeeper.sh
COPY configs/etckeeper-hook.sh /root/etckeeper/etckeeper-hook.sh
RUN chmod +x /root/etckeeper/*.sh
RUN chmod +x /root/*.sh
RUN /bin/bash -c '/root/etckeeper.sh'

#open ports
EXPOSE 80 22
