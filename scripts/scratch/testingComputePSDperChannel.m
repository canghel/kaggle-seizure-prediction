
%% Preamble

fileToLoad = '1_1_0.mat';

cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts/dataProcessing');
dataPath = '../../data';
outputPath = '../../output/dataProcessing';

load(fullfile(dataPath, 'train_1', fileToLoad));

% grab just one channel of the data for now
channel = 1;
signal = dataStruct.data(:,channel);

% window width determined by number of seconds, and window overlap
numSeconds = 5;
overlap = 0.5;
zeroFractionThreshold = 0.2; % ignore windows with more than 0.2 zeros 

% translate into number of data points out of 240000 for the signal
windowWidth = numSeconds/60*240000/10;
windowDist = windowWidth*(1-overlap);
windowZeroThresh = windowWidth*zeroFractionThreshold;

beta = 0.5;  % width for Kaiser window

%computePSDperChannel

