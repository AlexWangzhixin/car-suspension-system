% Task 1: Quarter Car Suspension System Simulation
% Author: Your Name
% Date: Today's Date
% Purpose: Simulate quarter car suspension system for cruise and sports modes
% and analyze step response characteristics

clear all;
close all;
clc;

% Prompt user for mode selection
disp('Please select the mode:');
disp('1. Cruise Mode');
disp('2. Sports Mode');
mode = input('Enter your choice (1 or 2): ');

% Assign parameters based on mode
if mode == 1
    % Cruise Mode Parameters
    M1 = 250;     % Sprung mass (kg) - chassis + driver
    M2 = 50;      % Unsprung mass (kg) - wheel + suspension components
    K1 = 10000;   % Spring stiffness (N/m) - suspension spring
    K2 = 200000;  % Spring stiffness (N/m) - tire stiffness
    C1 = 1500;    % Damping coefficient (Ns/m) - suspension damper
    C2 = 2000;    % Damping coefficient (Ns/m) - tire damping
    mode_name = 'Cruise Mode';
elseif mode == 2
    % Sports Mode Parameters
    M1 = 250;     % Sprung mass (kg) - chassis + driver
    M2 = 50;      % Unsprung mass (kg) - wheel + suspension components
    K1 = 20000;   % Spring stiffness (N/m) - suspension spring (stiffer for sports)
    K2 = 250000;  % Spring stiffness (N/m) - tire stiffness (stiffer for sports)
    C1 = 3000;    % Damping coefficient (Ns/m) - suspension damper (higher for sports)
    C2 = 2500;    % Damping coefficient (Ns/m) - tire damping (higher for sports)
    mode_name = 'Sports Mode';
else
    error('Invalid mode selection. Please run the script again and select 1 or 2.');
end

% Display selected mode and parameters
disp(['\nSelected Mode: ', mode_name]);
disp('Parameters:');
disp(['M1 (Sprung mass): ', num2str(M1), ' kg']);
disp(['M2 (Unsprung mass): ', num2str(M2), ' kg']);
disp(['K1 (Suspension spring): ', num2str(K1), ' N/m']);
disp(['K2 (Tire stiffness): ', num2str(K2), ' N/m']);
disp(['C1 (Suspension damper): ', num2str(C1), ' Ns/m']);
disp(['C2 (Tire damping): ', num2str(C2), ' Ns/m']);

% Save parameters to workspace for Simulink
save('suspension_params.mat', 'M1', 'M2', 'K1', 'K2', 'C1', 'C2');

% Run Simulink model
disp('\nRunning Simulink model...');
sim('task1sim.slx');

% Calculate step response characteristics
disp('\nCalculating step response characteristics...');
step_info = stepinfo(y, t, 0.1);

% Display results
disp(['\nStep Response Characteristics for ', mode_name, ':']);
disp(['Rise Time: ', num2str(step_info.RiseTime), ' seconds']);
disp(['Overshoot: ', num2str(step_info.Overshoot), ' %']);
disp(['Settling Time (2%): ', num2str(step_info.SettlingTime), ' seconds']);

% Calculate settling time to 5%
disp('Calculating settling time to 5%...');
final_value = 0.1;
threshold = 0.05 * final_value;
settling_time_5 = 0;
for i = length(t):-1:1
    if abs(y(i) - final_value) > threshold
        settling_time_5 = t(i+1);
        break;
    end
end
if settling_time_5 == 0
    settling_time_5 = t(end);
end
disp(['Settling Time (5%): ', num2str(settling_time_5), ' seconds']);

% Plot step response
figure('Name', ['Quarter Car Suspension Step Response - ', mode_name]);
plot(t, y, 'LineWidth', 2);
grid on;
xlabel('Time (seconds)');
ylabel('Driver''s Seat Position (m)');
title(['Step Response of Quarter Car Suspension - ', mode_name]);
hline(final_value, 'r--', 'Final Value', 'LineWidth', 1.5);
hline(final_value * 1.02, 'g--', '2% Tolerance', 'LineWidth', 1.5);
hline(final_value * 0.98, 'g--', 'LineWidth', 1.5);
hline(final_value * 1.05, 'm--', '5% Tolerance', 'LineWidth', 1.5);
hline(final_value * 0.95, 'm--', 'LineWidth', 1.5);
legend('Seat Position', 'Final Value', '2% Tolerance', '5% Tolerance');

% Save plot
saveas(gcf, ['step_response_', lower(strrep(mode_name, ' ', '_')), '.png']);

disp('\nSimulation completed successfully!');