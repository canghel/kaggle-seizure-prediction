### basicSVM.R ################################################################
# Try basic SVM model.
# Actually - doing some bootstrapping (based on Honglei Xie's Dream9(?) 
# Alzheimer's challenge work)
#
# Note: the version which did *not* scale the test data in the same way as
# the train data got a better result.

### PREAMBLE ##################################################################
library(kernlab);
library(R.matlab)
library(ROCR);

# reproducibility
set.seed(1015);

# number of bootstraps
B <- 100; 

### LOAD TRAINING DATA ########################################################

basicInfo <- read.delim( 
	file = basicInfoFilename,
	sep = ",",
	stringsAsFactors = FALSE
    );

trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
# get feature
load(trainDataFilename);

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
trainData <- scale(trainData);
N <- nrow(trainData);

class.weights <- summary(response)/sum(summary(response))

### PREDICT ###############################################################

testData <-  readMat(testDataFilename);
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

# this is wrong need to scale using train data values
# also, why do I have so many NA's?? did I process data wrong?
testData <- scale(testData);
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
	file = predictionsFilename, 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
);