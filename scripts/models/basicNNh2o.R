### basic NNh2o.R #############################################################
# try making two 1024 -> 512 -> 256 1-layer autoencoders, with 256 layer then 
# sent to a classifier; then maybe try to put it all together into 1024-512-256-2
# with the weights initialized from the autoencoders
# some code based on Yimin Hu's

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
	epochs = 1000, #training rounds
	l1 = 1e-4,  #l1 penalty
	adaptive_rate = TRUE, #whether to modify learning rate automatically
	regression_stop = 1e-6, #early stopping
	seed = ae.seed, #random seed
	export_weights_and_biases = TRUE #export and save the weights
	); 

set <- 1;

# load data for given data set
source("loadAvgFreqData.R");
trainingData <- as.h2o(trainData);
trainingResponse <- as.h2o(trainBasicInfo$response);

aeModels <- vector();

for (j in 1:2) {
	ae <- do.call(h2o.deeplearning, 
		modifyList(list(
				x = names(trainingData),
				training_frame = trainingData,
				autoencoder = TRUE,
				hidden = layerSizes[j]),
				args)
			);

	print(paste("j = ",j,", Number of epochs: ", last(ae@model$scoring_history$epochs)))
	trainingData <- h2o.deepfeatures(ae,trainingData,layer=1)
	names(trainingData) <- gsub("DF", paste0("L",j,sep=""), names(trainingData))
	aeModels <- c(aeModels, ae)
}

w1.1 <- as.matrix(h2o.weights(aeModels[[1]], matrix_id=1));
w1.2 <- as.matrix(h2o.weights(aeModels[[1]], matrix_id=2));
biases1.1 <- as.matrix(h2o.biases(aeModels[[1]], vector_id=1));
biases1.2 <- as.matrix(h2o.biases(aeModels[[1]], vector_id=2));

w2.1 <- as.matrix(h2o.weights(aeModels[[2]], matrix_id=1));
w2.2 <- as.matrix(h2o.weights(aeModels[[2]], matrix_id=2));
biases2.1 <- as.matrix(h2o.biases(aeModels[[2]], vector_id=1));
biases2.2 <- as.matrix(h2o.biases(aeModels[[2]], vector_id=2));

temp <- cbind(as.matrix(trainingData), ifelse(trainBasicInfo$response, "Y", "N"));
colnames(temp)[ncol(temp)] <- "response";
temp <- as.h2o(temp)

lastModel <- h2o.deeplearning(
	x = 1:256,
	training_frame = temp, 
	y = 257,
	hidden = 10,
	#balance_classes = TRUE,
	epochs = 100 #,
	#classification_stop = 0.99
)
summary(lastModel)

path <- h2o.saveModel(lastModel, path=file.path("..", "..", "output", "basicNNh2o"), force=TRUE)

save(w1.1, w1.2, biases1.1, biases1.2, 
	 w2.1, w2.2, biases2.1, biases2.2,
	file = file.path("..", "..", "output", "-basicNNh2o-weights.RData"))
	);