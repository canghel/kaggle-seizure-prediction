%%% runSimpleFreqFeatures 
% Get just the frequencies from 0 to 30 over all the channels
% do it for a dataset

%% Load dataset

dataPath = '../../data';
folderName = strcat(whichSet, '_', num2str(ss), '_new');
outputPath = '../../output/dataProcessing';

% get zero and one filenames
allFiles = getFilenames(ss, whichSet, dataPath);
numFiles = length(allFiles);

%% Get features
windowWidth = 1000;
windowFracOverlap = 1/4;

avgFreq = zeros(numFiles, 1024);
%medFreq = zeros(numFiles, 1024);

% really slow, really bad... 
for j=1:numFiles
    % just print out some info on progress
    if mod(j, 100)==0
        display(j)
    end
    fileToLoad = allFiles(j);
    fileToLoad = fileToLoad{1};
    % get avg freq
    avgFreq(j,:) = simpleFreqFeatures(fileToLoad, folderName, windowWidth, windowFracOverlap);
    % medFreq(j,:) = simpleFreqFeatures(fileToLoad, folderName, windowWidth, windowFracOverlap);
end

filename = strcat(num2str(yyyymmdd(datetime)), '_', folderName, '_avgFreq.mat');
save(fullfile(outputPath, filename), 'allFiles', 'avgFreq');

%filename = strcat(num2str(yyyymmdd(datetime)), '_', folderName, '_medFreq.mat');
%save(fullfile(outputPath, filename), 'allFiles', 'medFreq');