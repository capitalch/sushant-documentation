% clear ; close all; clc
% load('ex6data1.mat');
% plotData(X, y);


file_contents =  'the quick brown fox jumped over the lazy dog';
%readFile('emailSample1.txt');
word_indices  = processEmail(file_contents);
n = 1899;
x = zeros(n, 1);
for wi = word_indices
    x(wi,1) = 1;
end




%{
C = 1;
model = svmTrain(X, y, C, @linearKernel, 1e-3, 20);
visualizeBoundaryLinear(X, y, model);


load('ex6data3.mat');
cVector = [ 0.01 0.03 0.1 0.3 1 3 10 30];
sigmaVector = [ 0.01 0.03 0.1 0.3 1 3 10 30];
m=[];
for i = 1:columns(cVector)
  for j = 1:columns(sigmaVector)
    model= svmTrain(X, y, cVector(i), @(x1, x2) gaussianKernel(x1, x2, sigmaVector(j)));
    predictions = svmPredict(model, Xval);
    err = mean(double(predictions ~= yval));
    m = [m;cVector(i) sigmaVector(j) err];
  endfor
endfor
[minimum, i] = min(m(:,3));
C = m(i,1);
sigma = m(i,2);
%}