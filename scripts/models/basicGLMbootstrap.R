### basicGLMbootstrap.R #######################################################
# redo basic glm with the updated datasets

### PREAMBLE ##################################################################

library(BoutrosLab.plotting.general);
library(R.matlab);
library(glmnet);

outputPath <- file.path("..", "..", "output", "glmModels"); 

# reproducibility
set.seed(1015);

### PREAMBLE ##################################################################
library(kernlab);
library(R.matlab)
library(ROCR);

source("scaleTestData.R")

outputPath <- file.path("..", "..", "output", "svmModels"); 

# reproducibility
set.seed(1015);

# number of bootstraps
B <- 100; 

### LOAD TRAINING DATA ########################################################

basicInfo <- read.delim( 
	file = file.path("..", "..", "output", "dataProcessing", "2016-11-25_trainBasicInfo.csv"),
	sep = ",",
	stringsAsFactors = FALSE
    );

trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
# get feature
load(file.path("..", "..", "output", "dataProcessing", paste0('2016-11-25_train_', set, '_avgFreq.RData')));

# make rownames match
trainBasicInfo <- trainBasicInfo[match(rownames(trainData), trainBasicInfo[,1]),]
rownames(trainBasicInfo) <- trainBasicInfo[,1];

# sanity check
print(identical(trainBasicInfo$files,rownames(trainData)))

# readjust weights
# not sure if this is the best right way to deal with imbalance and zeros...
# weight by (1-fraction of zeros)*fraction of observations with that outcome
numPreictal <- sum(trainBasicInfo$response);
numBaseline <- length(trainBasicInfo$response) - numPreictal;
baselineWeight <- numBaseline/length(trainBasicInfo$response);
trainBasicInfo$outcomeWeight <- baselineWeight;
trainBasicInfo$outcomeWeight[which(trainBasicInfo$response==1)] <- 1- baselineWeight;
trainBasicInfo$weights <- (1-trainBasicInfo$fracZero)*trainBasicInfo$outcomeWeight;

### LOAD TEST DATA ############################################################

testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161125_test_', set, '_new_avgFreq.mat')));
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

N <- nrow(trainData);

pred <- matrix(NA, nrow=nrow(testData), ncol=B);
coefs <- matrix(NA, nrow=(ncol(testData)+1), ncol=B)

for (b in 1:B){

	i.train <- sample(1:N, size=N, replace = TRUE);

	message("On sample # ", b);
	
	cvfit <- cv.glmnet(trainData[i.train,], 
		trainBasicInfo$response[i.train], 
		family = "binomial", 
		type.measure = "auc",
		weights = trainBasicInfo$weights[i.train]
		);

	# # look at cv graph
	# png(file.path(outputPath, paste0(Sys.Date(),  "-",  substr(Sys.time(), 12, 19), '_', set ,"_cvfit.png")));
	# plot(cvfit); 
	# dev.off();

	print(coef(cvfit, s = "lambda.min"));
	coefs[,b] = coef(cvfit, s = "lambda.min")[,1];
	
	testPredict <- predict(cvfit, newx = testData,  type = "response", s = 'lambda.min');

	### MAKE DATAFRAME ########################################################

	pred[,b] <- testPredict[,1]
}

predictions <- data.frame(
	File = rownames(testData),
	Class = apply(pred, 1, mean, na.rm=TRUE),
	stringsAsFactors = FALSE
	)

predictions$Class[is.na(predictions$Class)] <- 0;

write.table(predictions, 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_glmBasic.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
    row.names = FALSE
    );

write.table(coefs, 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_coefsGlmBasic.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
    row.names = FALSE
    );