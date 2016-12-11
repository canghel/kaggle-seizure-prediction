### TRAIN DATA #############################################################

trainBasicInfo <- basicInfo[grep(paste0('^', set, '_'), basicInfo$files),];
# get feature
load(file.path("..", "..", "output", "dataProcessing", paste0('2016-11-25_train_', set, '_avgFreq.RData')));

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

testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161125_test_', set, '_new_avgFreq.mat')));
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;