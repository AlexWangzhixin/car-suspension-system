% Task 4: Full Axle Suspension System Simulation with Road Profile
% Purpose: Simulate full axle suspension system with realistic road profile
% and calculate RMSE and MAE for traction and stability analysis
% Corrected: Using 3-DOF model parameters and optimized Sports Mode

clear all;
close all;
clc;

% Load road profile data
disp('Loading road profile data...');
load('roadProfile.mat');

% Check if road profile data is loaded correctly
if ~exist('roadLeft', 'var') || ~exist('roadRight', 'var') || ~exist('time', 'var')
    error('Road profile data not found. Please ensure roadProfile.mat is in the current directory.');
end

% Display road profile information
disp(['Road profile duration: ', num2str(max(time)), ' seconds']);
disp(['Number of samples: ', num2str(length(time))]);
disp(['Sample rate: ', num2str(1/(time(2)-time(1))), ' Hz']);

% Prompt user for mode selection
disp('\nPlease select the mode:');
disp('1. Cruise Mode');
disp('2. Sports Mode (Optimized)');
mode = input('Enter your choice (1 or 2): ');

% ==========================================
% 1. 定义物理参数 (根据 Engineering Spec Notes)
% ==========================================
% 质量 (Masses)
% M3: Driver's seat and fixings (including driver)
M3 = 100; % kg
% M2: Vehicle chassis (Sprung mass relative to suspension)
M2 = 250; % kg
% M1: Wheels, axles etc. (Unsprung mass)
M1 = 50;  % kg

% 座椅参数 (Seat Parameters)
% K1: Driver's seat stiffness
K1 = 2200; % N/m
% C1: Driver's seat damping
C1 = 700;  % Ns/m
% C3: Driver's seat back friction (Viscous equivalent)
C_seat_fric = 300 ;
C1_total = C1 + C_seat_fric; % 总座椅阻尼

% 轮胎参数 (Tyre Parameters)
% K3: Wheel-Tyre stiffness
K3 = 120000; % N/m
% C_tyre: 通常忽略或很小，题目未给，可设为0或小值
C_tyre = 0 ;

% 悬挂参数 (Suspension Parameters) - 取决于模式
if mode == 1
    % Cruise Mode (Standard)
    K2 = 8000;   % N/m
    C2 = 900;    % Ns/m
    mode_name = 'Cruise Mode';
elseif mode == 2
    % Sports Mode (OPTIMIZED from Task 3)
    % 题目 Task 4 要求验证 "Proposed Design"
    K2 = 30000;  % 来自 Task 3 的推荐值
    C2 = 3000;   % 来自 Task 3 的推荐值
    mode_name = 'Sports Mode (Optimized)';
else
    error('Invalid selection');
end

% Task 2: Add bump-stops to limit relative displacement between wheel and chassis to +/- 2cm
bump_stop_limit = 0.02;  % 2cm limit

% Display selected mode and parameters
disp(['\nSelected Mode: ', mode_name]);
disp('Parameters:');
disp(['M1 (Unsprung mass - Wheels): ', num2str(M1), ' kg']);
disp(['M2 (Sprung mass - Chassis): ', num2str(M2), ' kg']);
disp(['M3 (Driver + Seat mass): ', num2str(M3), ' kg']);
disp(['K1 (Seat stiffness): ', num2str(K1), ' N/m']);
disp(['K2 (Suspension stiffness): ', num2str(K2), ' N/m']);
disp(['K3 (Tire stiffness): ', num2str(K3), ' N/m']);
disp(['C1 (Seat damping total): ', num2str(C1_total), ' Ns/m']);
disp(['C2 (Suspension damping): ', num2str(C2), ' Ns/m']);
disp(['C_tyre (Tire damping): ', num2str(C_tyre), ' Ns/m']);
disp(['Bump-stop limit: +/-', num2str(bump_stop_limit*100), ' cm']);

% Save parameters to workspace for Simulink
save('axle_params.mat', 'M1', 'M2', 'M3', 'K1', 'K2', 'K3', 'C1_total', 'C2', 'C_tyre', 'bump_stop_limit', 'roadLeft', 'roadRight', 'time');

