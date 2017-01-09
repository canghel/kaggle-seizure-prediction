%%%% call the "runSimpleFreqFeatures" which calculates the features for one set

% set 1 train -----------------------------------------------------------------
outputPath = '.';
whichSet = 'train'; 
folderName = 'train_1'
folderPath = '../data/train_1'
runSimpleFreqFeatures

% set 1 test
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_1'
folderPath = '../data/test_1'
runSimpleFreqFeatures

% set 1 test new
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_1_new'
folderPath = '../data/test_1_new'
runSimpleFreqFeatures


% set 2 train -----------------------------------------------------------------
outputPath = '.';
whichSet = 'train'; 
folderName = 'train_2'
folderPath = '../data/train_2'
runSimpleFreqFeatures

% set 2 test
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_2'
folderPath = '../data/test_2'
runSimpleFreqFeatures

% set 2 test new
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_2_new'
folderPath = '../data/test_2_new'
runSimpleFreqFeatures

% set 3 train -----------------------------------------------------------------
outputPath = '.';
whichSet = 'train'; 
folderName = 'train_3'
folderPath = '../data/train_3'
runSimpleFreqFeatures

% set 3 test
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_3'
folderPath = '../data/test_3'
runSimpleFreqFeatures

% set 3 test new
clear all;
outputPath = '.';
whichSet = 'test'; 
folderName = 'test_3_new'
folderPath = '../data/test_3_new'
runSimpleFreqFeatures