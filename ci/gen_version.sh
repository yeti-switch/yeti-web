#!/bin/bash
if git describe --tags --exact &>/dev/null; then
	if [ "$PACKAGE_TYPE" = "nightly" ]; then
		git describe --tags --exact | sed 's/$/+nightly0/'
	else
		git describe --tags --exact
	fi
else
	git describe --tags | sed -E 's/-([0-9]+)-[^-]*$/+nightly\1/'
fi
