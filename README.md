[![tests](https://github.com/ddev/ddev-proxy-support/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-proxy-support/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2023.svg)

# DDEV Proxy support (Archived, see DDEV Docs)

**This add-on is now archived.**

**Configuring proxy support for DDEV and Docker is not hard, but it does require more than the simple approach shown here. Please see [DDEV Networking](https://ddev.readthedocs.io/en/latest/users/usage/networking/). (You don't really have to do anything for DDEV, but you do have to configure Docker to get everything working.)**

To install this, install and restart:

```sh
ddev add-on get ddev/ddev-proxy-support && ddev restart
```

It installs a docker-compose.proxy.yaml and pre.Dockerfile.proxy-support which add proxy capabilities to DDEV v1.19.5+

With this setup you should be able to use `webimage_extra_packages` against a proxy, and you should also be able to `ddev ssh` into the web container and use curl and see it using the proxy. `curl -v -I <target>` is a good test. See also the [tests](tests/test.bats).

# Testing

Details about how to lab-test this are in [Lab-testing a proxied environment](lab-testing.md).

You can also find public proxies of varying reliability at [spys](https://spys.one/free-proxy-list/US/) and other places, and of course you would never trust them with any traffic, but they're useful for testing.

**Contributed and maintained by [@rfay](https://github.com/rfay) based on the original [ddev-contrib recipe](https://github.com/ddev/ddev-contrib/tree/master/recipes/proxy).**


