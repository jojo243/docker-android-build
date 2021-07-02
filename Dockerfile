FROM  registry.gitlab.com/fdroid/ci-images-client

ARG   user=android_runner
ARG   uid=1000
ARG   gid=1000

ENV   GRADLE_USER_HOME /home/.gradle

RUN   groupadd -g ${gid} ${user} && \
        useradd -d /home/ -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
        mkdir -p /opt/android-sdk/licenses && \
        chown ${uid}:${gid} -R /home /opt/android-sdk

# put VOLUME specification BEFORE USER!!
VOLUME /home /opt/android-sdk

RUN   mkdir -p /home/.android/ && \
        cp /root/.android/repositories.cfg /home/.android/ && \
        chown ${uid}:${gid} -R /home/.android

# put USER specification AFTER VOLUME!!
USER  ${user}

COPY  entrypoint.sh .

ENTRYPOINT [ "/entrypoint.sh" ]
