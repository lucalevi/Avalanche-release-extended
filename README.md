# What is it?

Avalanche bulletins use graphics, text and icons in order to (qualitatively) inform about avalanche hazard, but it lacks detailed geographical evidence that localises the truly dangerous areas. Attempting to overcome this limitation, a numerical model was developed to support avalanche forecasters: it automatically visualises and quantifies dangerous areas, thus providing objective data, by calculating slab avalanches release propensity according to current snow and weather conditions. The model extends an existing algorithm; its parameters were determined by analisyng avalanche bulletins and through a survey addressed to professionals. Several parameters have been integrated, such as snowpack stability, dangerous aspects and altitudes, and a snow cover mask with changeable boundaries; furthermore, the model calculates the amount of dangerous steep slopes in a given area. 
"The algorithm produces a raster map (asci format) which values ranging from 0 to 1. A value of 0 indicates locations where avalanches are not possible to release whereas a value of 1 corresponds to locations that are highly favourable for avalanche release." (from https://github.com/jocha81/Avalanche-release )
The tool wants to be a help for avalanche forecasters.

## Why two R files?

PRA_R.r is the original algorithm upon which the extended one (pra_R_LI.r) is based.
The first one is the same you can find at this link https://github.com/jocha81/Avalanche-release 
	
## License Agreement:
The code is licensed under the open-source GNU GPL version 3 license. 
The only restriction if you want to redistribute the source code is:
- you must provide access to the source code,
- you must license derived work under the same GPL v3 license

## Citation
If the original tool (PRA_R.r) is used in a scientific publication, please cite the following paper:
Veitinger, J., Purves, R. S., and Sovilla, B.: Potential slab avalanche release area identification from estimated winter terrain: a multi-scale, fuzzy logic approach, Nat. Hazards Earth Syst. Sci. Discuss., 3, 6569-6614, doi:10.5194/nhessd-3-6569-2015, 2015. 

Whereas if the extended tool is used (pra_R_LI.r), please cite the following thesis:
Iacolettig, L. (2017): La pericolosità da valanga calcolata e visualizzata. Un modello numerico-geografico, Master's Thesis, University of Udine, doi:10.13140/RG.2.2.27066.18880 
