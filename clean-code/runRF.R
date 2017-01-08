### runRF.R ###################################################################
# a script to run the RF model that was used in the averaged submission

### FUNCTIONS #################################################################
source("collectResults.R");

### COMMON PATHS ##############################################################
# everything saved in the current directory

basicInfoFilename <- file.path(".", "trainBasicInfo.csv");
outputPath <- file.path("."); 

### SET 1 #####################################################################
set <- 1;
trainDataFilename <- file.path(".", "train_1_avgFreq.RData");
testDataFilename <- file.path(".", "test_1_new_avgFreq.mat");
predictionsFilename <- file.path("test_1_new_RF_predictions.csv");
source("basicRF.R")

### SET 2 #####################################################################
set <- 2;
trainDataFilename <- file.path(".", "train_2_avgFreq.RData");
testDataFilename <- file.path(".", "test_2_new_avgFreq.mat");
predictionsFilename <- file.path("test_2_new_RF_predictions.csv");
source("basicRF.R")

### SET 1 #####################################################################
set <- 3;
trainDataFilename <- file.path(".", "train_3_avgFreq.RData");
testDataFilename <- file.path(".", "test_3_new_avgFreq.mat");
predictionsFilename <- file.path("test_3_new_RF_predictions.csv");
source("basicRF.R")

### COLLECT RESULTS FROM ALL SETS #############################################

collectResults(outputPath, "_new_RF_predictions.csv", "allRF.csv")