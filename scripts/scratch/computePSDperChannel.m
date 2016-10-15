
%signal = createPSDinputMatrix(signal, windowWidth, windowDist);
numZerosPerWindow = sum(signal==0, 1);

% should do something better here...
signal = signal(:,find(numZerosPerWindow < 0.2*windowWidth));

[pxx, w] = periodogram(signal,kaiser(windowWidth, beta));

filename = strcat(num2str(yyyymmdd(datetime)), '-test-pxx-', fileToLoad,'.txt');
dlmwrite(fullfile(outputPath,filename),pxx)