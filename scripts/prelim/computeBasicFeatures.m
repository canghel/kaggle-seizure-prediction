function features = computeBasicFeatures(NN, dataPath, dataset, fileNames)
% function features = computeBasicFeatures(NN, fileNames, dataPath, dataset)

features.avg = repmat(NaN,NN, 16);
features.med = repmat(NaN,NN, 16);
features.sd = repmat(NaN,NN, 16);

for (jj = 1:NN)
    if (mod(jj,10)==0)
        disp(['At iteration ', num2str(jj)]);
    end
    load(fullfile(dataPath, dataset, fileNames{jj}));
    rowSums = sum(dataStruct.data, 2);
    idxNonzero = find(rowSums~=0);
    numNonzero = length(idxNonzero);
    features.avg(jj,:) = mean(dataStruct.data(idxNonzero,:),1);
    features.med(jj,:) = median(dataStruct.data(idxNonzero,:),1);
    features.sd(jj,:) = std(dataStruct.data(idxNonzero,:),1);
end
