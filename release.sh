#!/bin/bash

git checkout main

curl -s 'https://pypi.org/pypi/woob/json' | jq -j -r '.info.version' > woob_version
curl -s 'https://registry.npmjs.org/kresus/latest' | jq -j -r '.version' > kresus_version

git add -A
git commit -m "Version update"
git push origin main
git tag `cat kresus_version`-`cat woob_version`
git push origin `cat kresus_version`-`cat woob_version`

exit 0
