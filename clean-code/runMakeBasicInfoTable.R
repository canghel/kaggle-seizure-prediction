### runMakeBasicInfoTable.R ###################################################
# set up the data paths and source the file that makes the basic info table
# as before, I think only the training entries are needed
# assumes fracZero.mat is in the directory

### PATHS #####################################################################
outputPath <- file.path(".");

trainDatasets <- c('train_1', 'train_2', 'train_3');
trainDatasetsPaths <- c('../data/train_1', '../data/train_2', '../data/train_3');

testDatasets <- c('test_1', 'test_2', 'test_3');
testDatasetsPaths <- c('../data/test_1', '../data/test_2', '../data/test_3');

### SOURCE SCRIPT #############################################################
source("makeBasicInfoTable.R")