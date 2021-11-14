macro "Get Ideal Prominence"{
	function generate_prom_counts(increment,max_p){
		// This function uses the results table to store counts information
		//	before copying into an array. Not sure if there is a work around to this
		run("Clear Results");
	
		// TODO: this might need to be adjusted dynamically based on image
		//		histogram parameters or whateva
		max_prominence = max_p;
		proms = newArray(max_p /increment);
		for (i = 0; i < max_prominence; i+=increment) {
			proms[i/increment] = i; // This might cause issues
			options = "prominence=" + i + " output=Count";
			run("Find Maxima...", options);
		}
	
		// Reads in counts results table into an array
		counts = newArray(nResults);
		for(i=0; i<nResults; i++) {
			counts[i] = getResult("Count", i);
		}

		// Maybe if we returned prominence vs counts this could be more useful
		// Rather than just internally using increment and index position to determine
		// Prominence
		return counts;
	}
	
	function get_ideal_prominence(increment, max_p){
		// Generates Prominence vs Counts table
		// The idea is that we iteratively increase the prominence to separate
		// points from background more and more but we will eventually hit diminishing returns
		// The value that this function eventually settles on >>I THINK<< is the ideal
		
		counts = generate_prom_counts(increment,max_p);
		mode_count = mode(counts);
	
		// NOTE: there probably is a built in function to do this
		// Finds first occurrence of the "stable" count value
		// Prominence is just index position * increment used
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
	
	// NOTE: is there really not a built in mode function?
	function mode(array){
		// Can't believe this isn't a built in function??
	
		// NOTE: Not sure if there's a way to just get the max
		Array.getStatistics(array, min, max, mean, stdDev);
	
		// Building an array big enough to hold all values in the range
		// Incrementing each index position corresponding to how many it encounters
		// Huge waste of space tbh
		mode_array = newArray(max+1);
		for (i = 0; i < lengthOf(counts); i++){
				mode_array[counts[i]] += 1;
		}
	
		// Returns array of indices corresponding to decreasing values
		// Reverse array and take first position for index with max value
		ranks = Array.rankPositions(mode_array);
		ranks = Array.reverse(ranks);
		the_mode = ranks[0];
		
		return the_mode;
	}


	return get_ideal_prominence(5, 500);
}