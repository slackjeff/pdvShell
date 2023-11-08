#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091,SC2039,SC2166


for i in {0..400}; do
	echo "$i - $(tput setab $i) COLOR; $(tput sgr0)"
done
