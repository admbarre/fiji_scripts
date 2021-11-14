function generate_prom_counts(increment,max_p){
	// This function uses the results table to store counts information
	//	before copying into an array. Not sure if there is a work around to this
	run("Clear Results");

	// TODO: this might need to be adjusted dynamically based on image
	//		histogram parameters or whateva
	max_prominence = max_p;
	for (i = 0; i < max_prominence; i+=increment) {
		options = "prominence=" + i + " output=Count";
		run("Find Maxima...", options);
	}

	counts = newArray(nResults);
	for(i=0; i<nResults; i++) {
		counts[i] = getResult("Count", i);
	}
	return counts;
}

function get_ideal_prominence(increment, max_p){
	counts = generate_prom_counts(increment,max_p);
	mode_count = mode(counts);
	ideal_prom = find_first(mode_count, counts) * increment;
	//print("The ideal prominence yielding " + mode_count + " counts is: " + ideal_prom);
	return ideal_prom;
}

function find_first(target, array){
	//print("Searching for " + target + " in array...");
	for (i=0; i < lengthOf(array); i++){
		if (array[i] == target){
			return i;
		}
	}
	return -1;
}

function mode(array){
	Array.getStatistics(array, min, max, mean, stdDev);
	//print(max);
	mode_array = newArray(max+1);
	for (i = 0; i < lengthOf(counts); i++){
			mode_array[counts[i]] += 1;
	}
	
	ranks = Array.rankPositions(mode_array);
	ranks = Array.reverse(ranks);
	the_mode = ranks[0];
	return the_mode;
}

function generate_derivatives(channel){
	//save_dir = "/Users/adrian/code/lab/fiji_scripts/logs/";
	save_dir = "/Users/adrian/code/lab/fiji/logs/";
	
	//THIS method might be unnecessary if mode method works better
	print("\\Clear"); //Clear the Log here just get the Log window up
	selectWindow("Log");
	counts = newArray(nResults);
	for(i=0; i<nResults; i++) {
		counts[i] = getResult("Count", i);
	}
	Array.print(counts);
	saveAs("Text", save_dir+channel+"_counts.txt"); 
	print("\\Clear");

	log_counts = newArray(lengthOf(counts));
	for (i=0; i<lengthOf(log_counts); i++){
		log_counts[i] = Math.log10(counts[i]);
	}
	Array.print(log_counts);
	saveAs("Text", save_dir+channel+"_log_counts.txt");
	print("\\Clear");
	
	
	first_deriv = newArray(lengthOf(log_counts)-1);
	for(i=1; i<lengthOf(first_deriv); i++){
		first_deriv[i-1] = log_counts[i] - log_counts[i-1];
	}
	Array.print(first_deriv);
	saveAs("Text", save_dir+channel+"_first_deriv.txt"); 
	print("\\Clear");
	
	second_deriv = newArray(lengthOf(first_deriv)-1);
	for(i=1; i<lengthOf(first_deriv); i++){
		second_deriv[i-1] = first_deriv[i] - first_deriv[i-1];
	}
	Array.print(second_deriv);
	saveAs("Text", save_dir+channel+"_second_deriv.txt");
	print("\\Clear"); 
}

function get_counts(ch, frame,increment,max_p, save_results){
	roiManager("reset");
	// TODO: the ROIs are being placed on the wrong frame for some reason, need to troubleshooot
	// NOTE: only the first position is being mislabeled as second frame, might be a zero indexing
	//		issue?

	Stack.setChannel(ch);
	Stack.setFrame(frame); 
	idp = get_ideal_prominence(increment,max_p);
	
	// Need to clear results of prominence counts to get single count from 
	// actual run with idp
	run("Clear Results");
	count_options = "prominence=" + idp + " output=Count";
	run("Find Maxima...", count_options);
	// Sadly bc how we iterate we only get one pos count at a time
	count = getResult("Count", 0);


	// TODO: SOMETHING HERE IS CONCATENATING THE STACK WITH ITSELF
	if (save_results == true){		
		roi_options = "prominence=" + idp + " output=[Point Selection]";
		run("Find Maxima...", roi_options);
		run("Clear Results");
		roiManager("add");
		roiManager("measure");

		// This is some ugly as sin coupling to global variables needs fixing
		
		fpath = cell_channels[ch-1]+"_pos"+frame;
		
		// NOTE: we don't really need to measure anything besides the counts...
		//saveAs("results",results_dir + "CH" + ch +"/" + fpath +  "_results.csv");
		roiManager("save", rois_dir + "CH" + ch +"/" + fpath + "_roi.zip");
	}
	return count;	
}

