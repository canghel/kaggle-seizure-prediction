### basic NNh2o.R #############################################################
# trying just simplest idea 3) for now:
#
# ideas: 
# 1) stacked autoencoder that decreases dim to 512-256 then goes down to 2 
# classifier
# 	- problem: weighing different samples? (only train with fracZero > something)
# 	- can't do customisable NN (multivariate) using h2o
# 2) two autoencoders, one for 0's and one for 1's
#	- run new sample in both, then compare errors to determine the class 
#	(method of comparing to other 1's and 0's signals?) 
# 3) simplest: just 1024-(something)-2 classifier 

### PREAMBLE ##################################################################

library(R.matlab)
library(data.table)
library(h2o)
h2o.init()

set.seed(1015);
ae.seed <- 1;

### SET UP OPTIONS FOR NETWORK ################################################

layerSizes <- c(512, 256)
ae <- list();

args <- list(
	activation = "Tanh", #activation function
	epochs = 20, #training rounds
	l1 = 1e-4,  #l1 penalty
	adaptive_rate = TRUE, #whether to modify learning rate automatically
	regression_stop = 1e-6, #early stopping
	seed = ae.seed, #random seed
	export_weights_and_biases = TRUE #export and save the weights
	); 

set <- 1;

### LOAD AND PREPARE DATA #####################################################

basicInfo <- read.delim( 
	file = file.path("..", "..", "output", "dataProcessing", "2016-11-25_trainBasicInfo.csv"),
	sep = ",",
	stringsAsFactors = FALSE
    );

source("loadAvgFreqData.R");
browser();

temp <- merge(trainData, trainBasicInfo[, c("response", "weights")], by="row.names")
rownames(temp) <- temp[,1];
temp <- temp[,-1];
predictors <- setdiff(names(temp), "response")
response <- temp[,"response"];
trainData <- temp[, -which(colnames(temp)=="response")];

trainingData <- as.h2o(trainData[1:10,]);

### TRAIN #####################################################################

aeModels <- vector();

# am actually going to do this the long way...
# train first autoencoder ----------------------------------------------------#

j <- 1;

ae <- do.call(h2o.deeplearning, 
	modifyList(list(
			x = predictors,
			training_frame = trainData,
			autoencoder = TRUE,
			weights_column = "weights",
			hidden = layerSizes[j]),
			autoencoder = TRUE,
			args)
		);

print(paste("j = ",j,", Number of epochs: ", last(ae@model$scoring_history$epochs)))
trainingData <- h2o.deepfeatures(ae,trainingData,layer=1)
names(trainingData) <- gsub("DF", paste0("L",j,sep=""), names(trainingData))
aeModels <- c(aeModels, ae)

w1.1 <- as.matrix(h2o.weights(aeModels[[1]], matrix_id=1));
w1.2 <- as.matrix(h2o.weights(aeModels[[1]], matrix_id=2));
biases1.1 <- as.matrix(h2o.biases(aeModels[[1]], vector_id=1));
biases1.2 <- as.matrix(h2o.biases(aeModels[[1]], vector_id=2));

w2.1 <- as.matrix(h2o.weights(aeModels[[2]], matrix_id=1));
w2.2 <- as.matrix(h2o.weights(aeModels[[2]], matrix_id=2));
biases2.1 <- as.matrix(h2o.biases(aeModels[[2]], vector_id=1));
biases2.2 <- as.matrix(h2o.biases(aeModels[[2]], vector_id=2));

# temp <- cbind(as.matrix(trainingData), ifelse(trainBasicInfo$response, "Y", "N"));
# colnames(temp)[ncol(temp)] <- "response";
# temp <- as.h2o(temp)

# lastModel <- h2o.deeplearning(
# 	x = 1:256,
# 	training_frame = temp, 
# 	y = 257,
# 	hidden = 10,
# 	#balance_classes = TRUE,
# 	epochs = 100 #,
# 	#classification_stop = 0.99
# )
# summary(lastModel)

# path <- h2o.saveModel(lastModel, path=file.path("..", "..", "output", "basicNNh2o"), force=TRUE)

# save(w1.1, w1.2, biases1.1, biases1.2, 
# 	w2.1, w2.2, biases2.1, biases2.2,
# 	file = file.path("..", "..", "output", paste0(Sys.Date(), "-basicNNh2o-weights.RData"))
# 	);