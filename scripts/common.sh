
BUCKET_NAME="kibana-custom-node-artifacts"

export TARGET_VERSION=${OVERRIDE_TARGET_VERSION:-TARGET_VERSION}

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

function retry() {
  local retries=$1; shift
  local delay=$1; shift
  local attempts=1

  until "$@"; do
    retry_exit_status=$?
    echo "Exited with $retry_exit_status" >&2
    if (( retries == "0" )); then
      return $retry_exit_status
    elif (( attempts == retries )); then
      echo "Failed $attempts retries" >&2
      return $retry_exit_status
    else
      echo "Retrying $((retries - attempts)) more times..." >&2
      attempts=$((attempts + 1))
      sleep "$delay"
    fi
  done
}

function replace_shasums_in_folder() {
  local working_directory=$1

  cd $working_directory

  # Check if SHASUMS256.txt file exists
  if [ ! -f "./SHASUMS256.txt" ]; then
    echo "SHASUMS256.txt file does not exist in folder: $working_directory"
    exit 1
  fi

  # Loop through files in folder
  for file in *; do
    if [ "$file" != "SHASUMS256.txt" ] && [ -f "$file" ]; then
      # Calculate SHA256 hash
      new_sha256=$(shasum -a 256 "$file" | cut -d' ' -f1)
      # Replace hashes in SHASUMS256.txt
      node -e """
        lines = fs.readFileSync('SHASUMS256.txt').toString().split('\n')
        output = lines.map(l => l.endsWith('$file') ? '$new_sha256  $file' : l)
        fs.writeFileSync('SHASUMS256.txt', output.join('\n'))
      """
    fi
  done

  echo "`pwd`/SHASUMS256.txt updated"

  cd -
}
