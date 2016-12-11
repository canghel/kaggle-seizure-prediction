### basic NNh2o.R #############################################################
# trying simplest thing: just 1024-(something)-2 classifier 

### PREAMBLE ##################################################################

library(R.matlab)
library(data.table)
library(h2o)
h2o.init(nthreads = -1)

outputPath <- file.path("..", "..", "output", "basicNNh2o"); 

set.seed(1015);

S <- 10;

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

# make response categorical
temp[, "response"] <- as.factor(temp[,"response"]);
temp[, "weights"] <- round(100*temp[, "weights"]);  
trainData <- temp;

### FEATURE SELECTION #########################################################

#source("basicNNh2oIQRFeatureSelection.R");
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

write.table(simpleModel@model$cross_validation_metrics_summary,
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_cv-summary.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = TRUE
	);

png(file.path(outputPath, paste0(Sys.Date(),  "-",  substr(Sys.time(), 12, 19), '_', set ,"_h2o-roc.png")));
plot(h2o.performance(simpleModel)) 
dev.off();

# path <- h2o.saveModel(simpleModel, path=outputPath, force=TRUE)

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
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_", set, "_simpleModel.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);