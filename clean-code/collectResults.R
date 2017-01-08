### collectResults.R ##########################################################
# function to concatenate the results from patients 1, 2, and 3 into a large file
# Inputs: 
# 	- outputPath = path to where the results are saved (both the separate set 
# 		results, and where the concatenated file will be output)
#	- filenameStem = the stem of the filename for the certain method 
#  	- outputFilename = filename of concatenated file 
# Outputs:
# 	- saves file of concatenated results 


collectResults <- function(outputPath, filenameStem, outputFilename){
	results <- NULL;

	for (set in 1:3){

		filename <- dir(
			path = outputPath,
			# match all files with given pattern
			pattern = paste0("^.*", set, filenameStem),
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
		file = file.path(outputPath, outputFilename), 
		quote = FALSE, 
		sep = ",",
		col.names = TRUE,
		row.names = FALSE
		);

}