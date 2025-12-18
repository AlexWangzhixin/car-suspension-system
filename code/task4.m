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
% if ~exist('roadLeft', 'var') || ~exist('roadRight', 'var') || ~exist('time', 'var')
%     error('Road profile data not found. Please ensure roadProfile.mat is in the current directory.');
% end

% Display road profile information
disp(['Road profile duration: ', num2str(max(sampledTime)), ' seconds']);
disp(['Number of samples: ', num2str(length(sampledTime))]);
disp(['Sample rate: ', num2str(1/(sampledTime(2)-sampledTime(1))), ' Hz']);

% Prompt user for mode selection
disp('\nPlease select the mode:');
disp('1. Cruise Mode');
disp('2. Sports Mode (Optimized)');
mode = input('Enter your choice (1 or 2): ');

% ==========================================
% 1. 定义物理参数 (根据 Engineering Spec Notes)
% ==========================================

% 参数定义 (基础参数同 Task 1)
M1=60;      % in kg, wheels-axles etc. (for quarter car)
M2=250;     % in kg, chassis (for quarter car)
M3=100;      % in kg, seat and driver (for quarter car)

K1=2000;    % N/m, spring coefficient
K3=100000;  % N/m, spring coefficient
 
C1=800;     % Ns/m, damping coefficient
C3=200;     % Ns/m, damping coefficient


if mode == 1
    % Cruise Mode
    K2 = 8000; 
    C2 = 900;
    mode_name = 'Cruise Mode';
elseif mode == 2
    % Sports Mode (OPTIMIZED)
    % 这里必须使用 Task 3 分析出的最佳参数！
    % 根据你的 task3_analysis.md，最佳设计是 K2=30000, C2=3000
    K2 = 30000;  
    C2 = 3000;   
    mode_name = 'Sports Mode (Optimized Design)';
else
    error('Invalid selection');
end

save('axle_params.mat');

% 运行 Task 4 全桥模型 (需包含左轮和右轮两套系统)
disp(['Running Task 4 simulation for ', mode_name, '...']);
sim('car_suspension_absolutedisplacements_WholeAxle.slx');

% ... (保留原有的 RMSE 和 MAE 计算代码，只要变量名匹配即可) ...