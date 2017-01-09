function [allFiles, zeroFiles, oneFiles] = getFilenames(trainOrTest, folderPath)
% function [allFiles zeroFiles oneFiles] = getFilenames(trainOrTest, folderPath)
% Inputs:
% - trainOrTest: 'train' or 'test'
% - folderPath
% Outputs:
% - allFiles
% - zeroFiles
% - oneFiles

dirData = dir(folderPath);
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