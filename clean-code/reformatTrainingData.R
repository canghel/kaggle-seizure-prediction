### reformatTrainingData.R ####################################################
# reformat the training data using the new info

### PREAMBLE #################################################################

library(R.matlab);
outputPath <- '.';

### LOAD SAFE FILE INFO ######################################################

safeFileInfo <- read.delim( 
	file = file.path("..", "data", "train_and_test_data_labels_safe.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);

# make a new data frame to load all the info from safeFileInfo and summary
# stats from basic info
allTrainInfo <- safeFileInfo;
allTrainInfo$fracZero <- rep(NA, nrow(safeFileInfo))
allTrainInfo$sanityCheck <- rep(NA, nrow(safeFileInfo))


for (set in 1:3){

	# load previous train and test info --------------------------------------#
	trainBasicInfo <- read.delim( 
		file = paste0("train_", set, "_basicInfo.csv"),
		sep = ",",
		stringsAsFactors = FALSE
		);

	testBasicInfo <- read.delim( 
		file = paste0("test_", set, "_basicInfo.csv"),
		sep = ",",
		stringsAsFactors = FALSE
		);

	# collect "safe" file info -----------------------------------------------#
	trainBasicInfo <- trainBasicInfo[which(trainBasicInfo$files %in% allTrainInfo$image),]
	allTrainInfo$fracZero[match(trainBasicInfo$files, allTrainInfo$image)] <- trainBasicInfo$fracZero;
	allTrainInfo$sanityCheck[match(trainBasicInfo$files, allTrainInfo$image)] <- trainBasicInfo$response;

	print("Check if responses match:")
	print(identical(
		allTrainInfo[which(!(is.na(allTrainInfo$sanityCheck))),"class"],
		allTrainInfo[which(!(is.na(allTrainInfo$sanityCheck))),"sanityCheck"])
	);

	testBasicInfo <- testBasicInfo[which(testBasicInfo$files %in% allTrainInfo$image),]
	allTrainInfo$fracZero[match(testBasicInfo$files, allTrainInfo$image)] <- testBasicInfo$fracZero;
}

# write new info table to file
goodFileInfo <- allTrainInfo[which(allTrainInfo$safe==1),];
colnames(goodFileInfo) <- c("files", "response", "safe", "fracZero", "sanityCheck")

write.table(goodFileInfo, 
	file =  file.path(outputPath,"trainBasicInfo.csv"), 
	quote = FALSE, 
	sep = ",",
	row.names = FALSE,
	col.names = TRUE
);


for (set in 1:3){

	# restrict training data to only safe files ------------------------------#
	trainData <-  readMat(file.path(outputPath, paste0('train_', set, '_avgFreq.mat')));
	files <- unlist(lapply(trainData$allFiles, "[[", 1));
	trainData <- trainData$avgFreq;
	rownames(trainData) <- files;

	testData <-  readMat(file.path(outputPath, paste0('test_', set, '_avgFreq.mat')));
	files <- unlist(lapply(testData$allFiles, "[[", 1));
	testData <- testData$avgFreq;
	rownames(testData) <- files;

	newTrainData <- rbind(trainData, testData);
	# NOTE: rewriting over 'trainData'
	trainData <- newTrainData[which(rownames(newTrainData) %in% goodFileInfo$files),];

	# save cleaned up files...
	save(trainData, file=file.path(outputPath, paste0('train_', set, '_avgFreq.RData')))
}