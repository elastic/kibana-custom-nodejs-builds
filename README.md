# kibana-custom-nodejs-builds
Contains configuration and sources to build node.js

The main usecase right now is building `node.js@18+` with `glibc@2.17`, which is required for some older platforms. (More context: https://github.com/nodejs/unofficial-builds/pull/69)

## Running locally
You can run most scripts locally on Mac/Linux. You'll need a few of the build/infra tools:
 - Docker
 - node.js
 - gsutil (`brew install google-cloud-sdk`)

Export some env variables required for the builds
```sh
  export ARCH="arm64"
  export TARGET_VERSION="18.16.1"
  export RE2_VERSION="1.17.7"
```

Then run individual scripts locally:
```sh
  ./scripts/create_build_images.sh
  ./scripts/build_nodejs.sh
```

## Docker image for node.js builds
One of the main components we need to create in this step is a docker image for an environment that's set up for building `node.js`.

The bits for this component are in the [build-image-config](./build-image-config/) folder.

The docker image uses mounted directories as working directories, as well as outputting the artifacts in these directories.


## Scripts for running the builds
Most of the `buildkite` logic is sheltered in the [scripts](./scripts/) directory.



## Context
During development, we found some more information that can be helpful as context, should anyone find this repo again

 - This repository is only needed while
   - centos:7 / RHEL7 is supported by Elastic, and we ship node.js with Kibana
   - the unofficial-builds repo accepts a linux/arm64 build (https://github.com/nodejs/unofficial-builds/pull/83)
 - The created Docker images needn't be pushed
   - they can be used once for the build, then rebuilt in case we need to run it again
 - I decided to remove the `VARIATION` attribute on the node.js:
   - build would result in the variation showing up in the file and folder names, making the logistics more difficult, if we want to keep this mostly transparent for Kibana
