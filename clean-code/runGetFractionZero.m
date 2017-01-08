%%% run the getFractionZero.m script; set all the paths here to pass into that
%%% script so that it doesn't have to be modified...

cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/clean-code');
% the path where train_1, test_1, train_2, etc. directories were
dataPath = '../data';
outputPath = '.';

% the dataset paths sent to the getFractionZero script
% note that I think I only used the "train" info for model-building, so that 
% it's okay that the new sets weren't included (I think)
datasets = {'train_1', 'test_1', 'train_2', 'test_2', 'train_3', 'test_3'};
datasetPaths = {
	fullfile(dataPath, 'train_1'),
	fullfile(dataPath, 'test_1'),
	fullfile(dataPath, 'train_2'),
	fullfile(dataPath, 'test_2'),
	fullfile(dataPath, 'train_3'),
	fullfile(dataPath, 'test_3')
	}

% helps to make the size of the table
numDatasets = length(datasetPaths);

% call the getFractionZero script
getFractionZero