
setwd("C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/scripts/dataProcessing/");
outputPath <- "C:/Users/cvanghel/Documents/personal-projects/kaggle-seizure-prediction/output/dataProcessing";
  
#library("gplots");

pxx <- read.csv(
  file = file.path(outputPath, paste0('20161008-test-pxx-',fileToLoad,'.txt')),
  sep = ",",
  header = FALSE,
  quote = "",
  stringsAsFactors = FALSE
)

#png(file.path(outputPath, "testpxx.png")); heatmap(as.matrix(pxx), Rowv=NA, Colv=NA); dev.off();

pxxCollapsed <- NULL;
for(j in 1:floor(nrow(pxx)/25)){
  pxxCollapsed <- rbind(pxxCollapsed, apply(pxx[(25*j+1):25*j,], 2, sum, na.rm=TRUE));
}

png(file.path(outputPath, paste0("testpxx-",fileToLoad,".png"))); heatmap.2(as.matrix(pxxCollapsed)[15:20,], tracecol=NAR, Rowv=NA, Colv=NA); dev.off();

m <- log10(as.matrix(pxxCollapsed)[2:41,]+1);
v <- apply(m, 1, max);
w <- m;
for (j in 1:length(v)){
  w[j,] <- w[j,]/v[j];
}

png(file.path(outputPath, paste0("rowsums-",fileToLoad,".png"))); plot(2:41, rowSums(m)/ncol(m), type="l"); dev.off();
png(file.path(outputPath, paste0("med-m-",fileToLoad,".png"))); plot(2:41, apply(m,1,median), type="l"); dev.off();
png(file.path(outputPath, paste0("mean-w-",fileToLoad,".png"))); plot(2:41, apply(w,1,mean), type="l"); dev.off();
#png(file.path(outputPath, paste0("median-",fileToLoad,".png"))); plot(2:41, apply(w, 1, median), type="l"); dev.off();
