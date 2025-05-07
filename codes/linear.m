% --------------------------------------

% --------------------------------------

% 1. Solving simple 2x2 system
% System:
% 5x + 9y = 5
% 3x - 6y = 4

A1 = [5, 9; 3, -6]; % Coefficient matrix
b1 = [5; 4];        % Right-hand side vector

x1 = A1 \ b1;       % Solve Ax = b using left division
disp('Solution for 2x2 system:');
disp(['x = ', num2str(x1(1))]);
disp(['y = ', num2str(x1(2))]);

% --------------------------------------

% 2. Solving 3x3 system
% System:
% x + 3y - 2z = 5
% 3x + 5y + 6z = 7
% 2x + 4y + 3z = 8

A2 = [1, 3, -2; 3, 5, 6; 2, 4, 3]; % Coefficient matrix
b2 = [5; 7; 8];                   % Right-hand side vector

x2 = A2 \ b2;       % Solve Ax = b using left division
disp('Solution for 3x3 system:');
disp(['x = ', num2str(x2(1))]);
disp(['y = ', num2str(x2(2))]);
disp(['z = ', num2str(x2(3))]);

% --------------------------------------
% Symbolic Operations (Make sure symbolic package is installed)
% --------------------------------------

pkg load symbolic    % Load symbolic package

% Define symbolic variables
syms x y z

% 3. Expand equations
disp('Expanded expressions:');
disp(expand((x - 5)*(x + 9)));
disp(expand((x + 2)*(x - 3)*(x - 5)*(x + 7)));
disp(expand(sin(2*x)));
disp(expand(cos(x + y)));

% 4. Collect equations (organize terms)
disp('Collected expressions:');
disp(collect(x^3 * (x - 7), x));
disp(collect(x^4 * (x - 3) * (x - 5), x));

% 5. Factorization and Simplification
disp('Factorization and Simplification:');
disp(factor(x^3 - y^3));                     % Factor a^3 - b^3
disp(factor([x^2 - y^2, x^3 + y^3]));         % Factor multiple expressions
disp(simplify((x^4 - 16)/(x^2 - 4)));         % Simplify rational expression




