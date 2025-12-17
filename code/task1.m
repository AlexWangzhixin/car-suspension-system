% Task 1: Quarter Car Suspension System Simulation (Corrected)
% 修正了参数以匹配 "Sports car design project" pdf
% 修正了模型结构为 3-DOF (包含驾驶员座椅)

clear all; close all; clc;

% Prompt user for mode selection
disp('Please select the mode:' );
disp('1. Cruise Mode' );
disp('2. Sports Mode' );
mode = input('Enter your choice (1 or 2): ' );

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
C_seat_fric = 300 ;
C1_total = C1 + C_seat_fric; % 总座椅阻尼

% 轮胎参数 (Tyre Parameters)
% K3: Wheel-Tyre stiffness
K3 = 120000; % N/m
% C_tyre: 通常忽略或很小，题目未给，可设为0或小值
C_tyre = 0 ;

% 悬挂参数 (Suspension Parameters) - 取决于模式
if mode == 1
    % Cruise Mode
    K2 = 8000;   % N/m
    C2 = 900;    % Ns/m
    mode_name = 'Cruise Mode' ;
elseif mode == 2
    % Sports Mode (Base)
    K2 = 13000;  % N/m
    C2 = 1500;   % Ns/m
    mode_name = 'Sports Mode' ;
else
    error('Invalid mode selection.' );
end

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

% 将参数保存到 workspace 供 Simulink 调用
% 注意：你的 Simulink 模型中的 Gain/参数块 必须使用这些变量名 (M1, M2, M3, K1, K2, K3...)
save('suspension_params.mat', 'M1', 'M2', 'M3', 'K1', 'K2', 'K3', 'C1_total', 'C2', 'C_tyre');

% ==========================================
% 2. 运行 Simulink 模型
% ==========================================
% 确保你的 task1sim.slx 是一个 3-DOF 模型
% 输入: Road Profile r(t) (Step signal, time=0, value=0.1)
% 输出: 必须包含 Driver Seat Position (y_seat 或 x3)
disp(['Running Simulink model for ', mode_name, '...' ]);
try
    sim('task1sim.slx' );
catch
    error('无法运行 task1sim.slx。请确保模型文件存在且参数变量名与脚本一致。' );
end

% ==========================================
% 3. 结果分析 (Step Response)
% ==========================================
% 假设 Simulink 输出的座椅位置变量名为 seat_pos，时间为 tout
% 如果你的模型输出不同，请修改此处
if ~exist('seat_pos', 'var' )
    error('Simulink 模型未输出 seat_pos 变量。请在模型中添加 To Workspace 模块。' );
end

% 计算性能指标 (针对 0.1m 的阶跃输入)
step_amplitude = 0.1 ;
S = stepinfo(seat_pos, tout, step_amplitude);

% Display results
disp(' ' );
disp(['=== Performance Metrics for ', mode_name, ' ===' ]);
disp(['Rise Time: ', num2str(S.RiseTime), ' s' ]);
disp(['Overshoot: ', num2str(S.Overshoot), ' %' ]);
disp(['Settling Time (2%): ', num2str(S.SettlingTime), ' s' ]);

% 计算 5% Settling Time
disp('Calculating settling time to 5%...');
final_value = step_amplitude;
threshold_5 = 0.05 * final_value;
settling_time_5 = 0;
for i = length(tout):-1:1
    if abs(seat_pos(i) - final_value) > threshold_5
        settling_time_5 = tout(i+1);
        break;
    end
end
if settling_time_5 == 0
    settling_time_5 = tout(end);
end
disp(['Settling Time (5%): ', num2str(settling_time_5), ' s']);

% 绘图
figure;
plot(tout, seat_pos, 'LineWidth', 2 );
grid on;
xlabel('Time (s)');
ylabel('Displacement (m)' );
title(['Driver Seat Step Response - ' , mode_name]);
legend('Seat Position' );

% Save plot
saveas(gcf, ['step_response_', lower(strrep(mode_name, ' ', '_')), '.png']);

disp('\nSimulation completed successfully!');