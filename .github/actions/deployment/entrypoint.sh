#!/bin/sh -l

cd ./src/

# echo "Installing R..."
# apt-get update
# DEBIAN_FRONTEND=noninteractive apt-get install -y -q r-base r-base-core r-base-dev r-cran-littler
# apt-get install -y -q build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev

echo 'Installing R packages...'
Rscript ./scripts/install_deps.R

# echo "Setting up shinyapps env..."


echo "Running deploy_app.R..."
Rscript ./scripts/deploy_app.R