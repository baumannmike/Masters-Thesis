# Masters-Thesis
# Supplementary MATLAB Code

This repository contains the MATLAB scripts used for the data processing, basal-friction inversion, analysis of the contributing terms, and rheological model evaluation presented in this thesis.

The code is organised into the following main sections:

## 1. Friction Inversion

Contains the MATLAB scripts used to process the LiDAR-derived flow data and reconstruct the effective basal friction coefficient. The scripts include the calculation of hydraulic and kinematic variables, spatial and temporal derivatives, filtering, smoothing, and the basal-friction inversion.

Measurement-specific processing parameters are retained in the corresponding MATLAB scripts to document the settings used for the individual measurements.

## 2. Dominating Factors

Contains the scripts used to analyse the individual terms contributing to the basal-friction inversion. These scripts were used to quantify the relative contribution of the different terms of the depth-averaged momentum balance to the temporal variability of the reconstructed basal friction signal.

## 3. Rheology

Contains the MATLAB scripts used to evaluate and compare the rheological formulations considered in this thesis:

* Voellmy
* Manchester
* Power-law

The scripts include the calculation of modelled basal friction and the quantitative comparison with the reconstructed friction signal using the sum of squared errors (SSE).

## Data and Reproducibility

The repository contains the MATLAB code and measurement-specific parameter settings used in the analysis. The original LiDAR point-cloud data and processed project data are not included due to their size and/or project-specific data-access restrictions.

The scripts were developed and executed in MATLAB. Some scripts require project-specific utility functions and input data structures that are not included in this repository.

The repository is provided as supplementary material to document the computational workflow and improve the reproducibility of the analyses presented in this thesis.
