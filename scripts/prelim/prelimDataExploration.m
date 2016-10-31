%%% prelimDataExploration.m
% basic data exploration

%% Preamble

% set paths (everything but first path should be general)
cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts');
dataPath = '../data';
outputPath = '../output/prelim';

% dataset
setVals = [1 2 3];
trainOrTest = {'train_' 'test_'};

% initialize data structure to save dataset names and files with zero
% indices
allZeroFiles.datasets =  cell(6,1);
allZeroFiles.filenames = cell(6,1);

%% Get number/fraction of zeros, loop

count = 1;
for ss = 1:length(setVals) % whether set 1,2, or 3
    for tt = 1:length(trainOrTest) % whether training or testing index
        dataset = strcat(trainOrTest{tt}, num2str(setVals(ss)));
        disp('Working on dataset below: --------------------------------');
        disp(dataset);
        
        % Thanks, SO: http://stackoverflow.com/questions/2652630/
        % how-to-get-all-files-under-a-specific-directory-in-matlab
        % get .mat filenames of the dataset
        dirData = dir(fullfile(dataPath, dataset));
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
            load(fullfile(dataPath, dataset, dataFilenames{i}));
            rowSums = sum(dataStruct.data, 2);
            fracZero(1,i) = sum(rowSums==0)/length(rowSums);
        end
        
        zeroIndices = find(fracZero==1);
        allZeroFiles.datasets{count,1} = dataset;
        % hmm... don't like this, can't remember how to choose proper
        % data structure, this is 32x12, have to index (row#,:) to get
        % name of datafile
        allZeroFiles.filenames{count,1} = cellstr(dataFilenames{1,zeroIndices});
        count = count+1;
    end
end

%% Plot num zeros info
% https://www.kaggle.com/pakozm/melbourne-university-seizure-prediction/dropoutcounts/output
% reproducing Francisco Zamora-Martinez's plots
zeroIndices = find(fracZero==1);

% just reminder of how unique works, from Matlab help:
% a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
% [c1,ia1,ic1] = unique(a)
% % returns
% c1 = [1 2 4 5 6 7 8 9]
% ia1 = [21 20 19 17 14 11 7 1]'
% ic1 = [8 8 8 8 8 8 7 7 7 7 6 6 6 5 5 5 4 4 3 2 1]'
[fracValues, ia, ic] = unique(sort(fracZero, 'descend'));
plot(unique(sort(fracZero, 'descend')), fliplr((ia-1)/NN));

%% Save
% must be an easier way to do this...

filename = strcat(num2str(yyyymmdd(datetime)), '_FilesnamesWithAllZeros.mat');
save(fullfile(outputPath, filename), 'allZeroFiles');