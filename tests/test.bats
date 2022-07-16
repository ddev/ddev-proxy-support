setup() {
  set -eu -o pipefail
  unset HTTP_PROXY HTTPS_PROXY http_proxy NO_PROXY
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testproxysupport
  # Test proxy from random public proxies listed at https://spys.one/en/free-proxy-list/
  # This may not be reliable, don't know.
  export TESTPROXY=http://67.212.186.101:80
  mkdir -p $TESTDIR
  export PROJNAME=test-proxy-support
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
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
  export http_proxy=${HTTP_PROXY}
#  export HTTPS_PROXY=${TESTPROXY}
  export NO_PROXY=127.0.0.1
  # Make sure that we can install extra packages using the proxy
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TESTPROXY}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
#  ddev exec curl -I -v https://example.com | grep "Uses proxy env variable http_proxy == '${HTTP_PROXY}'"
  ddev exec "curl -I -v https://example.com |& grep 'Uses proxy env variable'"
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get rfay/ddev-proxy-support with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get rfay/ddev-proxy-support
  ddev debug refresh
  ddev start
  export HTTP_PROXY=${TESTPROXY}
  export http_proxy=${HTTP_PROXY}
#  export HTTPS_PROXY=${TESTPROXY}
  export NO_PROXY=127.0.0.1
  # Make sure that we can install extra packages using the proxy
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TESTPROXY}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
#  ddev exec curl -I -v https://example.com | grep "Uses proxy env variable http_proxy == '${HTTP_PROXY}'"
  ddev exec "curl -I -v https://example.com |& grep 'Uses proxy env variable'"
}
