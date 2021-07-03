pipeline {

    agent none

    environment {
        GOOGLE_MAPS_API_KEY = credentials('google_maps_api_key')
        GITHUB_GISTS_TOKEN = credentials('github_gist_token')
        MAPBOX_TOKEN = credentials('mapbox_token')
        ANDROID_LICENSE = credentials('android_license')

        build_image_name = 'jb/android_env'
    }

    stages {
        stage('Prepare Build Enviroment') {
            agent {
                dockerfile {
                    additionalBuildArgs "-t $build_image_name"
                }
            }

            steps {
                sh 'ls -la'
                // 'https://github.com/jojo243/docker-android-build'
            }
        }

        stage('Checkout') {
            agent any
            steps {
                git 'https://github.com/bike-bean/BikebeanApp.git'
            }
        }

        stage('Create secrets.xml') {
            agent any
            steps {
                sh '''cat <<EOF > app/src/main/res/values/secrets.xml
<?xml version="1.0" encoding="utf-8"?>
  <resources xmlns:tools="http://schemas.android.com/tools">
     <string name="google_maps_api_key">${GOOGLE_MAPS_API_KEY}</string>
     <string name="github_gist_token">${GITHUB_GISTS_TOKEN}</string>
     <string name="mapbox_token" tools:keep="@string/mapbox_token">${MAPBOX_TOKEN}</string>
  </resources>
EOF'''
            }
        }

        stage('Build') {
            agent {
                docker {
                    image "${build_image_name}"
                    args '-v android_sdk_root_volume:/opt/android-sdk -v android_home_volume:/home'
                }
            }

            steps {
                sh '/entrypoint.sh $ANDROID_LICENSE :app:assembleDebug'
            }
        }
    }
}