% Run Simulink model
disp('\nRunning Simulink model...');
sim('task4sim.slx');

% Calculate RMSE for each wheel
disp('\nCalculating RMSE for each wheel...');
rmse_left = sqrt(mean((wheelLeft - roadLeft).^2));
rmse_right = sqrt(mean((wheelRight - roadRight).^2));
rmse_avg = (rmse_left + rmse_right) / 2;

% Display RMSE results
disp(['\nRMSE Results for ', mode_name, ':']);
disp(['Left Wheel RMSE: ', num2str(rmse_left), ' m']);
disp(['Right Wheel RMSE: ', num2str(rmse_right), ' m']);
disp(['Average RMSE: ', num2str(rmse_avg), ' m']);

% Calculate MAE between left and right wheels
disp('\nCalculating MAE between left and right wheels...');
mae_wheels = mean(abs(wheelLeft - wheelRight));

% Display MAE results
disp(['\nMAE Results for ', mode_name, ':']);
disp(['Left-Right Wheel MAE: ', num2str(mae_wheels), ' m']);

% Plot results
disp('\nGenerating plots...');

% Plot 1: Road profile vs Wheel positions
figure('Name', ['Road Profile vs Wheel Positions - ', mode_name]);
plot(time, roadLeft, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Left Road Profile');
hold on;
plot(time, wheelLeft, 'b-', 'LineWidth', 2, 'DisplayName', 'Left Wheel Position');
plot(time, roadRight, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Right Road Profile');
plot(time, wheelRight, 'r-', 'LineWidth', 2, 'DisplayName', 'Right Wheel Position');
grid on;
xlabel('Time (seconds)');
ylabel('Displacement (m)');
title(['Road Profile vs Wheel Positions - ', mode_name]);
legend('Location', 'Best');

% Plot 2: Wheel position difference (stability indicator)
figure('Name', ['Left-Right Wheel Position Difference - ', mode_name]);
plot(time, wheelLeft - wheelRight, 'g-', 'LineWidth', 2);
grid on;
xlabel('Time (seconds)');
ylabel('Position Difference (m)');
title(['Left-Right Wheel Position Difference - ', mode_name]);
hline(0, 'r--', 'Zero Difference', 'LineWidth', 1.5);

% Plot 3: Chassis position
figure('Name', ['Chassis Position - ', mode_name]);
plot(time, chassis, 'k-', 'LineWidth', 2);
grid on;
xlabel('Time (seconds)');
ylabel('Displacement (m)');
title(['Chassis Position - ', mode_name]);

% Save plots
saveas(1, ['road_vs_wheel_', lower(strrep(mode_name, ' ', '_')), '.png']);
saveas(2, ['wheel_difference_', lower(strrep(mode_name, ' ', '_')), '.png']);
saveas(3, ['chassis_position_', lower(strrep(mode_name, ' ', '_')), '.png']);

% Display summary table
disp('\n=== Summary Results ===');
disp(['Mode: ', mode_name]);
disp(' ');
disp('RMSE Values:');
disp(['  Left Wheel: ', num2str(rmse_left*1000), ' mm']);
disp(['  Right Wheel: ', num2str(rmse_right*1000), ' mm']);
disp(['  Average: ', num2str(rmse_avg*1000), ' mm']);
disp(' ');
disp('MAE Values:');
disp(['  Left-Right Wheel Difference: ', num2str(mae_wheels*1000), ' mm']);
disp(' ');
disp('Interpretation:');
disp('  - Lower RMSE indicates better traction (wheel follows road more closely)');
disp('  - Lower MAE indicates better horizontal stability (balanced suspension)');

% Save results to file
save(['task4_results_', lower(strrep(mode_name, ' ', '_')), '.mat'], ...
    'rmse_left', 'rmse_right', 'rmse_avg', 'mae_wheels', 'mode_name', 'time', ...
    'roadLeft', 'roadRight', 'wheelLeft', 'wheelRight', 'chassis');

disp('\nSimulation completed successfully!');
disp('Results saved to MAT-file for further analysis.');