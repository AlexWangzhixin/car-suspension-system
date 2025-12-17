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
% 注意：题目给出 C3=300 Ns/m。通常作为并联阻尼处理。
C_seat_fric = 300; 
C1_total = C1 + C_seat_fric; % 总座椅阻尼用于仿真

% 轮胎参数 (Tyre Parameters)
% K3: Wheel-Tyre stiffness
K3 = 120000; % N/m
% C_tyre: 题目未给，通常设为0
C3_tyre = 0; 

% 悬挂参数 (Suspension Parameters) - 取决于模式
if mode == 1
    % Cruise Mode
    K2 = 8000;   % N/m
    C2 = 900;    % Ns/m
    mode_name = 'Cruise Mode';
elseif mode == 2
    % Sports Mode (Base) - 这是Task 1要求的原始Sports Mode
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
    sim('task1sim.slx'); 
catch ME
    error(['Simulink 运行失败: ' ME.message]);
end

% ==========================================
% 3. 结果分析 (Step Response)
% ==========================================
% 假设 Simulink 输出的座椅位置变量名为 y_seat (或 x3)，时间为 tout
% 你需要在 Simulink 中添加 To Workspace 模块导出这些数据
if ~exist('y_seat', 'var')
    error('Simulink 模型未输出 y_seat 变量。请在模型中添加 To Workspace 模块，变量名为 y_seat。');
end

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