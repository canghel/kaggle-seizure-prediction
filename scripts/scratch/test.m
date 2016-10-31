nwin = 2048;
wind = kaiser(nwin,0.5);
nlap = 512;
nfft = 2048;

spectrogram(signal,wind,nlap,nfft,'yaxis')