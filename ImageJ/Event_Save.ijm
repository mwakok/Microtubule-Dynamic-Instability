// Save the events 
//
// How To:
// 1) Load a single kymograph (created with "Kymo_Save.ijm") 
// 2) Create traces of each growth event in the kymograph
// 3) Run this script to save the coordin ates of each event
//-------------------------------------------------------------

imageName = getTitle;
imageName = replace(imageName,".tif","");

pathName = "K:\\bn\\mdo\\Shared\\Maurits\\DATA\\2019-07-11 - MT fluctuations\\Analysis\\Events\\";
//pathName = getDirectory("Select Output directory");


list = getFileList(pathName);
count = lengthOf(list);

for (i=0; i<roiManager("count"); i++){

	roiManager("Select", i);
	num = count + i + 1;
	file = pathName + imageName + "_Event_" + num + ".txt";

	roiManager("Set Line Width", 1);
	saveAs("XY Coordinates", file);

}
roiManager("deselect");
roiManager("delete");
close();