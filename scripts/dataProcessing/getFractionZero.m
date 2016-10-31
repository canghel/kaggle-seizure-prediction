%%% Get the fraction of each file which is zero values
% copy paste from prelimDataExploration

%% Preamble

% set paths (everything but first path should be general)
cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts/dataProcessing');
dataPath = '../../data';
outputPath = '../../output/dataProcessing';

% dataset
setVals = [1 2 3];
trainOrTest = {'train_' 'test_'};

% initialize data structure to save dataset names and files with zero
% indices
infoTable.datasets =  cell(6,1);
infoTable.filenames = cell(6,1);
infoTable.fracZero = cell(6,1);

%% Get number/fraction of zeros, loop

count = 1;
for ss = 1:length(setVals) % whether set 1,2, or 3
    for tt = 1:length(trainOrTest) % whether training or testing index
        
        ss = 1; tt = 1;
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
        
        infoTable.datasets{count,1} = dataset;
        infoTable.filenames{count,1} = cellstr(dataFilenames{1,:});
        infoTable.fracZero{count,1} = fracZero;
        count = count+1;
    end
end

filename = strcat(num2str(yyyymmdd(datetime)), '_fracZero.mat');
save(fullfile(outputPath, filename), 'infoTable');
