# FROM ubuntu:18.04
FROM rocker/tidyverse:3.6.2
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]