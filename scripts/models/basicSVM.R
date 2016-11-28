### basicSVM.R ################################################################
# Try basic SVM model.
# Actually - doing some bootstrapping (based on Honglei Xie's Dream9(?) 
# Alzheimer's challenge work)
#
# To do
# - need to scale/center test data properly
# - maybe log?

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

### TRAIN MODEL ###############################################################

# readjust weights
# not sure if this is the best right way to deal with imbalance and zeros...
# weight by (1-fraction of zeros)*fraction of observations with that outcome
numPreictal <- sum(trainBasicInfo$response);
numBaseline <- length(trainBasicInfo$response) - numPreictal;
baselineWeight <- numBaseline/length(trainBasicInfo$response);
trainBasicInfo$outcomeWeight <- baselineWeight;
trainBasicInfo$outcomeWeight[which(trainBasicInfo$response==1)] <- 1- baselineWeight;
trainBasicInfo$weights <- (1-trainBasicInfo$fracZero)*trainBasicInfo$outcomeWeight;

trainBasicInfo$response <- as.factor(trainBasicInfo$response)

response <- trainBasicInfo$response[complete.cases(trainData)];
trainData <- trainData[complete.cases(trainData),];

trainColMeans <- apply(trainData, 2, mean);
trainColSd <- apply(trainData, 2, sd);

# make sure it looks like scale
#sanityCheckTemp <- scaleTestData(trainData, trainColMeans, trainColSd);
#print(summary(sanityCheckTemp));
#print(summary(as.vector(scale(trainData) - sanityCheckTemp)))

trainData <- scale(trainData);
N <- nrow(trainData);

class.weights <- summary(response)/sum(summary(response))

### PREDICT ###############################################################

testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161125_test_', set, '_new_avgFreq.mat')));
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

# scaled using training values now
testData <- scaleTestData(testData, trainColMeans, trainColSd);
goodTestIndices <- which(complete.cases(testData)==TRUE);
badTestIndices <- which(complete.cases(testData)==FALSE);

pred <- matrix(NA, nrow=length(goodTestIndices), ncol=B);

for (b in 1:B){

	i.train <- sample(1:N, size=N, replace = TRUE);

	message("On sample # ", b);

	svmModel <- ksvm(
		x = trainData[i.train,], 
		y = response[i.train], 
		type = "C-svc",
		kernel = "rbf",
		C = 10,
		prob.model = TRUE,
		class.weights = class.weights
		);

	predVal <- predict(svmModel, trainData[-i.train,], type="probabilities");
	predVal.obj <- prediction(predVal[,2], response[-i.train])
	valAUC <- as.numeric(performance(predVal.obj,"auc")@y.values);
	print(paste0("AUC on held out set: ", valAUC))

	predAllTrain <- predict(svmModel, trainData, type="probabilities");
	predAllTrain.obj <- prediction(predAllTrain[,2], response)
	allTrainAUC <- as.numeric(performance(predAllTrain.obj,"auc")@y.values);
	print(paste0("AUC on all training set: ", allTrainAUC))

	pred[,b] <- predict(svmModel, testData[goodTestIndices,],  type="probabilities")[,2];

}

predMean <- apply(pred, 1, mean);

predFinal <- rep(0, nrow(testData));
predFinal[goodTestIndices] <- predMean;

results <- data.frame(
	File = rownames(testData),
	Class = predFinal,
	stringsAsFactors = FALSE
	)

write.table(results[,c(1,2)], 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_svmModel.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);