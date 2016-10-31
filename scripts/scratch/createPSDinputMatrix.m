function out = createPSDinputMatrix(signal, windowWidth, windowDist)
% function out = createPSDinputMatrix(signal, windowWidth, windowDist)
%
% Assume overlap is 1/2!! (generalize later)
% try to reshape the signal into segments to use in the power spectrum
% density calculation, without using a for loop
%
% Inputs:
% - signal = 240000x1 matrix of one channel
% - windowWidth = width of the window, in number of data points (e.g. 2000)
% - windowDist = distance to next window; assumes overlap is 1/2 at this
% point so it's 1/2 windowWidth (redundant input)
% Outputs:
% - out = windowWidth x ((2*240000/n) segments), where 2 comes from the
% ovelap being 1/2

n = length(signal);

% non-overlapping windows, cutting the signal by window length
% number of rows and columns for A
nA = n/windowWidth;
A = reshape(signal, windowWidth, nA);

% overlapping 1/2 windows, add zeros last bit
leftOver = n - length([windowDist+1:n]);
B = [signal(windowDist+1:end); zeros(leftOver,1)];
B = reshape(B, windowWidth, nA);

% reshape into needed size
out = [A ; B];
out = reshape(out, windowWidth, 2*nA);

% % quick sanity check:
% all(out(:,1) == A(:,1))
% all(out(:,2) == B(:,1))
% all(out(:,3) == A(:,2))
% all(out(:,4) == B(:,2))

end
