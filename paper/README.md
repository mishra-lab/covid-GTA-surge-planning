# COVID-19 Healthcare Surge Model for Greater Toronto Area Hospitals

This folder contains the code and data used to run the model and generate
figures for the manuscript.

TODO: add citation

## Breakdown of model code

| File | Description |
| ---- | ----------- |
| [**`covid_modelphase1.R`**](./code/covid_modelphase1.R) | Starting point for running the model. Calls the other files to load in the correct parameter set and. |
| [`covid_model_det.R`](./code/covid_model_det.R) | Defines the deterministic, compartmental surge model and defines the ODEs based on provided parameters. |
| [`epid.R`](./code/epid.R) | Defines the initial states of the model and calls the `deSolve` package to solve the ODEs. |
| [`RunParmsFile.R`](./code/RunParmsFile.R) | Reads in the provided parameters file and calls the `epid` function to perform the simulation. This file can run both the regular model and sensitivity analyses. |

## TODO: Description of data files

## TODO: Breakdown of figure code
