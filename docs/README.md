# kaggle-seizure-prediction
Work for 2016-09 to 2016-12 on [Melbourne University AES/MathWorks/NIH Seizure Prediction](https://www.kaggle.com/c/melbourne-university-seizure-prediction)

Ranking: Top 3% (13/478)

## Method description

### Feature extraction/selection

I used only frequency data from the EEG electrical signals for each patient (due to lack of time), following an approach somewhat similar to

> Junhua Li, Zbigniew Struzik, Liqing Zhang and Andrzej Cichocki. [Feature learning from incomplete EEG with denoising autoencoder.](http://www.bsp.brain.riken.jp/publications/2015/FeaturelearningfromincompleteEEG.pdf) Neurocomputing. 165 (2015) 25-36.

The details are as follows:

*	For each channel, I used a windowed Fourier transform to get the local frequencies in overlapping windows along the signal.  I chose a [Kaiser window](https://www.mathworks.com/help/signal/ug/kaiser-window.html) with the default \beta = 0.05, of window length 1000 points (= 2.5 s) and a small overlap of 1/4 of the window length (i.e. 250 points = 0.625 s). 
*	To further restrict the number of features, I selected only the frequencies in the 5-30 Hz range.  Li et al. restrict to 8-30 Hz for motor imagery, and a quick Internet search reveals that the range of frequencies traditionally associated to an epilepsy seisure is 0.1-0.5 Hz to 30-40 Hz although higher frequency oscillations are also likely to be important (e.g. Greg A. Worrell et al. [Brain (2004), 127, 1496-1506](http://brain.oxfordjournals.org/content/127/7/1496)).
*	For each channel, I took the mean of the frequencies across all windows. 
*	Similar to Li et al., I concatenated the frequency data of each of the 16 channels into a long feature vector for each patient. 

### Models

(Under construnction)

### Code

The code for my last submission and the instructions on how to run it is in the `clean-code` directory.

### Possible improvements

(Under construnction)

### Acknowledgments

I received a complimentary MathWorks MATLAB license to use for the competition and used MATLAB for my feature selection code. 