# Avalanche Release Area Identification Model

## Overview

This R script implements an algorithm for automated identification of potential avalanche release areas. It extends the original work by Jochen Veitinger and Betty Sovilla, incorporating additional parameters to enhance avalanche hazard assessment.

## What's New

The extended model (PRA_new.R) builds upon the original algorithm (PRA_R.r) by including:

- Snowpack stability analysis
- Dangerous aspects and altitudes
- Snow cover mask with aspect-varying boundaries
- Calculation of dangerous steep slopes in a given area

These additions aim to provide more comprehensive and accurate avalanche hazard assessments.

## How It Works

The algorithm produces a raster map (ASCII format) with values ranging from 0 to 1:
- 0: Locations that are not Potential Release Areas (PRAs)
- 1: Locations that are totally PRAs

This output assists avalanche practitioners in their forecasting activities by visualizing and quantifying dangerous areas without human bias.

## Usage

### Input Parameters

```R
inputRas = "nameofDTM.asc"    # Input Digital Terrain Model
outPRA = "nameofoutputPRA.asc"    # Output file name
HS = 2.3     # Snow depth in meters
smooth = "Regular"    # Smoothing type: "Regular" or "Smooth"
wind = 180    # Wind direction (N=0, W=90, S=180)
windTol = 30    # Wind tolerance
work_dir = "H:/mydocuments"    # Working directory for intermediate results
```

### Required Libraries

The script uses several R libraries. Ensure these are installed:

```R
library(sp)
library(gstat)
library(shapefiles)
library(foreign)
library(methods)
library(plyr)
library(raster)
library(RSAGA)
```

### Main Processing Steps

1. Preliminary calculations and data preparation
2. Computation of wind shelter index
3. Calculation of ruggedness at different scales
4. Correction of snow surface roughness with slope
5. Definition of membership functions for roughness, slope, and wind shelter
6. Application of fuzzy logic operator to combine factors

### Output

The script generates a raster file (specified by `outPRA`) representing the potential release areas.

## Forest Module (Optional)

There's an optional forest module. To use a forest mask (ASCII file where forest = 1, no forest = 0), uncomment the respective lines at the end of the script.

## Original Work

This script is an extension of the algorithm developed by Jochen Veitinger and Betty Sovilla. The original work can be found at: https://github.com/jocha81/Avalanche-release

## License

This code is licensed under the GNU GPL version 3 license. When redistributing:
- Provide access to the source code
- License derived work under the same GPL v3 license

## Citation

If using the original tool (PRA_R.r), please cite:

Veitinger, J., Purves, R. S., and Sovilla, B.: Potential slab avalanche release area identification from estimated winter terrain: a multi-scale, fuzzy logic approach, Nat. Hazards Earth Syst. Sci. Discuss., 3, 6569-6614, doi:10.5194/nhessd-3-6569-2015, 2015.

If using the extended tool (PRA_new.r), please cite:

Iacolettig, L. (2017): La pericolosità da valanga calcolata e visualizzata. Un modello numerico-geografico, Master's Thesis, University of Udine, doi:10.13140/RG.2.2.27066.18880

## Contributing

Contributions to improve the model are welcome. Please submit pull requests or open issues for discussion.
