#!/bin/bash

rdoc="rdoc18"

if [ ! "x$1" = "x" ];
    then output=$1
else
    output="./doc/"
fi

$rdoc -t "Rubygame Documentation" -m "Rubygame" -o $output lib/rubygame/*.rb ext/rubygame/*.c
