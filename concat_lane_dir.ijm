macro "concat_lane_dir" {// This script allows you to open a lane directory and concatenate the position files
// into one stack

// TODO: need to compartmentalize this into a module that can be used by other scripts
function get_root(){
	root = "/Users/adrian/Documents/research/images/"
	Dialog.create("Choose Lan Directory");
	Dialog.addDirectory("LN dir: ", root);
	Dialog.show();
	
	root = Dialog.getString();
	return root;
}
function get_file_list(root){
	file_list = getFileList(root);
	return file_list;
}

// Only have to do this because we have to specify array sizes so stupid
function count_images_in_dir(files){
	image_count = 0;
	for (i=0; i<lengthOf(files); i++){
		if (endsWith(files[i], ".tif")){
			image_count++;
		}
	}
	return image_count;	
}

function get_images_in_dir(files){
	image_list = newArray(count_images_in_dir(files));
	//print("Images: " + lengthOf(image_list));
	for (i=0; i<lengthOf(files); i++){
		if (endsWith(files[i], ".tif")){
			//print("Adding: " + files[i]);
			image_list[i] = files[i];
		}
	}
	return image_list;
}

function concat_positions(){
	root = get_root();
	file_list = get_file_list(root);
	//print("File list");
	//Array.print(file_list);

	image_list = get_images_in_dir(file_list);
	//print("Tif list");
	//Array.print(image_list);
	
	
	// TODO: this needs to become more generalized and we need to be more consistent with naming
	// experiments or to create a better preprocessing script
	//print(image_list[0]);
	split_dot = split(image_list[0],".");
	no_ext = split_dot[0];
	//print(no_ext);
	image_name_tokens = split(no_ext,"_");
	//Array.print(image_name_tokens);
	prefix = image_name_tokens[0];
	lane_num = image_name_tokens[1];
	
	for (i=0; i<lengthOf(image_list); i++){
		open(image_list[i]);
	}
	image_title = prefix + "_" + lane_num;
	stack_path = root+image_title+".tif";
	if(!File.exists(stack_path)){
		print(stack_path + " does not exist! Creating...");
		run("Concatenate...", "all_open "+ "title=" + image_title + " open");

		//TODO: should we create a dir to store the original positions?
		// might change the file exists logic...
		
		setVoxelSize(1, 1, 1, "pixel");
		saveAs(stack_path);
	}else{
		print(stack_path + " already exists! Opening...");
		close("*");
		open(stack_path);
	}
	return root;
}

root = concat_positions();
return root;
} 