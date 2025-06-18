#!/bin/dash

download() {
  lgogdownloader \
    --wait 100 \
    --download \
    --language en+de \
    --include-hidden-products \
    --size-only \
    --save-serials \
    --save-changelogs \
    --"$1"
}

if [ ! -f "${HOME}/.cache/lgogdownloader/gamedetails.json" ]; then
  lgogdownloader --update-cache
fi

if [ "$1" = "all" ]; then
  lgogdownloader \
    --use-cache \
    --wait 100 \
    --download \
    --language en+de \
    --include-hidden-products \
    --save-changelogs \
    --save-serials
else
  download new || exit 1
  download updated || exit 1
  lgogdownloader --clear-update-flags
fi

lgogdownloader \
  --check-orphans \
  --delete-orphans \
  --use-cache
