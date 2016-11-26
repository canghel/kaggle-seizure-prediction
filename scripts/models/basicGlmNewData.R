### basicGlmNewData.R #########################################################
# redo basic glm with the updated datasets

### PREAMBLE ##################################################################

library(BoutrosLab.plotting.general);
library(R.matlab);
library(glmnet);

outputPath <- file.path("..", "..", "output", "glmModels"); 

# reproducibility
set.seed(1015);

### LOAD TRAINING DATA ############################################################

basicInfo <- read.delim( 
	file = file.path("..", "..", "output", "dataProcessing", "2016-11-25_trainBasicInfo.csv"),
	sep = ",",
	stringsAsFactors = FALSE
    );

results <- NULL;

for (set in 1:3){ 

	trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
	# get feature
	load(file.path("..", "..", "output", "dataProcessing", paste0('2016-11-25_train_', set, '_avgFreq.RData')));

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

	# look at cv graph
	png(file.path(outputPath, paste0(Sys.Date(),  "-",  substr(Sys.time(), 12, 19), '_', set ,"_cvfit.png")));
	plot(cvfit); 
	dev.off();

	print(coef(cvfit, s = "lambda.min"));
	 
	### PREDICT ###############################################################

	testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161125_test_', set, '_new_avgFreq.mat')));
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
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_Basic.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
    row.names = FALSE
    );