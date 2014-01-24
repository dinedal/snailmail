#!/bin/bash

for img in `ls *.jpg`; do convert -density 300 -rotate 270 -resize 1200x1800! -gravity Center $img $img.pdf; done
