#!/bin/sh -l

echo "Installing R..."
apt-get update
apt-get install -y r-base r-base-dev r-cran-littler

echo "Setting up shinyapps env..."
# TODO: do we need this?

echo "Running deploy_app.R..."
cd ../src/
Rscript ./scripts/deploy_app.R