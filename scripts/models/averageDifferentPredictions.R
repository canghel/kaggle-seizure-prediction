### averageDifferentPredictions.R #############################################
# If take mean of predictions of different methods, is the result better?

### PREDICTIONS TO AVERAGE ####################################################

# weighted glm
pred1 <- read.delim( 
	file = file.path("..", "..", "submissions", "2016-11-25-19:17:20_Basic.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);

# boosted svm
pred2 <- read.delim(file.path("..", "..", "submissions", "2016-11-27-14:17:48_all_svmModel.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);

# rf
pred3 <- read.delim(file.path("..", "..", "submissions", "2016-11-30-14:10:59_all_rfModel.csv"),
	sep = ",",
	stringsAsFactors = FALSE
	);

# ensemble of nn
pred4<- read.delim("/home/canghel/personal-projects/output/basicNNh2o/2016-12-01-09:18:50_all_simpleModel.csv",
	sep = ",",
	 	stringsAsFactors = FALSE
 	);

### MERGE AND AVERAGE #########################################################
pred <- merge(pred1, pred2, by.x="File", by.y="File")
pred <- merge(pred, pred3, by.x="File", by.y="File")
pred <- merge(pred, pred4, by.x="File", by.y="File")

png(file.path("..", "..", "output", "ensemble", "prediction-agreement.png"));
plot(pred[,3], pred[,4])
dev.off()

print("correlation between two examples")
print(cor(pred[,3], pred[,4]))

results <- data.frame(
	File = pred$File,
	Class = rowMeans(pred[,2:5]),
	stringsAsFactors = FALSE
	);

write.table(results[,c(1,2)], 
	file = file.path("..", "..", "output", "ensemble", paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_averagedPreds.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);