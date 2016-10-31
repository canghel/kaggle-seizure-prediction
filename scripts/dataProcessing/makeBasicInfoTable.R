### makeTableResponses.R ######################################################
# make a .txt file of filenames and the responses

### PREAMBLE ##################################################################

library(R.matlab);
dataPath <- file.path("..", "..", "data"); 
outputPath <- file.path("..", "..", "output", "dataProcessing"); 

### LOAD FILENAMES ############################################################

trainDatasets <- c('train_1', 'train_2', 'train_3');

for (patient in 1:3){

	# names of files
	filenames <- dir(
		path = file.path(dataPath, trainDatasets[patient]),
		# match all files with given pattern
		pattern = ".*.mat",
		# return only names of visible files
		all.files = FALSE,
		# return only file names, not relative file paths
		full.names = FALSE,
		# assume all are in given directory, not in any subdirectories
		recursive =	FALSE,
		ignore.case =TRUE
	);

	# responses
	response <- str_sub(filenames,-5,-5);

	dataTable <- data.frame(
		names = filenames,
		response = response
		);

	### LOAD FRACTION OF ZEROS ################################################

	### WRITE TO FILE #########################################################

	write.table(dataTable, 
		file = file.path(outputPath, paste0(Sys.Date(), "-", trainDatasets[patient], "_basicInfo.csv")), 
		quote = FALSE, 
		sep = ",",
		row.names = FALSE,
		col.names = TRUE
  );
}