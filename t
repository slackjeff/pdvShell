#!/usr/bin/env bash

for ((i = 1; i <= 100; i++)); do
	if [[ $(($i%5)) -eq 0 ]]; then
            echo $i
     fi
    done


