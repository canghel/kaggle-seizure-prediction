%% Load file 

fileToLoad = '1_37_1.mat'; kk = 4;

cd('C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts/dataProcessing');
dataPath = '../../data';
outputPath = '../../output/dataProcessing';

load(fullfile(dataPath, 'train_1', fileToLoad));

% grab just one channel of the data for now
channel = 1;
signal = dataStruct.data(:,channel);
beta = 0.5;

Fs = 240000/(10*60);
t = 1/Fs:1/Fs:10*60;


%% Create spectrogram

windowWidth = 1000;
window = kaiser(windowWidth, beta);
windowOverlap = windowWidth/4;
nfft = 1024;

[s w t ps] = spectrogram(signal,window,windowOverlap,nfft,Fs,'yaxis');
%ax = gca;
%ax.YScale = 'log';

fLower = min(find(w > 5));
fHigher = max(find(w < 30));
tNonzero = find(sum(ps,1)~=0);

%figure(kk); image(ps(fLower:fHigher, tNonzero));

subsetPs = ps(fLower:fHigher, tNonzero);
subsetW = w(fLower:fHigher);
figure(kk); plot(subsetW, mean(subsetPs,2));

