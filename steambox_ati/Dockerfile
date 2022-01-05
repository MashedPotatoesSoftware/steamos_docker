FROM steambox_ati:postinstall
LABEL maintainer="rsharo@users.noreply.github.com"

USER steamuser
WORKDIR /home/steamuser
ENV HOME /home/steamuser
ENTRYPOINT [ "/usr/local/bin/show_motd" ]
CMD ["/bin/bash"]

