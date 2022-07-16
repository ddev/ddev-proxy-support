
# Lab-testing a proxied environment

I used Parallels on macOS for the test lab.

* Created a Parallels VM proxy server with a simple tiny Ubuntu 22.04 server running [tinyproxy](https://tinyproxy.github.io/), which was shockingly simple to install and configure (`apt-get install tinyproxy`), very small configuration changes ([example /etc/tinyproxy/tinyproxy.conf](tinyproxy.conf)). I'll call this machine "proxy".
* Added an additional "host-only" interface in Parallels and added it to the proxy VM
* Set up Parallels to use the name of the VM as its hostname. You should now be able to `ping proxy.host-only`
* Used an existing (different) Ubuntu 22.04 Parallels VM as the ddev/docker environment and added the host only interface to it.  I'll call this machine "workstation".
* Turned off the primary network interface in the workstation, so it had no direct network connectivity, verified that ping of internet addresses failed.
* Configured the workstation VM with system-wide proxy settings using the regular Ubuntu network setting GUI (in this case HTTP/HTTPS proxies using proxy.host-only:8888).
* Configured the Firefox browser on "workstation" to use the system-configured proxy and verified that it could now operate.
* Verified that curl against internet https locations now worked on the "workstation".
* Configured the docker server as in step 2 above, and verified that `docker pull ubuntu` now worked on "workstation" using the proxy.
* Configured the docker client as in step 3 above and verified that proxy setup was now right in the container by `ddev start`, `ddev ssh`, and using curl inside the container against an HTTPS website.
* Added the .ddev/web-build/Dockerfile from step 4 into the ddev project on the "workstation" and `ddev start`, then `ddev ssh` and `sudo apt-get update` and saw the update happen successfully, all using the proxy.
