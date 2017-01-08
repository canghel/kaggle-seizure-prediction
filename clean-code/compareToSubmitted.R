### compareToSubmitted.R ######################################################
# sanity check, to make sure the individal GLM, SVM, NN, RF models match
# before averaging
# this script isn't self-contained in this directory (needs files in 
# submissions and output directories)

### PREAMBLE ##################################################################
library("BoutrosLab.plotting.general");

### FUNCTIONS #################################################################
compareModels <- function(modelName, pred1, pred2){
	print(paste0("Comparing ", modelName, " models ----------------"))
	
	# check if they are identical
	out <- identical(pred1, pred2);
	print("Are the models identical?")
	print(out)

	# if not identical, then see how different they are
	if (!(out)){
		rowsMatch <- identical(rownames(pred1), rownames(pred2));
		#print("Are rownames identical?")
		#print(rowsMatch);
		if (rowsMatch){
			print("Summary of differences:");
			print(summary(pred1[,2]-pred2[,2]));
			print("Summary of differences divided by original value:");
			print(summary((pred1[,2]-pred2[,2])/pred1[,2]));
			print("Correlation:");
			print(cor(pred1[,2],pred2[,2]));
			create.boxplot(
				file = file.path(".", paste0(modelName, "-differences.png")),
				formula = y ~ x, 
				data = data.frame(
					y = pred1[,2]-pred2[,2],
					x = rep("diff", length(pred1[,2]))
					),
				add.stripplot = TRUE,
				resolution = 400,
				jitter.factor = 0.5,
				jitter.amount = 0.2
				)
		}
	}
}

### GLM #######################################################################
glmOriginal <- read.delim( 
	file = file.path("..", "submissions", "2016-11-25-19:17:20_Basic.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);
glmRedone <- read.delim( 
	file = "allGLM.csv",
	sep = ",",
	stringsAsFactors = FALSE
	); 

### SVM #######################################################################
svmOriginal <- read.delim(file.path("..", "submissions", "2016-11-27-14:17:48_all_svmModel.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);
svmRedone <- read.delim( 
	file = "allSVM.csv",
	sep = ",",
	stringsAsFactors = FALSE
	); 

### NN ########################################################################
# not actually a submission, but used in the averaging
nnOriginal <- read.delim(file.path("..", "submissions", "2016-12-01-09:18:50_all_simpleModel.csv"),
	sep = ",",
	stringsAsFactors = FALSE
 	);
nnRedone <- read.delim( 
	file = "allNN.csv",
	sep = ",",
	stringsAsFactors = FALSE
	); 

### RF #######################################################################
rfOriginal <- read.delim(file.path("..", "submissions", "2016-11-30-14:10:59_all_rfModel.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);
rfRedone <- read.delim( 
	file = "allRF.csv",
	sep = ",",
	stringsAsFactors = FALSE
	); 

### COMPARE ###################################################################
compareModels("GLM", glmOriginal, glmRedone)
compareModels("SVM", svmOriginal, svmRedone)
compareModels("RF", rfOriginal, rfRedone)
compareModels("NN", nnOriginal, nnRedone)