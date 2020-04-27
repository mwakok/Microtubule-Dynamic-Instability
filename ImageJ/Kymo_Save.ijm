// Create and save kymographs together with the Line Coordinates
// This script requires the KymoResliceWide plugin (https://imagej.net/KymoResliceWide)
//
// How To:
// 1) Load the merged color stack  
// 2) Create line profiles of all the microtubules in the tiffs stack and store them 
//	  in the ROI manager (T)
// 3) Run this script to calculate and save all kymographs
//------------------------------------------------------------------------------------

// Select an output directory
dir = getDirectory("Choose a Directory");
// Set the width of the line
lineWidth = 11;
// Set the sample name
Sample = "Time_Merge_" 

// Calculate kymographs for each saved line profile in the ROI manager
for (n=0; n< roiManager("count"); n++) {
	
	roiManager("select", n);
	roiManager("Set Line Width", lineWidth);
	// Run the KymoResliceWide plugin
	run("KymoResliceWide ", "intensity=Maximum ignore");

	// Create appendix enumeration of filename
	if (n < 9) {
		MT_num = "00" + (n+1);		
	} else {
		MT_num = "0" + (n+1); 
	}

	// Save the kymograph
	file_Kymo = dir + Sample +  "MT_" + MT_num + ".tif";
	saveAs("Tiff", file_Kymo);
	close();
	
	// Save the line coordinates
	roiManager("Set Line Width", 1);
	file_Cor = dir + Sample + "MT_" + MT_num + ".txt"; 
	saveAs("XY Coordinates", file_Cor);
}
