#!/bin/sh -l

cd ./src/

echo 'Installing R packages...'
Rscript ./scripts/install_deps.R

echo "Running deployment script..."
Rscript ./scripts/deploy_app.R