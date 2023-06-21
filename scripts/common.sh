
function assert_correct_arch() {
  ARCH=$1

  if [[ "$ARCH" == "arm64" || "$ARCH" == "amd64" ]]; then
    # we're good, supported architecture
    echo "Building for architecture: $ARCH"
  else
    echo "ARCH (=$ARCH) env variable is not one of: arm64, amd64"
    exit 1
  fi
}

function get_build_image_name() {
  NODE_VERSION=${1:-$TARGET_VERSION}
  PLATFORM=${2:-$ARCH}

  echo "docker.elastic.co/elastic/nodejs-custom:$NODE_VERSION-$PLATFORM"
}
