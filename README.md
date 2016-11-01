# ubuntu-16-django-application

**_Current Status: Work In Progress (Feedback wanted)_**

A Docker image to use as a basis for Docker contained Django applications with Celery background task processing, which will be running under OpenShift.

* Django is a python based web application framework: https://www.djangoproject.com/
* Celery is a Distributed Task Queue: http://www.celeryproject.org/
* OpenShift is a container application platform based on Docker: https://www.openshift.org/
* Docker is an software containerization tool: https://www.docker.com/

## Quick Start

### Using Docker

 1. First run a broker for Celery. I use RabbitMQ (https://www.rabbitmq.com/).
    ```
    docker run -d -P --name=rabbitmq rabbitmq:3-management 
    ```

 2. Run the Django image.
    ```
    docker run -d -P --link rabbitmq:rabbitmq --name=djangoapp astrolox/ubuntu-16-django-application
    ```

### Using OpenShift

```
oc new-app --file=openshift-template.yaml --param=APP_HOSTNAME_SUFFIX=.djangoapp.example.com
```

## Usage

## Creating your own application image

 1. Create a Dockerfile in your project folder.

    Basic example:
    ```
    FROM astrolox/ubuntu-16-django-application
    COPY src/ ./
    RUN ["/bin/bash", "-c", " \
            source application-python3-environment && \
            pip install --no-cache-dir --upgrade pip && \
            pip install --no-cache-dir --upgrade -r requirements.txt \
            python manage.py collectstatic --noinput --clear --link --verbosity 0 \
        "]
    ```

    A more complex example of what you might want your Dockerfile to look like:
    ```
    FROM astrolox/ubuntu-16-django-application
    # Copy in various additional required files (like init scripts).
    COPY files /
    # Install app required python modules from pip requirements file
    #  Do this separately so that it doesn't have to be repeated often
    COPY src/requirements.txt /var/www
    RUN ["/bin/bash", "-c", " \
            source application-python3-environment && \
            pip install --no-cache-dir --upgrade pip && \
            pip install --no-cache-dir --upgrade -r requirements.txt \
        "]
    # Copy the application in to the image
    #  Do this pretty late because its the item most likely to change
    COPY src/ /var/www
    # Perform additional setup required for the application
    # Collate static files in to the correct folder
    RUN ["/bin/bash", "-c", " \
            application-component-remove scheduler && \
            application-component-remove worker && \
            source application-python3-environment && \
            python manage.py collectstatic --noinput --clear --link --verbosity 0 \
        "]
    ```

 2. Place your django application code in ./src/

  ```
  django-admin startproject -v 3 app ./src/
  ```

 3. Setup your WSGI file to have the name passenger_wsgi.py

  ```
  cp ./src/app/wsgi.py ./src/passenger_wsgi.py
  ```

 4. Build your docker image

  ```
  docker build -t mydjangoapp .
  ```

 6. See it running

  ```
  docker run -d -P mydjangoapp
  ```

For configuring passwords, etc, I recommend environment variables via the --env-file paramter to docker run. Please see the Docker documentation for further details.

## Official deployment checklist

Before putting your Django application near a production server please review [the deployment checklist in the Django documentation](https://docs.djangoproject.com/en/1.9/howto/deployment/checklist/ "Django 1.9 deployment checklist").

## Deploying to OpenShift

 1. Modify the openshift-template file.
    - Change the image names
    - Remove any of the components which are you not using
    - Modify run as user ID numbers
    - Modify the volume configuration to match that required by your openshift cluster

 2. Run the new-app command
  ```
  oc new-app --file=openshift-template.yaml --param=APP_HOSTNAME_SUFFIX=.djangoapp.example.com
  ```

## Variables

* OpenShift Template Parameters
  * ``APP_NAME`` - Name of this Django application (maximum 17 characters)
  * ``APP_DB_DATABASE`` - Database database name
  * ``APP_HOSTNAME_SUFFIX`` - HTTPS hostname suffix for the routes

* Both Docker Environment Variables and OpenShift Template Parameters
  * ``PASSENGER_APP_ENV`` - defaults to ``production``, may also set to ``development``
  * ``CELERY_BROKER_URL`` - defaults to ``amqp://guest:guest@rabbitmq:5672//``
  * ``CELERY_BROKER_API`` - defaults to ``http://guest:guest@rabbitmq:15672/api/``

* Docker build arguments
  * ``BAKED`` - defaults to ``True``, any other value means ``False``
  * ``DJANGO_VER`` - defaults to ``1.9.11``
  * ``DJANGO_CELERY_VER`` - defaults to ``3.1.17``

### Baked

The primary use case for this image is to have a Django application baked in to it, by way of a docker image descending from this one. Please see the above usage instructions and example.

However if you prefer to use this image to provide just the environment in which to run Django. This is supported by setting BAKED to False when building the image. Doing so then allows you to mount persistent storage at /var/www from which your Django application can be served. 

### Django version

Note that this image can be used with versions of Django which are newer than 1.9 (which is not the latest at time of updating this README). However the message queue implementation is currently of the older style which does not sit well with newer version of Django. I plan to update this image (in a way that is backwards compatible) to address this, but until that is done it will default to the older version of Django.
