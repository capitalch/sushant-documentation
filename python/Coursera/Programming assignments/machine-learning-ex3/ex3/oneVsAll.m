function [all_theta] = oneVsAll(X, y, num_labels, lambda)
%ONEVSALL trains multiple logistic regression classifiers and returns all
%the classifiers in a matrix all_theta, where the i-th row of all_theta 
%corresponds to the classifier for label i
%   [all_theta] = ONEVSALL(X, y, num_labels, lambda) trains num_labels
%   logistic regression classifiers and returns each of these classifiers
%   in a matrix all_theta, where the i-th row of all_theta corresponds 
%   to the classifier for label i

% Some useful variables
m = size(X, 1);
n = size(X, 2);

% You need to return the following variables correctly 
all_theta = zeros(num_labels, n + 1);

% Add ones to the X data matrix
X = [ones(m, 1) X];

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the following code to train num_labels
%               logistic regression classifiers with regularization
%               parameter lambda. 
%
% Hint: theta(:) will return a column vector.
%
% Hint: You can use y == c to obtain a vector of 1's and 0's that tell you
%       whether the ground truth is true/false for this class.
%
% Note: For this assignment, we recommend using fmincg to optimize the cost
%       function. It is okay to use a for-loop (for c = 1:num_labels) to
%       loop over the different classes.
%
%       fmincg works similarly to fminunc, but is more efficient when we
%       are dealing with large number of parameters.
%
% Example Code for fmincg:
%
%     % Set Initial theta
%     initial_theta = zeros(n + 1, 1);
%     
%     % Set options for fminunc
%     options = optimset('GradObj', 'on', 'MaxIter', 50);
% 
%     % Run fmincg to obtain the optimal theta
%     % This function will return theta and the cost 
%     [theta] = ...
%         fmincg (@(t)(lrCostFunction(t, X, (y == c), lambda)), ...
%                 initial_theta, options);
%

initial_theta = zeros(n + 1, 1);
options = optimset('GradObj', 'on', 'MaxIter', 50);
for c = 1:num_labels
    [theta] = fmincg(@(t)lrCostFunction(t,X,(y==c), lambda),initial_theta,options);
    all_theta(c,:) = theta';
end

%{
My understanding:
1) X is m X n matrix. m = number of learning data, n = no of features. You need to add one column of all
ones to X for the x_zero which is always one. so X will be m X (n+1) matrix.
2) y is m X 1 vector 0-10 for output of learning data. There is 5000 learning data. Each data consists of 400 fearures,
equivalent to 20 * 20 for a 20*20 size image.
3) So X and y together is complete learning input and output.
4) No of class is 10 which is from 1 to 10. This is for each digit 1,2,3,4,...10.
5) Purpose is to find out all_theta. Theta is parameter which is to be multiplied with features. Like theta_zero*x_zero  + theta_one*x_one*...theta(n+1)*x(n+1)
6) all_theta is theta values for all ten classes. So it should be 10 X (n+1) matrix
7) fmincg is an octave function which takes input of a function fn with parameters, initial_theta vector and options. It
is to be run in a loop for 10 times for 10 number of classes. Output is theta values for that class. Sy for example,
for 1 there is theta vector, for 2 there is theta vector, for 3 there is theta vector. If you run fmincg ten times,
you will get ten theta row vectors. assimilate all these rows of theta to create a 10 * (n+1) matrix which is the output.
8) fmincg returns those values for theta for which the cost function is minimum.
9) In above code all_theta is 10 X 401 matrix.
10) usage of fmincg is fmincg(anonymous_function,anonymous_function_argument,options).
anonymous function argument is initial_theta as above.
%}










% =========================================================================


end
