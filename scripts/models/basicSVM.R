### basicSVM.R ################################################################
# Try basic SVM model.
#
# To do
# - need to scale/center test data properly
# - maybe log?

### PREAMBLE ##################################################################
#library(BoutrosLab.plotting.general);
library(kernlab);
library(pROC);

outputPath <- file.path("..", "..", "output", "svmModels"); 

# reproducibility
set.seed(1015);

# do each set separately, to speed up
set <- 1;

### FUNCTIONS #################################################################



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
trainData <- scale(trainData);

class.weights <- summary(response)/sum(summary(response))

svmModel <- ksvm(
	x = trainData, 
	y = response, 
	type = "C-svc",
	kernel = "rbf",
	C = 10,
	#prob.model = TRUE,
	class.weights = class.weights
	);

pred <- predict(svmModel, trainData, type="probabilities");
#trainAUC <- auc(response, pred[,2])

pred.obj <- prediction(pred[,2], response)
perfAUC <- as.numeric(performance(pred.obj,"auc")@y.values);

 
### PREDICT ###############################################################

testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161125_test_', set, '_new_avgFreq.mat')));
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;

# this is wrong need to scale using train data values
trainData <- scale(testData);

testPredict <- predict(cvfit, newx = testData,  type = "response", s = 'lambda.min');

### MAKE DATAFRAME ########################################################

predictions <- data.frame(
	File = rownames(testData),
	Class = testPredict[,1],
	stringsAsFactors = FALSE
	)

write.table(predictions[,c(1,2)], 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_svmModel.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);