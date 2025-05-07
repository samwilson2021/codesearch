% ---------------------------------------
% ---------------------------------------

clc; clear; close all;

% Time parameters
t0 = 0;         % Initial time
tf = 10;        % Final time
h = 0.01;       % Step size
N = (tf - t0)/h;

% Initial conditions
y1 = zeros(1, N+1); % y = y1
y2 = zeros(1, N+1); % dy/dt = y2
t = t0:h:tf;

y1(1) = 0;    % y(0)
y2(1) = 1;    % y'(0)

% Define the functions
f1 = @(t, y1, y2) y2;
f2 = @(t, y1, y2) sin(t) - 2*y2 - 5*y1;

% Runge-Kutta 4th Order Method Loop
for i = 1:N
    k1_1 = h * f1(t(i), y1(i), y2(i));
    k1_2 = h * f2(t(i), y1(i), y2(i));

    k2_1 = h * f1(t(i)+h/2, y1(i)+k1_1/2, y2(i)+k1_2/2);
    k2_2 = h * f2(t(i)+h/2, y1(i)+k1_1/2, y2(i)+k1_2/2);

    k3_1 = h * f1(t(i)+h/2, y1(i)+k2_1/2, y2(i)+k2_2/2);
    k3_2 = h * f2(t(i)+h/2, y1(i)+k2_1/2, y2(i)+k2_2/2);

    k4_1 = h * f1(t(i)+h, y1(i)+k3_1, y2(i)+k3_2);
    k4_2 = h * f2(t(i)+h, y1(i)+k3_1, y2(i)+k3_2);

    y1(i+1) = y1(i) + (k1_1 + 2*k2_1 + 2*k3_1 + k4_1)/6;
    y2(i+1) = y2(i) + (k1_2 + 2*k2_2 + 2*k3_2 + k4_2)/6;
end

% -------------------------------
% Plot the results
% -------------------------------
figure;
plot(t, y1, 'b', 'LineWidth', 2);
xlabel('Time (t)');
ylabel('Displacement y(t)');
title('Solution of Second-Order ODE using RK4');
grid on;

figure;
plot(t, y2, 'r', 'LineWidth', 2);
xlabel('Time (t)');
ylabel('Velocity y''(t)');
title('Velocity Profile using RK4');
grid on;

% Combine Displacement and Velocity
figure;
plot(t, y1, 'b', t, y2, 'r--', 'LineWidth', 2);
legend('Displacement y(t)', 'Velocity y''(t)');
title('Displacement and Velocity vs Time');
xlabel('Time (t)');
ylabel('Values');
grid on;

% ---------------------------------------
% ---------------------------------------

