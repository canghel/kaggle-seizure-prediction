### averageDifferentPredictions.R #############################################
# If take mean of predictions of different methods, is the result better?

### PREDICTIONS TO AVERAGE ####################################################

# weighted glm
pred1 <- read.delim( 
	file = "allGLM.csv",
	sep = ",",
	stringsAsFactors = FALSE
	);

# boosted svm
pred2 <- read.delim(
	"allSVM.csv",
	sep = ",",
	stringsAsFactors = FALSE
	);

# rf
pred3 <- read.delim(
	"allRF.csv",
	sep = ",",
	stringsAsFactors = FALSE
	);

# ensemble of nn
pred4 <- read.delim(
	"allNN.csv",
	sep = ",",
	stringsAsFactors = FALSE
 	);

### MERGE AND AVERAGE #########################################################
pred <- merge(pred1, pred2, by.x="File", by.y="File")
pred <- merge(pred, pred3, by.x="File", by.y="File")
pred <- merge(pred, pred4, by.x="File", by.y="File")

print("Correlation between predictions from different methods:")
print(cor(pred[,2:5]))

results <- data.frame(
	File = pred$File,
	Class = rowMeans(pred[,2:5]),
	stringsAsFactors = FALSE
	);

write.table(results[,c(1,2)], 
	file = file.path("averagedPreds.csv"), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);