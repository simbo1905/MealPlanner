#!/bin/bash
. "$(dirname "$0")/load_env.sh"
dart --enable-experiment=dot-shorthands "$@"
