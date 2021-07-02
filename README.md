# docker-android-build

A Docker image to run Android Gradle tasks in CI.

## Usage

### 1. Building

Simply build this image via

```bash
docker build -t some_tag .
```

or use the Docker Engine API (e.g. if you are in another docker container):

```bash
tar czf context.tar.gz Dockerfile entrypoint.sh
curl -sS \
  --unix-socket "/var/run/docker.sock" \
  --request "POST" 'http://localhost/v1.41/build?t=some_tag' \
  --header "Content-Type: application/x-tar" \
  --data-binary "@context.tar.gz" | jq '.stream' | sed -e 's/^\"//;s/\"$//' | xargs -0 echo -e | grep --color=never -e .
rm context.tar.gz
```

(make sure you have access to the `/var/run/docker.sock`, most of the time
this includes adding your user to the `docker` group)

### 2. Running

Run the image with something similar to this:

```bash
docker run -t \
  -v __ANDROID_HOST_PATH__:/workspace \
  -v android_sdk_root_volume:/opt/android-sdk \
  -v android_home_volume:/home \
  -w /workspace \
  some_tag __ANDROID_SDK_LICENSE__ __GRADLE_TASK__
```

again, you can also use the Docker Engine API:

```bash
cat <<EOF > container.json
{
  "Cmd": [
    "__ANDROID_SDK_LICENSE__",
    "__GRADLE_TASK__"
  ],
  "Image": "some_tag",
  "Tty": true,
  "Volumes": {
    "/workspace": { },
    "/home": { },
    "/opt/android-sdk": { },
  },
  "WorkingDir": "/workspace",
  "HostConfig": {
    "Mounts": [
    {
      "Source": "__ANDROID_HOST_PATH__",
      "Target": "/workspace",
      "Type": "bind"
    },
    {
      "Source": "android_sdk_root_volume",
      "Target": "/opt/android-sdk",
      "Type": "volume"
    },
    {
      "Source": "android_home_volume",
      "Target": "/home",
      "Type": "volume"
    }
    ]
  }
}
EOF
# create the container
curl -sS \
  --unix-socket "/var/run/docker.sock" \
  --request "POST" 'http://localhost/v1.41/containers/create' \
  --header "Content-Type: application/json" \
  --data-binary "@container.json" | jq '.Id' | xargs echo | tee container_id.txt
rm container.json
# start the container
curl -sS \
  --unix-socket "/var/run/docker.sock" \
  --request "POST" "http://localhost/v1.41/containers/$(cat container_id.txt)/start" | jq '.message' | sed -e 's/^\"//;s/\"$//'
# attach to the container
curl -sS \
  --unix-socket "/var/run/docker.sock" \
  --request "POST" "http://localhost/v1.41/containers/$(cat container_id.txt)/attach?logs=true&stream=true&stdout=true&stderr=true"
```

### Variables

In the above examples, there are some placeholders that you should replace with
appropriate values.

| placeholder | explanation |
| --- | --- |
| \_\_ANDROID_SDK_LICENSE\_\_ | Android SDK License, usually found in `$ANDROID_HOME/licenses/android-sdk-license` |
| \_\_GRADLE_TASK\_\_ | Gradle Task, such as `:app:assembleDebug` |
| \_\_ANDROID_HOST_PATH\_\_ | Path (on the Host) to the Android Project |
