%%% runSimpleFreqFeatures 
% Get just the frequencies from 0 to 30 over all the channels
% do it for a dataset

% get zero and one filenames
allFiles = getFilenames(whichSet, folderPath);
numFiles = length(allFiles);

%% Get features
windowWidth = 1000;
windowFracOverlap = 1/4;

avgFreq = zeros(numFiles, 1024);

% really slow, really bad... 
for j=1:numFiles
    % just print out some info on progress
    if mod(j, 100)==0
        display(j)
    end
    fileToLoad = allFiles(j);
    fileToLoad = fileToLoad{1};
    % get avg freq
    avgFreq(j,:) = simpleFreqFeatures(fileToLoad, folderPath, windowWidth, windowFracOverlap);
end

filename = strcat(folderName, '_avgFreq.mat');
save(fullfile(outputPath, filename), 'allFiles', 'avgFreq');