### basicSVMCollectResults.R ##################################################

outputPath <- file.path("..", "..", "output", "rfModels"); 

results <- NULL;

for (set in 1:3){

	filename <- dir(
		path = outputPath,
		# match all files with given pattern
		pattern = paste0("2016-11-30.*", set, "_rfModel.csv"),
		# return only names of visible files
		all.files = FALSE,
		# return only file names, not relative file paths
		full.names = FALSE,
		# assume all are in given directory, not in any subdirectories
		recursive =	FALSE,
		ignore.case =TRUE
	);

	temp <- read.table( 
		file = file.path(outputPath,filename), 
		sep = ",",
		header = TRUE,
		stringsAsFactors = TRUE
		);

	results <- rbind(results, temp);
}

write.table(results[,c(1,2)], 
	file = file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_all_rfModel.csv")), 
	quote = FALSE, 
	sep = ",",
	col.names = TRUE,
	row.names = FALSE
	);

png(file.path(outputPath, paste0(Sys.Date(), "-",  substr(Sys.time(), 12, 19), "_hist_of_predictions.png")))
hist(results[,2]);
dev.off();