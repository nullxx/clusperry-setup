FROM ubuntu:14.04

WORKDIR /app
COPY . .

RUN apt-get -y -qq update && \
	apt-get install dnsutils curl wget jq tree -y && \
	apt-get clean

CMD ["bash", "/app/script.sh"]