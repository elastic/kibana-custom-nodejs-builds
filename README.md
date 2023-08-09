# kibana-custom-nodejs-builds
Contains configuration and sources to build node.js

The main use case right now is building `node.js@18+` with `glibc@2.17`, which is required for some older platforms. (More context: https://github.com/nodejs/unofficial-builds/pull/69)

## How to generate a new build?
We have a kibana-flavored buildkite job that does most of the work for building these distributables, by running the scripts in this repo. You can find the job here: https://buildkite.com/elastic/kibana-custom-node-dot-js-builds - [configured here](https://github.com/elastic/kibana-buildkite/blob/main/pipelines/kibana-custom-node-build.tf).

### Build on a branch
You can either create a new branch, where you set the new default values for the Node & re2 versions, and run a new build on that branch (or get the PR merged, and run a build on `main`). See [this PR](https://github.com/elastic/kibana-custom-nodejs-builds/pull/8) for reference.

### Build with override parameters
Or you can set override parameters on buildkite when starting the job:
```
OVERRIDE_TARGET_VERSION=18.17.0
OVERRIDE_RE2_VERSION=1.20.1
```

### What happens after?
You should see the job starting up two tasks in parallel. Those are the (node.js + re2) builds per platform. The arm64 cross-compilation takes a while, but once they're done, we also create a `SHASUMS256.txt` based on the original version's hashes, but updating the entries for our custom-built versions.

All the artifacts will be uploaded to this bucket: [kibana-custom-node-artifacts](https://console.cloud.google.com/storage/browser/kibana-custom-node-artifacts;tab=objects?forceOnBucketsSortingFiltering=true&project=elastic-kibana-184716&supportedpurview=project&prefix=&forceOnObjectsSortingFiltering=false&pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22)))

### How to use these builds in Kibana?
- First, follow the guide for upgrading node.js for Kibana: https://www.elastic.co/guide/en/kibana/current/upgrading-nodejs.html
- Second, if you've updated RE2 versions, make sure to update the expected download hashes around in the [patch_native_modules_task.ts](https://github.com/elastic/kibana/blob/4c41247f938fcfde404a151a0b1193f3f5898cb1/src/dev/build/tasks/patch_native_modules_task.ts#L43)
- Finally, keep in mind that your requests for downloading these resources will probably go through the [kibana-proxy-cache](https://github.com/elastic/kibana-ci-proxy-cache/), if you're reading this in 2026 you might need to update that code as well :)


## Running locally
You can run most scripts locally on Mac/Linux. You'll need a few of the build/infra tools:
 - Docker
 - node.js
 - gsutil (`brew install google-cloud-sdk`)

Export some env variables required for the builds
```sh
  export ARCH="arm64" # or amd64
  export TARGET_VERSION="18.17.0"
  export RE2_VERSION="1.20.1"
```

Then run any of the individual scripts locally:
```sh
  ./scripts/create_build_images.sh
  ./scripts/build_nodejs.sh
  # ./scripts/...
```

Keep in mind, individual steps might have a dependency on other steps. For reference, check the call order in [pipeline.yml](./.buildkite/pipeline.yml).

## Docker image for node.js builds
One of the main components we need to create in this step is a docker image for an environment that's set up for building `node.js`.

The bits for this component are in the [build-image-config](./build-image-config/) folder.

The docker image uses mounted directories as working directories, as well as outputting the artifacts in these directories.


## Scripts for running the builds
Most of the `buildkite` logic is sheltered in the [scripts](./scripts/) directory.



## Context
During development, we found some more information that can be helpful as context, should anyone find this repo again

 - This repository is only needed...
   - While any of the following Linux distributions are included in the [Kibana support-matrix](https://www.elastic.co/support/matrix#matrix_kubernetes)
     - CentOS/RHEL 7
     - Oracle Enterprise Linux 7
     - Ubuntu 16.04 / 18.04 / 20.04
     - OpenSUSE 15
     - SLES 12
     - Debian 8 / 9
     - Amazon Linux 2
   - Until the `unofficial-builds` repo accepts a linux/arm64 build (https://github.com/nodejs/unofficial-builds/pull/83)
 - The created Docker images needn't be pushed
   - they can be used once for the build, then rebuilt in case we need to run it again
 - I decided to remove the `VARIATION` attribute on the node.js:
   - build would result in the variation showing up in the file and folder names, making the logistics more difficult, if we want to keep this mostly transparent for Kibana
