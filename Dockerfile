FROM astrolox/ubuntu-16-passenger-python-3.5:latest
MAINTAINER brian.wojtczak@1and1.co.uk
COPY files /
RUN chmod -R 777 /etc/supervisor/conf.d /etc/supervisor/conf.d/*
RUN application-bootstrap
ENV \
	PASSENGER_APP_ENV=production \
	CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672// \
	CELERY_BROKER_API=http://guest:guest@rabbitmq:15672/api/
