FROM mcr.microsoft.com/infersharp:v1.4

ADD run_infersharp_ci.sh /run_infersharp_ci.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
