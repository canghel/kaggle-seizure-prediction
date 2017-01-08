# clean-code
I refactored some of my code (note to self: make paths more portable next time!!) so that it would be easier to repoduce my top solution to the competition. 

## Feature extraction/selection

### Basic info table
Obtain the fraction of zeros in each file by running the following in MATLAB:

 	runGetFractionZero;

and then create a nice table with both fraction zero and the response by running the following in R:

	source('runMakeBasicInfoTable.R');

These commands create six tables (for both the training and the original test sets), but only the training data is used in model-building.

### Frequency features

### Update to use only 'safe' labels


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