%%% Get the fraction of each file which is zero values
% copy paste from prelimDataExploration

%% Preamble

% initialize data structure to save dataset names and files with zero
% indices
infoTable.datasets =  cell(numDatasets,1);
infoTable.filenames = cell(numDatasets,1);
infoTable.fracZero = cell(numDatasets,1);

%% Get number/fraction of zeros, loop
for idx = 1:numDatasets
    dataset = datasets{idx};
    disp('Working on dataset below: --------------------------------');
    disp(dataset);
    
    % Thanks, SO: http://stackoverflow.com/questions/2652630/
    % how-to-get-all-files-under-a-specific-directory-in-matlab
    % get .mat filenames of the dataset
    dirData = dir(char(datasetPaths(idx)));
    dirIndex = [dirData.isdir];
    dataFilenames = {dirData(~dirIndex).name};
    
    % initialize
    NN = length(dataFilenames);
    fracZero = zeros(1, NN);
    
    for i=1:NN
        % just output info about iteration number
        if (mod(i,100)==0)
            disp(['Getting number of zeros in ', num2str(i),'th file of ', num2str(NN)]);
        end
        load(fullfile(char(datasetPaths(idx)), dataFilenames{i}));
        rowSums = sum(dataStruct.data, 2);
        fracZero(1,i) = sum(rowSums==0)/length(rowSums);
    end
    
    infoTable.datasets{idx,1} = dataset;
    infoTable.filenames{idx,1} = dataFilenames;
    infoTable.fracZero{idx,1} = fracZero;
end

filename = 'fracZero.mat';
save(fullfile(outputPath, filename), 'infoTable');
