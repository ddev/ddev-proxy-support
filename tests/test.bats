setup() {
  set -eu -o pipefail
  unset HTTP_PROXY HTTPS_PROXY http_proxy NO_PROXY
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testproxysupport
  # Test proxy will normally come from TEST_PROXY_URL secret in github repo, but defaults to
  # a public proxy listed at https://spys.one/en/free-proxy-list/
  # This may not be reliable.
  export TEST_PROXY_URL=${TEST_PROXY_URL:-http://93.127.215.97:80}
  echo "# Using TEST_PROXY_URL=${TEST_PROXY_URL}" >&3

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
  ddev stop
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev debug refresh
  ddev start
  export HTTP_PROXY=${TEST_PROXY_URL}
#  export HTTPS_PROXY=${TEST_PROXY_URL}
  # Make sure that we can install extra packages using the proxy
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TEST_PROXY_URL}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
#  ddev exec curl -I -v https://example.com | grep "Uses proxy env variable http_proxy == '${HTTP_PROXY}'"
  ddev exec "curl -I -v https://example.com |& grep 'Uses proxy env variable'"
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev stop
  echo "# ddev get ddev/ddev-proxy-support with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-proxy-support
  ddev debug refresh
  ddev start
  export HTTP_PROXY=${TEST_PROXY_URL}
#  export HTTPS_PROXY=${TEST_PROXY_URL}
  # Make sure that we can install extra packages using the proxy
  ddev config --webimage-extra-packages=autojump
  ddev start
  ddev exec "echo \${HTTP_PROXY} | grep ${TEST_PROXY_URL}"
  grep "ENV.*HTTP_PROXY" .ddev/.webimageBuild/Dockerfile
#  ddev exec curl -I -v https://example.com | grep "Uses proxy env variable http_proxy == '${HTTP_PROXY}'"
  ddev exec "curl -I -v https://example.com |& grep 'Uses proxy env variable'"
}
