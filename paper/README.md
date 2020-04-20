# COVID-19 Healthcare Surge Model for Greater Toronto Area Hospitals

This folder contains the code and data used to run the model and generate
figures for the manuscript.

TODO: add citation

## Description of R code

### Generating parameter files

**Note:** the necessary parameter files for running the model are already available in the data folder. See [the description of data files](#description-of-data-files) for more information.

| File | Description |
| ---- | ----------- |
| [**`sample_parms.R`**](./code/sample_parms.R) | Starting point for creating parameter files. Reads in the data file of parameter ranges and value for sampling and calls the helper functions to output the parameter files: `ParmSet_Default.csv`, `OneWaySens_ParmList.csv`, `LHS_int_fix_drop_Reffective.csv` |
| [`Full_LHS_fix.R`](./code/Full_LHS_fix.R) | Creates a matrix of parameter values using Latin hypercube sampling. |
| [`makeParmFile.R`](./code/makeParmFile.R) | Calculates the necessary parameters for the model and performs validity checks. Saves the final parameter file in the specified file. |

### Running the model

| File | Description |
| ---- | ----------- |
| [**`covid_modelphase1.R`**](./code/covid_modelphase1.R) | Starting point for running the model and generating outputs. Calls the other files to load in the correct parameter set. |
| [`covid_model_det.R`](./code/covid_model_det.R) | Defines the deterministic, compartmental surge model and defines the ODEs based on provided parameters. |
| [`epid.R`](./code/epid.R) | Defines the initial states of the model and calls the `deSolve` package to solve the ODEs. |
| [`RunParmsFile.R`](./code/RunParmsFile.R) | Reads in the provided parameters file and calls the `epid` function to perform the simulation. This file can run both the regular model and sensitivity analyses. |

### Creating the figures
| File | Description |
| ---- | ----------- |
| [`Figure 2 & 3.R`](./code/Figure%202%20&%203.R) | Creates: <li> **Figure 2:** Cumulative detected cases across simulated epidemic scenarios and observed data used for epidemic constraints. <li> **Figure 3:** Incident epidemic curves and health-care needs in the Greater Toronto Area (GTA) across three scenarios: default, fast/large, slow/small epidemics. |
| [`Figure 4 & 5.R`](./code/Figure%204%20&%205.R) | Creates: <li> **Figure 4:** Estimated surge and capacity for hospitalization at two acute care hospitals in the Greater Toronto Area. <li> **Figure 5:** Estimated surge and capacity for intensive care at two acute care hospitals in the Greater Toronto Area. <br> **Note:** These figures require access to data from St. Michael's Hospital and St. Joseph's Health Centre in Toronto.  |
| [`Figure 6.R`](./code/Figure%206.R) | Creates: <li> **Figure 6:** One-way sensitivity analyses using default epidemic scenario for prevalence of non-ICU and ICU inpatients with COVID-19 at St. Michael’s Hospital |

## Description of data
TODO
