### basicGLM.R ###############################################################
# glmnet model

### PREAMBLE ##################################################################

library(BoutrosLab.plotting.general);
library(R.matlab);
library(glmnet);

outputPath <- file.path("..", "..", "output", "glmModels"); 

# reproducibility
set.seed(1015);

### LOAD TRAINING DATA ############################################################

results <- NULL;

for (set in 1:3){

	trainBasicInfo <- read.delim( 
		file = file.path("..", "..", "output", "dataProcessing", paste0("2016-10-22-train_", set, "_basicInfo.csv")),
		sep = ",",
		stringsAsFactors = FALSE
	    );

	# re-format feature data
	trainData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161022_train_', set, '_avgFreq.mat')));
	files <- unlist(lapply(trainData$allFiles, "[[", 1));
	trainData <- trainData$avgFreq;
	rownames(trainData) <- files;

	# make rownames match
	trainBasicInfo <- trainBasicInfo[match(rownames(trainData), trainBasicInfo[,1]),]
	rownames(trainBasicInfo) <- trainBasicInfo[,1];

	# sanity check
	print(identical(trainBasicInfo$files,rownames(trainData)))

	### TRAIN MODEL ###########################################################

	# weight by 1-fraction of zeros
	# no adjustment yet for imbalanced data
	cvfit <- cv.glmnet(trainData, 
		trainBasicInfo$response, 
		family = "binomial", 
		type.measure = "auc",
		weights = 1-trainBasicInfo$fracZeros
		);

	# look at cv graph
	png(file.path(outputPath, paste0(Sys.Date(), '_', set ,"_cvfit.png")));
	plot(cvfit); 
	dev.off();

	print(coef(cvfit, s = "lambda.min"));
	 
	### PREDICT ###############################################################

	testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161022_test_', set, '_avgFreq.mat')));
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
	file = file.path(outputPath, paste0(Sys.Date(), "_Basic.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
    row.names = FALSE
    );