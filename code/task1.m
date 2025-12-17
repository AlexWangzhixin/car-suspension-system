% Task 1: Quarter Car Suspension System Simulation (Corrected)
% Author: Your Name
% Date: Today's Date

clear all; close all; clc;

% Prompt user for mode selection
disp('Please select the mode:');
disp('1. Cruise Mode');
disp('2. Sports Mode');
mode = input('Enter your choice (1 or 2): ');

% ==========================================
% 1. 定义物理参数 (根据 Engineering Spec Notes)
% ==========================================
% 质量 (Masses)
% M3: Driver's seat and fixings (including driver)
M1=60;      % in kg, wheels-axles etc. (for quarter car)
M2=250;     % in kg, chassis (for quarter car)
M3=100;      % in kg, seat and driver (for quarter car)

K1=2000;    % N/m, spring coefficient
K3=100000;  % N/m, spring coefficient
 
C1=800;     % Ns/m, damping coefficient
C3=200;     % Ns/m, damping coefficient

% 悬挂参数 (Suspension Parameters) - 取决于模式
if mode == 1
    % Cruise Mode
    K2 = 8000;   % N/m
    C2 = 900;    % Ns/m
    mode_name = 'Cruise Mode';
elseif mode == 2
    % Sports Mode (Base) 
    K2 = 13000;  % N/m
    C2 = 1500;   % Ns/m
    mode_name = 'Sports Mode';
else
    error('Invalid mode selection.');
end

% 将参数保存到 workspace 供 Simulink 调用
% 注意：你的 Simulink 模型中的 Gain/参数块 必须使用这些变量名 (M1, M2, M3, K1, K2, K3...)
save('suspension_params.mat');

% ==========================================
% 2. 运行 Simulink 模型
% ==========================================
disp(['Running Simulink model for ', mode_name, '...']);
% 确保 task1sim.slx 是一个包含 M3 (座椅) 的 3-DOF 模型
try
    sim('car_suspension_absolutedisplacements.slx'); 
catch ME
    error(['Simulink 运行失败: ' ME.message]);
end

% ==========================================
% 3. 结果分析 (Step Response)
% ==========================================
data_matrix = output.Data;
time_vector = output.Time;

% 假设第4列是座椅绝对位移 (y_seat = r+x+y+z)
y_seat = data_matrix(:, 4);  % 提取第4列作为座椅位移
tout = time_vector;          % 时间向量

% 计算性能指标 (针对 0.1m 的阶跃输入)
step_amplitude = 0.1;
S = stepinfo(y_seat, tout, step_amplitude, 'SettlingTimeThreshold', 0.02); % 2% Settling Time

disp(' ');
disp(['=== Performance Metrics for ', mode_name, ' ===']);
disp(['Rise Time: ', num2str(S.RiseTime), ' s']);
disp(['Overshoot: ', num2str(S.Overshoot), ' %']);
disp(['Settling Time (2%): ', num2str(S.SettlingTime), ' s']);

% 计算 5% Settling Time (Matlab stepinfo 默认只给一个，需手动算或再次调用)
S5 = stepinfo(y_seat, tout, step_amplitude, 'SettlingTimeThreshold', 0.05);
disp(['Settling Time (5%): ', num2str(S5.SettlingTime), ' s']);

% 绘图
figure('Name', ['Step Response - ', mode_name]);
plot(tout, y_seat, 'LineWidth', 2); grid on;
xlabel('Time (s)'); ylabel('Displacement (m)');
title(['Driver Seat Step Response - ', mode_name]);
legend('Seat Position');