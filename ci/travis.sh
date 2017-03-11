#!/bin/sh

#  _                   _          _      _     _                          _
# | |_ _ __ __ ___   _(_)___   __| | ___| |__ (_) __ _ _ __    _ __   ___| |_
# | __| '__/ _` \ \ / / / __| / _` |/ _ \ '_ \| |/ _` | '_ \  | '_ \ / _ \ __|
# | |_| | | (_| |\ V /| \__ \| (_| |  __/ |_) | | (_| | | | |_| | | |  __/ |_
#  \__|_|  \__,_| \_/ |_|___(_)__,_|\___|_.__/|_|\__,_|_| |_(_)_| |_|\___|\__|
#
#
#               Documentation: <http://travis.debian.net>


## Copyright ##################################################################
#
# Copyright © 2015, 2016 Chris Lamb <lamby@debian.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Functions ##################################################################

set -eu

Info () {
	echo "I: ${*}" >&2
}

Error () {
	echo "E: ${*}" >&2
}

## Configuration ##############################################################

SOURCE="$(dpkg-parsechangelog | awk '/^Source:/ { print $2 }')"
VERSION="$(dpkg-parsechangelog | awk '/^Version:/ { print $2 }')"

Info "Starting build of ${SOURCE} using travis.debian.net"

TRAVIS_DEBIAN_MIRROR="${TRAVIS_DEBIAN_MIRROR:-http://ftp.de.debian.org/debian}"
TRAVIS_DEBIAN_BUILD_DIR="${TRAVIS_DEBIAN_BUILD_DIR:-/build}"
TRAVIS_DEBIAN_TARGET_DIR="${TRAVIS_DEBIAN_TARGET_DIR:-../}"
TRAVIS_DEBIAN_NETWORK_ENABLED="${TRAVIS_DEBIAN_NETWORK_ENABLED:-false}"
TRAVIS_DEBIAN_INCREMENT_VERSION_NUMBER="${TRAVIS_DEBIAN_INCREMENT_VERSION_NUMBER:-false}"

#### Distribution #############################################################

TRAVIS_DEBIAN_BACKPORTS="${TRAVIS_DEBIAN_BACKPORTS:-false}"
TRAVIS_DEBIAN_EXPERIMENTAL="${TRAVIS_DEBIAN_EXPERIMENTAL:-false}"

