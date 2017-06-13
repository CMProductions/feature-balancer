#!/bin/bash

function test {
  PHP="php-$1"
  $PHP bin/phpspec run
}

for version in 5.5 5.6 7.0 7.1; do
  echo "Testing PHP $version"
  test $version
done