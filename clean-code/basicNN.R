### basicNN.R #################################################################
# trying simplest thing: just 1024-(something)-2 classifier 

### PREAMBLE ##################################################################

library(R.matlab)
library(data.table)
library(h2o)
h2o.init(nthreads = -1)

set.seed(1015);

S <- 10;

### SET UP OPTIONS FOR NETWORK ################################################

secondLayer <- 100

### LOAD AND PREPARE DATA #####################################################

basicInfo <- read.delim( 
	file = basicInfoFilename,
	sep = ",",
	stringsAsFactors = FALSE
    );

### TRAIN DATA #############################################################

trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
# get feature
load(trainDataFilename);

# make rownames match
trainBasicInfo <- trainBasicInfo[match(rownames(trainData), trainBasicInfo[,1]),]
rownames(trainBasicInfo) <- trainBasicInfo[,1];

# sanity check
print(identical(trainBasicInfo$files,rownames(trainData)))

### CALCULATE WEIGHTS #####################################################

# readjust weights
# not sure if this is the best right way to deal with imbalance and zeros...
# weight by (1-fraction of zeros)*fraction of observations with that outcome
numPreictal <- sum(trainBasicInfo$response);
numBaseline <- length(trainBasicInfo$response) - numPreictal;
baselineWeight <- numBaseline/length(trainBasicInfo$response);
trainBasicInfo$outcomeWeight <- baselineWeight;
trainBasicInfo$outcomeWeight[which(trainBasicInfo$response==1)] <- 1- baselineWeight;
trainBasicInfo$weights <- (1-trainBasicInfo$fracZero)*trainBasicInfo$outcomeWeight;

### TEST DATA #############################################################

testData <-  readMat(testDataFilename);
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

temp <- merge(trainData, trainBasicInfo[, c("response", "weights")], by="row.names")
rownames(temp) <- temp[,1];
temp <- temp[,-1];

# make response categorical
temp[, "response"] <- as.factor(temp[,"response"]);
temp[, "weights"] <- round(100*temp[, "weights"]);  
trainData <- temp;

### FEATURE SELECTION #########################################################

source("../scripts/models/basicNNh2oIQRFeatureSelection.R");
#browser();
predictors <- setdiff(names(trainData), "response")
trainingData <- as.h2o(trainData);

### TRAIN #####################################################################

allPred <- matrix(0, nrow(testData), S);

for (seedVal in 1:S){

	simpleModel <- h2o.deeplearning(
		# training data
		training_frame = trainingData,
		x = predictors,
		y = "response",
		# structure of network
		activation = "TanhWithDropout", 
		hidden = c(secondLayer), 
		# use adadelta
		adaptive_rate = TRUE, 
		# CV, epochs, dropout, penalty, weights
		nfolds = 10,
		input_dropout_ratio = 0.2,
	   	epochs = 1000, 
	   	l1 = 1e-3, 
	   	# l2 = 1e-5, 
		weights_column = "weights",
		stopping_metric = "AUC",
		stopping_tolerance = 0.01,
		# other arguments
		seed = seedVal, # may not be reproducible even with this due to memory management 
		export_weights_and_biases = TRUE 
		);

	print(simpleModel@model$cross_validation_metrics_summary)

	### PREDICTIONS ###############################################################

	testingData <- as.h2o(testData);
	predictions <- as.data.frame(h2o.predict(simpleModel, testingData))

	allPred[,seedVal] <- predictions[, "p1"]

}

results <- data.frame(
	File = rownames(testData),
	Class = apply(allPred, 1, mean, na.rm=TRUE),
	stringsAsFactors = FALSE
	)

write.table(results[,c(1,2)], 
	file = predictionsFilename, 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);