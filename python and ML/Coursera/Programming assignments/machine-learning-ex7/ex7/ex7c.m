%load('ex7data2.mat');
%K = 3; % 3 Centroids
%initial_centroids = [3 3; 6 2; 8 5];
%idx = findClosestCentroids(X, initial_centroids);
%centroids = computeCentroids(X, idx, K);

[m, n] = size(X);
load ('ex7data1.mat');
[X_norm, mu, sigma] = featureNormalize(X);
[U, S] = pca(X_norm);

Z = projectData(X_norm, U, K);
U_reduce = U(:,1:K);
UT_reduce = U_reduce';
rec = Z * UT_reduce


