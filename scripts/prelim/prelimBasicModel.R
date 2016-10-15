### prelimBasicFeaturePlots.R #################################################


### PREAMBLE ##################################################################

library(BoutrosLab.plotting.general);
library(R.matlab);
library(glmnet);

outputPath <- file.path("..", "output", "prelim"); 

# reproducibility
set.seed(1015);

### MAKE PLOTS OF TRAINING DATA ###############################################

results <- NULL;

for (set in 1:3){

	trainData <- readMat(file.path(outputPath, paste0('20161001_train_', set ,'_BasicFeatures.mat')));

	oneFeatures <- t(cbind(data$oneFeatures[,,1]$avg, scale(data$oneFeatures[,,1]$sd)));
	rownames(oneFeatures) <- c(paste0('EA', 1:16), paste0('ES', 1:16));

	zeroFeatures <- t(cbind(data$zeroFeatures[,,1]$avg, scale(data$zeroFeatures[,,1]$sd)));
	rownames(zeroFeatures) <- c(paste0('EA', 1:16), paste0('ES', 1:16));

	oneFeaturesReformat <- data.frame(
	    value = as.vector(oneFeatures),
	    electrode = as.factor(rep(rownames(oneFeatures), ncol(oneFeatures)))
	    );

	create.boxplot(
		filename = file.path(outputPath, paste0(Sys.Date(), '_vals_', set ,'_1.png')),
		formula = electrode ~ value,
		data = oneFeaturesReformat ,
		xlab.label = 'values',
		main.cex = 1.5, 
		ylab.cex = 1.5,
		xlab.cex = 1.5,
		yaxis.cex = 1,
		xaxis.cex = 1,
		xlim= c(-1,1),
		add.stripplot = TRUE,
		resolution = 200
		);

	zeroFeaturesReformat <- data.frame(
	    value = as.vector(zeroFeatures),
	    electrode = as.factor(rep(rownames(zeroFeatures), ncol(zeroFeatures)))
	    );

	create.boxplot(
		filename = file.path(outputPath,  paste0(Sys.Date(), '_vals_', set ,'_0.png')),
		formula = electrode ~ value,
		data = zeroFeaturesReformat ,
		xlab.label = 'values',
		main.cex = 1.5, 
		ylab.cex = 1.5,
		xlab.cex = 1.5,
		yaxis.cex = 1,
		xaxis.cex = 1,
		xlim= c(-1,1),
		add.stripplot = TRUE,
		resolution = 200
		);

	#temp1 <- complete.cases(t(zeroFeatures)); zeroFeatures <- zeroFeatures[,temp1]
	#temp2 <- complete.cases(t(oneFeatures)); oneFeatures <- oneFeatures[,temp2]

	### TRAIN MODEL ###############################################################

	glmdata <- rbind(t(zeroFeatures), t(oneFeatures));
	glmdata <- rbind(t(zeroFeatures), t(oneFeatures));
	#data <- cbind(data, c(rep(0, ncol(zeroFeatures)), rep(1, ncol(oneFeatures))));
	#colnames(data)[17] = 'outcome';
	#data <- as.data.frame(data);
	y <- c(rep(0, ncol(zeroFeatures)), rep(1, ncol(oneFeatures)));
	cvfit <- cv.glmnet(glmdata, y, family = "binomial", type.measure = "auc");
	png(file.path(outputPath, paste0(Sys.Date(), '_', set ,"_cvfit.png")));
	plot(cvfit); 
	dev.off();

	print(coef(cvfit, s = "lambda.min"));
	#}

	### PREDICT ###################################################################

	testData <- readMat(file.path(outputPath, paste0('20161002_test_', set ,'_BasicFeatures.mat')));

	testFeatures <- t(cbind(testData$testFeatures[,,1]$avg, scale(testData$testFeatures[,,1]$sd)));
	rownames(testFeatures) <- c(paste0('EA', 1:16), paste0('ES', 1:16));

	testPredict <- predict(cvfit, newx = t(testFeatures),  type = "response", s = 'lambda.min');

	### MAKE DATAFRAME ############################################################

	# sanity check
	identical(unlist(testData$allTest)[testData$indicesTestNonZero], unlist(testData$allTestNonZero))

	predictions <- data.frame(
		File = unlist(testData$allTest),
		Class = rep(0, length(testData$allTest)),
		stringsAsFactors = FALSE
		)
	rownames(predictions) <- predictions$File;
	predictions[unlist(testData$allTestNonZero),'Class'] <- testPredict;

	results <- rbind(results, predictions[,c("File", "Class")]);
}

write.table(results, 
	file = file.path(outputPath, paste0(Sys.Date(), "_submission_02.csv")), 
	quote = FALSE, 
	sep = ",",
    row.names = FALSE,
    col.names = TRUE
    );