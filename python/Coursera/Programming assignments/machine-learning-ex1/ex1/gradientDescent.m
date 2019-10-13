function [theta, J_history] = gradientDescent(X, y, theta, alpha, num_iters)
%GRADIENTDESCENT Performs gradient descent to learn theta
%   theta = GRADIENTDESCENT(X, y, theta, alpha, num_iters) updates theta by 
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(num_iters, 1);

thetaZero = theta(1,1);
thetaOne = theta(2,1);

theta1 = theta;
x = X(:,2);
for iter = 1:num_iters

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCost) and gradient here.
    %

    H = X * theta1;

    %H = thetaZero * ones(m,1) + thetaOne * (ones(m,1) .* x);
    
    thetaZero = thetaZero - (alpha/m) * sum(H - y);
    thetaOne = thetaOne - (alpha/m) * sum((H - y).* x ) ;
    
    theta1 = [thetaZero;thetaOne];
    % ============================================================

    % Save the cost J in every iteration    
    J_history(iter) = computeCost(X, y, theta);
end
theta = theta1;
end
