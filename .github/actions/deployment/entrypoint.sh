#!/bin/sh -l

# TODO: re-enable
echo "Installing R..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y r-base r-base-dev r-cran-littler -q
apt-get install -y r-cran-rsconnect -q

echo "Setting up shinyapps env..."
# TODO: do we need this?

echo "Running deploy_app.R..."
cd ./src/
Rscript ./scripts/deploy_app.R