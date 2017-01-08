### basicRF.R #################################################################
library(R.matlab);
library(randomForest);
library(ROCR);

# reproducibility
set.seed(1015);

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

testData <-  readMat(testDataFilename);
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

# scaled using training values now
testData <- scale(testData);
goodTestIndices <- which(complete.cases(testData)==TRUE);
badTestIndices <- which(complete.cases(testData)==FALSE);

rfModel <- randomForest(
    x = trainData,
    y = response,
    replace = TRUE,
    mtry = 2,
    ntree = 2000,
    nodesize = 10,
    classwt = class.weights,
    do.trace=100
);

### PREDICT ###################################################################

predictions <- predict(rfModel, newdata = testData[goodTestIndices,], type="prob");

predFinal <- rep(0, nrow(testData));
predFinal[goodTestIndices] <- predictions[,2];

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