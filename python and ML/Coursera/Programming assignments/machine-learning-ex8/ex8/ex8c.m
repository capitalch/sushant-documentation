%{
    load('ex8data1.mat');
    [m, n] = size(X);
    [mu sigma2] = estimateGaussian(X);

    pval = multivariateGaussian(Xval, mu, sigma2);

    epsilon = min(pval) + (max(pval) - min(pval)) / 1000;
    my = pval < epsilon;
    tp = sum((yval == 1) & (my == 1));
    fp = sum((yval == 0) & (my == 1));
    fn = sum((yval == 1) & (my == 0));

    prec = tp / (tp + fp);
    rec = tp / (tp + fn);

    F1 = 2 * prec * rec / (prec + rec)
%}
% Recommender system

load ('ex8_movies.mat');

load ('ex8_movieParams.mat');

num_users = 4; num_movies = 5; num_features = 3;
X = X(1:num_movies, 1:num_features);
Theta = Theta(1:num_users, 1:num_features);
Y = Y(1:num_movies, 1:num_users);
R = R(1:num_movies, 1:num_users);

J = cofiCostFunc([X(:) ; Theta(:)], Y, R, num_users, num_movies, ...
               num_features, 1.5);