FROM 1and1internet/ubuntu-16-nginx-passenger-python-3:latest
MAINTAINER brian.wojtczak@1and1.co.uk
ENV \
	PASSENGER_APP_ENV=production \
	CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672// \
	CELERY_BROKER_API=http://guest:guest@rabbitmq:15672/api/ \
	SECRET_KEY=insecure
COPY files /
RUN application-bootstrap
WORKDIR /var/www/
CMD ["application-all"]
