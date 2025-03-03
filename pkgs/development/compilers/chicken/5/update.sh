#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=../../../../.. -i ysh -p oils-for-unix chicken

setglobal ENV.URL_PREFIX="https://code.call-cc.org/egg-tarballs/5/"
cd $(nix-prefetch-url \
     'https://code.call-cc.org/cgi-bin/gitweb.cgi?p=eggs-5-latest.git;a=snapshot;h=master;sf=tgz' \
     --name chicken-eggs-5-latest --unpack --print-path | tail -1)

echo "# THIS IS A GENERATED FILE.  DO NOT EDIT!" > $_this_dir/deps.toml
for i, item in */*/*.egg {
  setglobal ENV.EGG_NAME=$(dirname $(dirname $item))
  setglobal ENV.EGG_VERSION=$(basename $(dirname $item))
  setglobal ENV.EGG_URL="$[ENV.URL_PREFIX]$[ENV.EGG_NAME]/$[ENV.EGG_NAME]-$[ENV.EGG_VERSION].tar.gz"
  setglobal ENV.EGG_SHA256=$(nix-prefetch-url $[ENV.EGG_URL])
  csi -s $_this_dir/read-egg.scm < $item
} >> $_this_dir/deps.toml
