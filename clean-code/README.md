# clean-code
I refactored some of my code (note to self: make paths more portable next time!!) so that it would be easier to repoduce my best solution to the competition.  

## Software

I used MATLAB (version 2016b, 64-bit, sponsored license) with the Signal Processing Toolbox (version 7.3) for the feature selection and R (version 3.3.2. 64-bit) with the following libraries:

	library(R.matlab);
	library(stringr);
	library(kernlab);
	library(ROCR);
	library(randomForest);
	library(glmnet);
	library(data.table);
	library(h2o);

with versions as below:

	attached base packages:
	 [1] stats     graphics  grDevices utils     datasets  methods   base

	other attached packages:
	 [1] h2o_3.10.0.8        statmod_1.4.27      data.table_1.10.0
	 [4] glmnet_2.0-5        foreach_1.4.3       Matrix_1.2-7.1
	 [7] randomForest_4.6-12 ROCR_1.0-7          gplots_3.0.1
	[10] kernlab_0.9-25      stringr_1.1.0       R.matlab_3.6.1

	loaded via a namespace (and not attached):
	 [1] magrittr_1.5       lattice_0.20-34    caTools_1.17.1     tools_3.3.2
	 [5] grid_3.3.2         R.oo_1.21.0        KernSmooth_2.23-15 iterators_1.0.8
	 [9] gtools_3.5.0       R.utils_2.5.0      bitops_1.0-6       codetools_0.2-15
	[13] RCurl_1.95-4.8     gdata_2.17.0       stringi_1.1.2      R.methodsS3_1.7.1
	[17] jsonlite_1.2.


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