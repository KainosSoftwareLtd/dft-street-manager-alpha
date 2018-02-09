#!/usr/bin/env sh

docker build --pull -t local/dft-street-manager-ux -f Dockerfile-dev .
docker run -p 3000:3000 -v $(pwd):/root/app local/dft-street-manager-ux
