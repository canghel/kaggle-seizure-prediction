### basic NNh2o.R #############################################################
# trying simplest thing: just 1024-(something)-2 classifier 

### PREAMBLE ##################################################################

library(R.matlab)
library(data.table)
library(h2o)
h2o.init()

outputPath <- file.path("..", "..", "output", "basicNNh2o"); 

set.seed(1015);
seedVal <- 1;

### SET UP OPTIONS FOR NETWORK ################################################

secondLayer <- 100

### LOAD AND PREPARE DATA #####################################################

basicInfo <- read.delim( 
	file = file.path("..", "..", "output", "dataProcessing", "2016-11-25_trainBasicInfo.csv"),
	sep = ",",
	stringsAsFactors = FALSE
    );

source("loadAvgFreqData.R");

temp <- merge(trainData, trainBasicInfo[, c("response", "weights")], by="row.names")
rownames(temp) <- temp[,1];
temp <- temp[,-1];
predictors <- setdiff(names(temp), "response")
# make response categorical
temp[, "response"] <- as.factor(temp[,"response"]);
temp[, "weights"] <- round(100*temp[, "weights"]);  
trainData <- temp;

trainingData <- as.h2o(trainData);

### TRAIN #####################################################################

simpleModel <- h2o.deeplearning(
	# training data
	training_frame = trainingData,
	x = predictors,
	y = "response",
	# structure of network
	activation = "Tanh", 
	hidden = c(secondLayer), 
	# use adadelta
	adaptive_rate = TRUE, 
	# CV, epochs, dropout, penalty, weights
	nfolds = 10,
	# input_dropout_ratio = 0.2,
   	epochs = 1000, 
   	l1 = 1e-4,
   	l2 = 1e-5, 
	weights_column = "weights",
	regression_stop = 1e-6, 
	# other arguments
	seed = seedVal, # may not be reproducible even with this due to memory management 
	export_weights_and_biases = TRUE 
	);

print(simpleModel@model$cross_validation_metrics_summary)

png(file.path(outputPath, paste0(Sys.Date(),  "-",  substr(Sys.time(), 12, 19), '_', set ,"_h2o-roc.png")));
plot(h2o.performance(simpleModel)) 
dev.off();

path <- h2o.saveModel(simpleModel, path=outputPath, force=TRUE)

### PREDICTIONS ###############################################################

testingData <- as.h2o(testData);
predictions <- as.data.frame(h2o.predict(simpleModel, testingData))

results <- data.frame(
	File = rownames(testData),
	Class = predictions[,"p1"],
	stringsAsFactors = FALSE
	)

write.table(results[,c(1,2)], 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_simpleModel.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);