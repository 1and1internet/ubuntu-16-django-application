# ubuntu-16-django-application

**_Current Status: Work In Progress_**

A Docker image to use as a basis for Docker contained Django applications with Celery background task processing, which will be running under OpenShift.

* Django is a python based web application framework: https://www.djangoproject.com/
* Celery is a Distributed Task Queue: http://www.celeryproject.org/
* OpenShift is a container application platform based on Docker: https://www.openshift.org/
* Docker is an software containerization tool: https://www.docker.com/

## Quick Start

### Using OpenShift

'''
oc new-app --file=openshift-template.yaml --param=APP_HOSTNAME_SUFFIX=.djangoapp.example.com
'''

### Using Docker

 1. First run a broker for Celery. I use RabbitMQ (https://www.rabbitmq.com/).
    ```
    docker run -d -P --name=rabbitmq rabbitmq:3-management 
    ```

 2. Run the Django image.
    ```
    docker run -d -P --link rabbitmq:rabbitmq --name=djangoapp astrolox/ubuntu-16-django-application
    ```

## Environment variables

All configuration is via environment variables.

* Just OpenShift
** ``APP_NAME`` - Name of this Django application (maximum 17 characters)
** ``APP_DB_DATABASE`` - Database database name
** ``APP_HOSTNAME_SUFFIX`` - HTTPS hostname suffix for the routes

* Both Docker and OpenShift
** ``CELERY_BROKER_URL`` - defaults to amqp://guest:guest@rabbitmq:5672//
** ``CELERY_BROKER_API`` - defaults to http://guest:guest@rabbitmq:15672/api/
