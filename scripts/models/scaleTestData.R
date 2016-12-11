### scaleTestData #############################################################
# scale properly: scale test data using train data mean and sd

scaleTestData <- function(testData, trainColMeans, trainColSd){
	M <- nrow(testData);
	# make mean and sd matrices (repmat)
	meansMatrix <- t(kronecker(trainColMeans, matrix(1,1, M)));
	sdMatrix <- t(kronecker(trainColSd, matrix(1,1, M)));
	# get scaled data
	scaledTestData <- (testData - meansMatrix)/sdMatrix;
	return(scaledTestData);
}