# What is it?

Avalanche bulletins use graphics, text and icons in order to inform about avalanche hazard, but detailed geographical evidence that localises the truly dangerous areas lacks. 
Attempting to overcome this limitation, a numerical model was developed to support avalanche forecasters: it automatically visualises and quantifies dangerous areas free of human bias, by calculating the release propensity of slab avalanches according to current snow and weather conditions. 

## Why two R files?
The model PRA_new.R extends the existing algorithm PRA_R.r.
Original code at https://github.com/jocha81/Avalanche-release 

The parameters of the extended model were determined analisyng avalanche bulletins and with a professioanl survey. Several parameters have been integrated: snowpack stability, dangerous aspects and altitudes, and a snow cover mask with aspect-varying boundaries. The model calculates finally the amount of dangerous steep slopes in a given area. 

Citing from the original readme, "The algorithm produces a raster map (asci format) which values ranging from 0 to 1. A value of 0 indicates locations where avalanches are not possible to release whereas a value of 1 corresponds to locations that are highly favourable for avalanche release."

Both the original and the extended tool help avalanche practictioners in their forecasting activity.



## License Agreement:
The code is licensed under the open-source GNU GPL version 3 license. 
The only restriction if you want to redistribute the source code is:
- you must provide access to the source code,
- you must license derived work under the same GPL v3 license

## Citation
If the original tool (PRA_R.r) is used in a scientific publication, please cite the following paper:
Veitinger, J., Purves, R. S., and Sovilla, B.: Potential slab avalanche release area identification from estimated winter terrain: a multi-scale, fuzzy logic approach, Nat. Hazards Earth Syst. Sci. Discuss., 3, 6569-6614, doi:10.5194/nhessd-3-6569-2015, 2015. 

If the extended tool is used instead (PRA_new.r), please cite the following thesis:
Iacolettig, L. (2017): La pericolosità da valanga calcolata e visualizzata. Un modello numerico-geografico, Master's Thesis, University of Udine, doi:10.13140/RG.2.2.27066.18880 
