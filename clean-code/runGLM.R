### runGLM.R ##################################################################
# a script to run the GLM model that was used in the averaged submission

### FUNCTIONS #################################################################
source("collectResults.R");

### COMMON PATHS ##############################################################
# everything saved in the current directory

basicInfoFilename <- file.path(".", "trainBasicInfo.csv");
outputPath <- file.path("."); 

### INPUT FILES ###############################################################
trainDataFilename1 <- file.path(".", "train_1_avgFreq.RData");
testDataFilename1 <- file.path(".", "test_1_new_avgFreq.mat");

trainDataFilename2 <- file.path(".", "train_2_avgFreq.RData");
testDataFilename2 <- file.path(".", "test_2_new_avgFreq.mat");

trainDataFilename3 <- file.path(".", "train_3_avgFreq.RData");
testDataFilename3 <- file.path(".", "test_3_new_avgFreq.mat");

### RUN GLM SCRIPT ############################################################
# glm script had a for loop over all sets, if do it separately the random
# seed is different
resultsFilename <- "allGLM.csv" 
source("basicGLM.R")