personal_script_dir = "/Users/adrian/code/lab/fiji_scripts/";
current_dir = runMacro(personal_script_dir + "concat_lane_dir.ijm");


// TODO: change this?
//save_dir = "/Users/adrian/code/lab/fiji_scripts/logs/";
save_dir = "/Users/adrian/code/lab/fiji/logs/";

// TODO: needs to be compartmentalized better as individual tools/methods/macros

// ch1 = Blue
// ch2 = Red
// ch3 = Far Red
// ch4 = Brightfield

// TODO: need to make a function for setting the channels
channels = 1;
fluor_channels = newArray("blue", "red", "far_red");
cell_channels = newArray("jurkat", "lag16psgl_tether", "lag16icam");

// Annotation directory structure example:
// comp annotation
//	-> results
//		-> CH1
//			->pos0
//			->pos1
//		-> CH2
//		-> CH3
//	->rois
//		-> CH1
//			->pos0
//			->pos1
//		-> CH2
//		-> CH3

annotations_dir = current_dir + "comp_annotations/";
rois_dir = annotations_dir + "rois/";
results_dir = annotations_dir + "results/";

if (!File.exists(annotations_dir)){
	print("Creating annotation dir");
	File.makeDirectory(annotations_dir);
}
if (!File.exists(rois_dir)){
	print("Creating roi dir");
	File.makeDirectory(rois_dir);
}
if (!File.exists(results_dir)){
	print("Creating results dir");
	File.makeDirectory(results_dir);
}

for (i=1; i<=lengthOf(cell_channels); i++){
	results_ch_dir = results_dir+"CH"+i;
	if (!File.exists(results_ch_dir)){
		File.makeDirectory(results_ch_dir);
	}
	
	rois_ch_dir = rois_dir+"CH"+i;
	if (!File.exists(rois_ch_dir)){
		File.makeDirectory(rois_ch_dir);
	}
}

// TODO: figure out how to dynamically determine best radius
// TODO: this needs to NOT be applied to brightfield
// NOTE: is this better after or before blur?

// This did not seem to impact annotation of red much
// Check prominence range tweaking first
//run("Subtract Background...", "rolling=20");
	
// NOTE: this only needs to be run once per stack but should not be in
// the concat lane function because of separation of responsibilities
run("Gaussian Blur...", "sigma=1 stack");

//cell_channels = newArray("jurkat", "lag16psgl_tether", "lag16icam");
Stack.getDimensions(width, height, channels, slices, frames);
positions = frames;
for (ch=1; ch <=lengthOf(cell_channels); ch++){
	channel_counts = newArray(positions+1); // Will hold the counts
	channel_counts[0] = cell_channels[ch-1]; // Add the name of the channel
	for (pos=1; pos <= positions; pos++){
		// THIS IS THE MAIN CALL
		// Try to dynamically set the max_p for each channel?
		// Not sure what the theory would be here, might need to analyze histogram
		channel_counts[pos] = get_counts(ch,pos,5,500,true);
	}

	current_ch_dir = results_dir + "CH" + ch + "/";
	print("\\Clear");
	Array.print(channel_counts);
	selectWindow("Log");
	saveAs("Text", current_ch_dir+cell_channels[ch-1]+"_pos_counts.txt");
}

// NOTES: This is working! but the far red channel requires some tweaking
//	it seems like the prominence is being set too high to distinguish
//	and we are undersampling. Maybe we need to tweak the max prominence we scale to
//	or add some new preprocessing features.
// 	probably need to do some more background subtraction