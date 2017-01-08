### basicGLM.R #################################################################
# redo basic glm with the updated datasets

### PREAMBLE ###################################################################

library(R.matlab);
library(glmnet);

# reproducibility
set.seed(1015);

### LOAD TRAINING DATA ########################################################

basicInfo <- read.delim( 
	file = basicInfoFilename,
	sep = ",",
	stringsAsFactors = FALSE
    );

results <- NULL;

for (set in 1:3){ 

	trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
	# get feature
	load(get(paste0('trainDataFilename', set)));

	# make rownames match
	trainBasicInfo <- trainBasicInfo[match(rownames(trainData), trainBasicInfo[,1]),]
	rownames(trainBasicInfo) <- trainBasicInfo[,1];

	# sanity check
	print(identical(trainBasicInfo$files,rownames(trainData)))

	### TRAIN MODEL ###########################################################

	# readjust weights
	# not sure if this is the best right way to deal with imbalance and zeros...
	# weight by (1-fraction of zeros)*fraction of observations with that outcome
	numPreictal <- sum(trainBasicInfo$response);
	numBaseline <- length(trainBasicInfo$response) - numPreictal;
	baselineWeight <- numBaseline/length(trainBasicInfo$response);
	trainBasicInfo$outcomeWeight <- baselineWeight;
	trainBasicInfo$outcomeWeight[which(trainBasicInfo$response==1)] <- 1- baselineWeight;
	trainBasicInfo$weights <- (1-trainBasicInfo$fracZero)*trainBasicInfo$outcomeWeight;

	cvfit <- cv.glmnet(trainData, 
		trainBasicInfo$response, 
		family = "binomial", 
		type.measure = "auc",
		weights = trainBasicInfo$weights
		);
	 
	### PREDICT ###############################################################

	testData <-  readMat(get(paste0('testDataFilename', set)));
	files <- unlist(lapply(testData$allFiles, "[[", 1));
	testData <- testData$avgFreq;
	rownames(testData) <- files;

	testPredict <- predict(cvfit, newx = testData,  type = "response", s = 'lambda.min');

	### MAKE DATAFRAME ########################################################

	predictions <- data.frame(
		File = rownames(testData),
		Class = testPredict[,1],
		stringsAsFactors = FALSE
		)

	results <- rbind(results, predictions);
}

results$Class[is.na(results$Class)] <- 0;

write.table(results[,c(1,2)], 
	file = file.path(outputPath, resultsFilename), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
    row.names = FALSE
    );