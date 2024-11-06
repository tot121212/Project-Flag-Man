#!/bin/sh
echo -ne '\033c\033]0;Flag Man\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Flag Man.x86_64" "$@"
