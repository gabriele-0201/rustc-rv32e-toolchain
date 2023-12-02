#!/usr/bin/env bash

param1=${1:-}
param2=${2:-}

# if $param1 == '-rust_commit' -> just export the commit
# if $param1 == '-host' || $param1 == '-aarch64' then $param2 could be "-artifact_name"

export RUST_COMMIT=8d321f7a88f0ae27793c133390e507bf1f49125a

# If -rust_commit specified then only export the rust commit variable
if [ "$param1" == "-rust_commit" ]; then
  return
fi

if [ "$param1" == "-rust_commit" ]; then
  export TOOLCHAIN_HOST_TRIPLET=$(rustc --version --verbose | grep 'host: ' | sed -r 's/host: (.*)/\1/')
elif [ "$param1" == "-aarch64" ]; then
  export TOOLCHAIN_HOST_TRIPLET=aarch64-apple-darwin
else
  return
fi

echo $TOOLCHAIN_HOST_TRIPLET
return

cd rust
git show --no-patch --format=%ci $RUST_COMMIT > commit_show_output
commit_show_output=$(cat commit_show_output)
rm commit_show_output
cd ../

regex='([0-9]{4}-[0-9]{2}-[0-9]{2})'
if [[ $commit_show_output =~ $regex ]]; then
  rust_commit_date="${BASH_REMATCH[1]}"
else
  echo "Impossible extracting date from rustc commit"
  exit 1
fi

export TOOLCHAIN_VERSION=nightly-$rust_commit_date-r$(cat release_number)

export TOOLCHAIN_NAME=riscv32em-$TOOLCHAIN_VERSION-$TOOLCHAIN_HOST_TRIPLET
export ARTIFACT_NAME=rust-$TOOLCHAIN_NAME
# test
echo $ARTIFACT_NAME

if [ "$param2" == "-artifact_name" ]; then
    echo "ARTIFACT_NAME=$ARTIFACT_NAME" >> $GITHUB_ENV
fi

