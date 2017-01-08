### makeTableResponses.R ######################################################
# make a .txt file of filenames and the responses

### PREAMBLE ##################################################################

library(R.matlab);
library(stringr);

### GET NUMBER OF ZEROS #######################################################

tmp <- readMat(file.path(outputPath, 'fracZero.mat'));
numZeros <- data.frame(
  files = unlist(tmp$infoTable[2]),
  fracZeros = unlist(tmp$infoTable[3])
  );
rm(tmp);
gc();

### FILES FOR TRAINING ########################################################

for (patient in 1:3){

	# get names of files
	filenames <- dir(
		path = trainDatasetsPaths[patient],
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

	# create data table
	dataTable <- data.frame(
		files = filenames,
		response = response
		);

	### GET FRACTION OF ZEROS #################################################

	numZerosSubset <- numZeros[which(numZeros$files %in% dataTable$files),];
	dataTable <- merge(dataTable, numZerosSubset, by.x='files', by.y='files')

	### WRITE TO FILE #########################################################

	write.table(dataTable, 
		file = file.path(outputPath, paste0(trainDatasets[patient], "_basicInfo.csv")), 
		quote = FALSE, 
		sep = ",",
		row.names = FALSE,
		col.names = TRUE
	);
}

### TEST DATASETS #############################################################
# kind of bad coding, copy-paste...

for (patient in 1:3){

	# names of files
	filenames <- dir(
		path = testDatasetsPaths[patient],
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

	dataTable <- numZeros[which(numZeros$files %in% filenames),];

	### WRITE TO FILE #########################################################

	write.table(dataTable, 
		file = file.path(outputPath, paste0(testDatasets[patient], "_basicInfo.csv")), 
		quote = FALSE, 
		sep = ",",
		row.names = FALSE,
		col.names = TRUE
  );
}