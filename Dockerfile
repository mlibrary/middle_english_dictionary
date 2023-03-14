FROM ruby:2.7

ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG ARCH=amd64

ENV BUNDLE_PATH /var/opt/app/gems

RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
    vim

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /opt/app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir /var/opt/app
RUN mkdir /var/opt/app/gems
RUN chown $UID:$GID /var/opt/app
RUN chown $UID:$GID /var/opt/app/gems
RUN touch $UID:$GID /var/opt/app/gems/.keep
COPY --chown=$UID:$GID . /opt/app

USER $UNAME
WORKDIR /opt/app
RUN gem install bundler

CMD ["sleep", "infinity"]
