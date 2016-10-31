function [allFiles, zeroFiles, oneFiles] = getFilenames(ss, trainOrTest, dataPath)
% function [allFiles zeroFiles oneFiles] = getFilenames(ss, trainOrTest= 'train', dataPath = 'C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/data')
% Inputs:
% - ss: 1,2,or 3 the dataset to get filenames for
% - trainOrTest: 'train' or 'test'
% Outputs:
% - allFiles
% - zeroFiles
% - oneFiles

if nargin < 3
     dataPath = 'C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/data';
end
    
dataset = strcat(trainOrTest, '_', num2str(ss));
dirData = dir(fullfile(dataPath, dataset));
dirIndex = [dirData.isdir];
allFiles = {dirData(~dirIndex).name};
allFiles = cellstr(allFiles);

% match filenames that end in zero
if strcmp(trainOrTest,'train')
    zeroIndices=regexp(allFiles,'\w*_0.mat');
    zeroIndices=~cellfun('isempty',zeroIndices);
    zeroFiles = allFiles(1, find(zeroIndices==1));
    oneFiles = allFiles(1,find(zeroIndices==0))
else
    zeroFiles = [];
    oneFiles = [];
end

end