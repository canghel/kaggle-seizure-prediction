% prelimBasicFeatureGeneration.m
% just get basic stats: mean, median, standard deviation of each electrode
% over entire interval

%% Preamble
% set paths (everything but first path should be general)
cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts');
dataPath = '../data';
outputPath = '../output/prelim';

%% Dataset to work on (change this to 1,2,3)
ss = 3;

%% Generate features for training data 

dataset = strcat('train_', num2str(ss));

% get zero and one filenames
[allTrain zeroTrain oneTrain] = getFilenames(ss, 'train', dataPath);

% omit files which are all zero
load(fullfile(outputPath, '20161001_FilesnamesWithAllZeros.mat'));
% index = strcmp([allZeroFiles.datasets{:}],dataset); % doesn't do
% anything?
% the 2*(ss-1)+1 is confusing indexing, it's just that I saved them in
% order train_1, test_1, train_2, test_2, train_3, test_3
oneTrain = oneTrain(find(~ismember(oneTrain, cellstr(allZeroFiles.filenames{2*(ss-1)+1,:}))==1));
zeroTrain = zeroTrain(find(~ismember(zeroTrain, cellstr(allZeroFiles.filenames{2*(ss-1)+1,:}))==1));

% number of remaining files once omit all zero files
oneNN = length(oneTrain);
zeroNN = length(zeroTrain);

% get features: .avg, .med(ian) and .sd
oneFeatures = computeBasicFeatures(oneNN, dataPath, dataset, oneTrain);
zeroFeatures = computeBasicFeatures(zeroNN, dataPath, dataset, zeroTrain);

% save to file
filename = strcat(num2str(yyyymmdd(datetime)), '_', dataset, '_BasicFeatures_.mat');
save(fullfile(outputPath, filename), 'oneFeatures', 'zeroFeatures');

%% Generate features for test data 

dataset = strcat('test_', num2str(ss));

% get all test filenames
[allTest] = getFilenames(ss, 'test', dataPath);

% get indices of filenames that have all 0's, as not using those to predict
indicesTestNonZero = find(~ismember(allTest, cellstr(allZeroFiles.filenames{2*ss,:}))==1);
indicesTestZero = find(ismember(allTest, cellstr(allZeroFiles.filenames{2*ss,:}))==1);
allTestNonZero = allTest(indicesTestNonZero);

testNN = length(allTestNonZero);

% get features: .avg, .med(ian) and .sd
testFeatures = computeBasicFeatures(testNN, dataPath, dataset, allTestNonZero);

% save to file
filename = strcat(num2str(yyyymmdd(datetime)), '_', dataset, '_BasicFeatures.mat');
save(fullfile(outputPath, filename), 'testFeatures', 'indicesTestNonZero', ...
    'indicesTestZero', 'allTestNonZero', 'testNN', 'allTest');
