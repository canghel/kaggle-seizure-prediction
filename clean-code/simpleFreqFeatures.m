function avgFreq = simpleFreqFeatures(fileToLoad, folderPath, windowWidth, windowFracOverlap)
% function out = simpleFreqFeatures(fileToLoad, folderPath, windowWidth, windowFracOverlap)

for channel = 1:16
    
    %% Load data

    load(fullfile(folderPath, fileToLoad));
    
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

    fLower = find((w > 5),1);
    fHigher = find((w < 30), 1 , 'last');
    tNonzero = find(sum(ps,1)~=0);
    
    %figure(1); image(ps(fLower:fHigher, tNonzero));
    
    subsetPs = ps(fLower:fHigher, tNonzero);
    % subsetW = w(fLower:fHigher);
    avgSubsetPs = mean(subsetPs,2);
    nn = length(avgSubsetPs);

    
    if (channel == 1)
        avgFreq = zeros(1, nn*16);
    end
    avgFreq(1, (nn*(channel-1)+1):(nn*channel)) =  avgSubsetPs;

end