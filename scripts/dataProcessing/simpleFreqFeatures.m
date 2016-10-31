%function avgFreq = simpleFreqFeatures(fileToLoad, folderName, windowWidth, windowFracOverlap)
function medFreq = simpleFreqFeatures(fileToLoad, folderName, windowWidth, windowFracOverlap)
% function out = simpleFreqFeatures(fileToLoad, folderName, windowWidth, windowFracOverlap)

for channel = 1:16
    
    %% Load data
    dataPath = '../../data';
    load(fullfile(dataPath, folderName, fileToLoad));
    
    % grab just one channel of the data for now
    signal = dataStruct.data(:,channel);
    beta = 0.5;
    
    % set time parameters
    Fs = 240000/(10*60);
    
    %% Create spectrogram
    
    window = kaiser(windowWidth, beta);
    windowOverlap = floor(windowFracOverlap*windowWidth);
    nfft = 1024;
    
    [s, w, t, ps] = spectrogram(signal,window,windowOverlap,nfft,Fs,'yaxis');
    %ax = gca;
    %ax.YScale = 'log';
    
    fLower = find((w > 5),1);
    fHigher = find((w < 30), 1 , 'last');
    tNonzero = find(sum(ps,1)~=0);
    
    %figure(1); image(ps(fLower:fHigher, tNonzero));
    
    subsetPs = ps(fLower:fHigher, tNonzero);
    % subsetW = w(fLower:fHigher);
    %avgSubsetPs = mean(subsetPs,2);
    %nn = length(avgSubsetPs);
    medSubsetPs = median(subsetPs,2);
    nn = length(medSubsetPs);
    
    if (channel == 1)
        %avgFreq = zeros(1, nn*16);
        medFreq = zeros(1, nn*16);
    end
    %avgFreq(1, (nn*(channel-1)+1):(nn*channel)) =  avgSubsetPs;
    medFreq(1, (nn*(channel-1)+1):(nn*channel)) =  medSubsetPs;
    
end