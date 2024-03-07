#!/bin/bash

function usage {
	echo "Usage: $0 [branch|pr] BRANCH_OR_PR"
	exit 1
}

set -x

if [ -z "$2" ]; then
	usage
fi

case $1 in
	branch) BRANCH="$2" ;;
	pr) PR="$2" ;;
	*) usage ;;
esac

cd ${GRADEBOOK_DIR}
git clone https://github.com/gradebook-dev/gradebook-app
cd gradebook-app

if [ -n "${BRANCH}" ]; then
	git checkout ${BRANCH}
else
	git fetch origin pull/${PR}/head:pull-${PR}
	git switch pull-${PR}
fi
