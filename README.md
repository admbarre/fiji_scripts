# fiji_scripts
My personal collection of FIJI/ImageJ scripts and their descriptions/future aims as well as issues (should eventually do this through git issues I guess...)

## concat_lane_dir
GUI to select **lane directory**of interest, concatenate position files into one stack, and edit image properties.

Future Aims
1. Allow for selection of **experiment directory**, and concatenating all lane directories inside.

## maxima_elbow
Runs on an image stack. Pre-processes stack and then iteratively runs FIJIs "Find Maxima" plugin to find ideal prominence value to
point pick with. Repeats process for each position in each channel. Saves point pick counts in a **results** folder for each channel, as
well as ROI files for each position in an **rois** folder.

Future Aims:
1. Selecting ideal prominence value:
    + Dynamically determine max prominence search range as this seems to greatly influence efficiency of this process.
2. Saving results:
    + Give a more descriptive name to the results file for updating database with.
3. Updating database:
    + Write a script (could be in python) to iterate through an experiment directory and add all results to database (without creating duplicates).
4. ROI and result validation:
    + Write a script to load all ROIs (computer and manually generated) onto the current stack for visual validation.
    + Write a script to validate ROIs unsupervised and generate (True/False) (Positive/Negative) table and efficiency.
    + Write a GUI to allow user to validate/add points live.
    
Issues:
1. Saving ROI and results by running "Find Maxima" twice is duplicating and concatenating stack with itself
2. First position ROI is being saved as second position (might be zero indexing issue?)
