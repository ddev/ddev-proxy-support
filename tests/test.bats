setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testproxysupport
  # Test proxy from random public proxies listed at https://spys.one/en/free-proxy-list/
  # This may not be reliable, don't know.
  export TESTPROXY=http://96.242.29.93:3128
  mkdir -p $TESTDIR
  export PROJNAME=test-proxy-support
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev stop
  ddev get ${DIR}
  ddev debug refresh
  ddev start
  export HTTP_PROXY=${TESTPROXY}
#  export HTTPS_PROXY=${TESTPROXY}
  export NO_PROXY=127.0.0.1
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TESTPROXY}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get rfay/ddev-proxy-support with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get rfay/ddev-proxy-support
  ddev debug refresh
  ddev start
  export HTTP_PROXY=${TESTPROXY}
#  export HTTPS_PROXY=${TESTPROXY}
  export NO_PROXY=127.0.0.1
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TESTPROXY}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
}
