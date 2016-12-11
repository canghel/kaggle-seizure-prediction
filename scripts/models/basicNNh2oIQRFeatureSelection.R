## 1024 features is still too much so do another step of feature selection
#scale(trainData[, -1025])
#png("test.png"); hist(as.vector(scale(trainData[, -1025]))); dev.off()
#png("test-log.png"); hist(as.vector(scale(log(trainData[, -1025]+1)); dev.off()
temp2 <- log(temp[, -c(1025,1026)]+1);

iqrVals <- apply(temp2, 2, IQR, na.rm=TRUE);
names(iqrVals) <- 1:1024;

# omit the scale, which messes things up when mean is small
mostVariableFeatures <- sort(iqrVals, decreasing=TRUE)[1:512];
mostVariableIndices <- names(mostVariableFeatures);

trainData <- temp[, c(as.numeric(mostVariableIndices),1025, 1026)];


testData <- log(testData[, as.numeric(mostVariableIndices)]+1);