if [ "${TRAVIS_DEBIAN_DISTRIBUTION:-}" = "" ]
then
	Info "Automatically detecting distribution"

	TRAVIS_DEBIAN_DISTRIBUTION="${TRAVIS_BRANCH:-}"

	if [ "${TRAVIS_DEBIAN_DISTRIBUTION:-}" = "" ]
	then
		TRAVIS_DEBIAN_DISTRIBUTION="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)"
	fi

	TRAVIS_DEBIAN_DISTRIBUTION="${TRAVIS_DEBIAN_DISTRIBUTION##debian/}"

	# Detect backports
	case "${TRAVIS_DEBIAN_DISTRIBUTION}" in
		*-backports)
			TRAVIS_DEBIAN_BACKPORTS="true"
			TRAVIS_DEBIAN_DISTRIBUTION="${TRAVIS_DEBIAN_DISTRIBUTION%%-backports}"
			;;
		backports/*)
			TRAVIS_DEBIAN_BACKPORTS="true"
			TRAVIS_DEBIAN_DISTRIBUTION="${TRAVIS_DEBIAN_DISTRIBUTION##backports/}"
			;;
	esac
fi

# Detect codenames
case "${TRAVIS_DEBIAN_DISTRIBUTION}" in
	oldstable)
		TRAVIS_DEBIAN_DISTRIBUTION="wheezy"
		;;
	stable)
		TRAVIS_DEBIAN_DISTRIBUTION="jessie"
		;;
	testing)
		TRAVIS_DEBIAN_DISTRIBUTION="stretch"
		;;
	unstable|master)
		TRAVIS_DEBIAN_DISTRIBUTION="sid"
		;;
	experimental)
		TRAVIS_DEBIAN_DISTRIBUTION="sid"
		TRAVIS_DEBIAN_EXPERIMENTAL="true"
		;;
esac

case "${TRAVIS_DEBIAN_DISTRIBUTION}" in
	wheezy)
		TRAVIS_DEBIAN_GIT_BUILDPACKAGE="${TRAVIS_DEBIAN_GIT_BUILDPACKAGE:-git-buildpackage}"
		TRAVIS_DEBIAN_GIT_BUILDPACKAGE_OPTIONS="${TRAVIS_DEBIAN_GIT_BUILDPACKAGE_OPTIONS:-}"
		;;
	*)
		TRAVIS_DEBIAN_GIT_BUILDPACKAGE="${TRAVIS_DEBIAN_GIT_BUILDPACKAGE:-gbp buildpackage}"
		TRAVIS_DEBIAN_GIT_BUILDPACKAGE_OPTIONS="${TRAVIS_DEBIAN_GIT_BUILDPACKAGE_OPTIONS:---git-submodules}"
		;;
esac

case "${TRAVIS_DEBIAN_DISTRIBUTION}" in
	wheezy|jessie)
		TRAVIS_DEBIAN_AUTOPKGTEST_RUN="${TRAVIS_DEBIAN_AUTOPKGTEST_RUN:-adt-run}"
		TRAVIS_DEBIAN_AUTOPKGTEST_SEPARATOR="${TRAVIS_DEBIAN_AUTOPKGTEST_SEPARATOR:----}"
		;;
	*)
		TRAVIS_DEBIAN_AUTOPKGTEST_RUN="${TRAVIS_DEBIAN_AUTOPKGTEST_RUN:-autopkgtest}"
		TRAVIS_DEBIAN_AUTOPKGTEST_SEPARATOR="${TRAVIS_DEBIAN_AUTOPKGTEST_SEPARATOR:---}"
		;;
esac

case "${TRAVIS_DEBIAN_DISTRIBUTION}" in
	sid)
		TRAVIS_DEBIAN_SECURITY_UPDATES="${TRAVIS_DEBIAN_SECURITY_UPDATES:-false}"
		;;
	*)
		TRAVIS_DEBIAN_SECURITY_UPDATES="${TRAVIS_DEBIAN_SECURITY_UPDATES:-true}"
		;;
esac

## Detect autopkgtest tests ###################################################

if [ -e "debian/tests/control" ] || grep -E '^(XS-)?Testsuite: autopkgtest' debian/control
then
	TRAVIS_DEBIAN_AUTOPKGTEST="${TRAVIS_DEBIAN_AUTOPKGTEST:-true}"
else
	TRAVIS_DEBIAN_AUTOPKGTEST="${TRAVIS_DEBIAN_AUTOPKGTEST:-false}"
fi

## Print configuration ########################################################

Info "Using distribution: ${TRAVIS_DEBIAN_DISTRIBUTION}"
Info "Backports enabled: ${TRAVIS_DEBIAN_BACKPORTS}"
Info "Experimental enabled: ${TRAVIS_DEBIAN_EXPERIMENTAL}"
Info "Security updates enabled: ${TRAVIS_DEBIAN_SECURITY_UPDATES}"
Info "Will use extra repository: ${TRAVIS_DEBIAN_EXTRA_REPOSITORY:-<not set>}"
Info "Extra repository's key URL: ${TRAVIS_DEBIAN_EXTRA_REPOSITORY_GPG_URL:-<not set>}"
Info "Will build under: ${TRAVIS_DEBIAN_BUILD_DIR}"
Info "Will store results under: ${TRAVIS_DEBIAN_TARGET_DIR}"
Info "Using mirror: ${TRAVIS_DEBIAN_MIRROR}"
Info "Network enabled during build: ${TRAVIS_DEBIAN_NETWORK_ENABLED}"
Info "Builder command: ${TRAVIS_DEBIAN_GIT_BUILDPACKAGE}"
Info "Builder command options: ${TRAVIS_DEBIAN_GIT_BUILDPACKAGE_OPTIONS}"
Info "Increment version number: ${TRAVIS_DEBIAN_INCREMENT_VERSION_NUMBER}"
Info "Run autopkgtests after build: ${TRAVIS_DEBIAN_AUTOPKGTEST}"
Info "DEB_BUILD_OPTIONS: ${DEB_BUILD_OPTIONS:-<not set>}"

## Increment version number ###################################################

if [ "${TRAVIS_DEBIAN_INCREMENT_VERSION_NUMBER}" = true ]
then
	cat >debian/changelog.new <<EOF
${SOURCE} (${VERSION}+travis${TRAVIS_BUILD_NUMBER}) UNRELEASED; urgency=medium

  * Automatic build.

 -- travis.debian.net <nobody@nobody>  $(date --utc -R)

EOF
	cat <debian/changelog >>debian/changelog.new
	mv debian/changelog.new debian/changelog
	git add debian/changelog
	git commit -m "Incrementing version number."
fi

## Build ######################################################################

#cat >Dockerfile.PG <<EOF
#FROM debian:jessie
#RUN echo "deb http://ftp.de.debian.org/debian jessie main" > /etc/apt/sources.list
#RUN echo "deb-src http://ftp.de.debian.org/debian jessie main" >> /etc/apt/sources.list
#RUN echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
#RUN echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
#RUN echo "deb http://pkg.yeti-switch.org/debian/jessie unstable main ext" >> /etc/apt/sources.list
#RUN apt-key adv --keyserver keys.gnupg.net --recv-key 9CEBFFC569A832B6
#RUN apt-get update && apt-get dist-upgrade --yes
#RUN apt-get install --yes --no-install-recommends postgresql-9.4 postgresql-9.4-pgq3 postgresql-9.4-prefix postgresql-9.4-yeti postgresql-contrib-9.4 libpq5
#
#WORKDIR /home/travis/build/dmitry-sinina/yeti-web
#COPY . .
#
#USER postgres
#RUN  service postgresql start && psql -f ci/prepare-db.sql
#EXPOSE 5432
#CMD service postgresql start
#EOF
#
#docker build --tag="yeti-switch.org/yeti-postgresql" --file Dockerfile.PG .
#docker ps
#docker run -p 127.0.0.1:5432:5432 "yeti-switch.org/yeti-postgresql"
#docker ps

cat >Dockerfile <<EOF
FROM debian:jessie
RUN echo "deb http://ftp.de.debian.org/debian jessie main" > /etc/apt/sources.list
RUN echo "deb-src http://ftp.de.debian.org/debian jessie main" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
RUN echo "deb http://pkg.yeti-switch.org/debian/jessie unstable main ext" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 9CEBFFC569A832B6
RUN apt-get update && apt-get dist-upgrade --yes
RUN apt-get install --yes --no-install-recommends build-essential devscripts git-buildpackage ca-certificates debhelper fakeroot lintian ruby2.3 python-jinja2 ruby2.3-dev python-yaml libpq5 zlib1g-dev libpq-dev libxslt-dev libxml2-dev python-psycopg2

RUN apt-get install --yes --no-install-recommends postgresql-9.4 postgresql-9.4-pgq3 postgresql-9.4-prefix postgresql-9.4-yeti postgresql-contrib-9.4 libpq5
EXPOSE 5432

WORKDIR /home/travis/build/dmitry-sinina/yeti-web
COPY . .

RUN rm -f Dockerfile
RUN git checkout .travis.yml || true
RUN mkdir -p /build
RUN service postgresql start&& su postgres -c"psql -f ci/prepare-db.sql"
RUN cp config/database.yml.distr config/database.yml
RUN service postgresql start&& ./aux/yeti-db --config config/database.yml --sql-dir sql --yes init > /dev/null
RUN service postgresql start&& ./aux/yeti-db --config config/database.yml --sql-dir sql --yes --cdr init > /dev/null
RUN service postgresql start&& ./aux/yeti-db --config config/database.yml --sql-dir sql --yes apply_all > /dev/null
RUN service postgresql start&& ./aux/yeti-db --config config/database.yml --sql-dir sql --yes --cdr apply_all > /dev/null
CMD service postgresql start&&export GEMRC=".gemrc"&&make package
EOF

Info "Using Dockerfile:"
sed -e 's@^@  @g' Dockerfile

TAG="travis.debian.net/${SOURCE}"

Info "Building Docker image ${TAG}"
docker build --tag="${TAG}" .

Info "Removing Dockerfile"
rm -f Dockerfile

CIDFILE="$(mktemp --dry-run)"
ARGS="--cidfile=${CIDFILE}"

Info "Running build"
# shellcheck disable=SC2086
docker run --env=DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:-}" ${ARGS} "${TAG}"

Info "Copying build artefacts to ${TRAVIS_DEBIAN_TARGET_DIR}"
mkdir -p "${TRAVIS_DEBIAN_TARGET_DIR}"
docker cp "$(cat "${CIDFILE}")":"${TRAVIS_DEBIAN_BUILD_DIR}"/ - \
	| tar xf - -C "${TRAVIS_DEBIAN_TARGET_DIR}" --strip-components=1


Info "Removing container"
docker rm "$(cat "${CIDFILE}")" >/dev/null
rm -f "${CIDFILE}"

Info "Build successful"
ls -la "${TRAVIS_DEBIAN_TARGET_DIR}"

