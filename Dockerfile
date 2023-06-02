FROM alpine:latest

ENV FLASK_DOCUMENTROOT /var/flaskapp

ENV FLASK_USER flask

ENV FLASK_PORT 5000

RUN mkdir -p $FLASK_DOCUMENTROOT

RUN adduser -h $FLASK_DOCUMENTROOT  -D  -s /bin/sh  $FLASK_USER

WORKDIR $FLASK_DOCUMENTROOT

COPY ./code/ .

RUN chown -R  $FLASK_USER:$FLASK_USER $FLASK_DOCUMENTROOT

RUN apk update && apk add python3 py3-pip --no-cache

RUN pip3 install -r requests.txt

USER $FLASK_USER

EXPOSE $FLASK_PORT

ENTRYPOINT ["python3"]

CMD ["app.py"]
