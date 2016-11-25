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

testData <-  readMat(file.path("..", "..", "output", "dataProcessing", paste0('20161022_test_', set, '_avgFreq.mat')));
files <- unlist(lapply(testData$allFiles, "[[", 1));
testData <- testData$avgFreq;
rownames(testData) <- files;