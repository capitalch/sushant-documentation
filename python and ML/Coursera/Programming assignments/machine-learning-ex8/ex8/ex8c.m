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

