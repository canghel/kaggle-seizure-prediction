# clean-code
I refactored some of my code (note to self: make paths more portable next time!!) so that it would be easier to repoduce my top solution to the competition. 

## Feature extraction/selection

The scripts assume that the directories `test_i`, `test_i`, and `test_i_new` for *i*=1,2,3 (with the files for each patient) are located in `../data` (relative path from the current directory).  The file `train_and_test_data_labels_safe.csv` should also be in `../data`.  I tried to define the paths in the 'run' scripts which call other scripts and functions, to make the paths easier to modify.

### Basic info table
Obtain the fraction of zeros in each file by running the following in MATLAB:

 	runGetFractionZero;

and then create a nice table with both fraction zero and the response by running the following in R:

	source('runMakeBasicInfoTable.R');

These commands create six tables (for both the training and the original test sets), which will be updated into one table in a later step.

### Frequency features
This step takes a long time.  It is done in MATLAB:

	runSimpleFreqFeaturesAll

This script calls `runSimpleFreqFeatures.m` which calculates the frequency features for one dataset (which calls `simpleFreqFeatures.m` which calculates the frequencies per channel).

### Update to use only 'safe' labels
The last step of processing is to create a basic information table of all the data and create `.RData` files of all the frequency features, using the 'safe' labels after the initial data was corrected.

	source('reformatTrainingData.R');


## Ensemble of models
The following feature files should be in the current directory:

*	`trainBasicInfo.csv`
* 	`train_1_avgFreq.RData`, `train_2_avgFreq.RData`, `train_3_avgFreq.RData`
* 	`test_1_new_avgFreq.mat`, `test_2_new_avgFreq.mat`, `test_3_new_avgFreq.mat`.

The results of four models were averaged to obtain the final result.  They can be run in R, and the results collected, using the following sequence of commands:

	source('runGLM.R');
	source('runRF.R');
	source('runSVM.R');
	source('runNN.R'); # this takes a long time!
	source('averageAllModels.R');