clear; clc;

% 固定参数（可根据任务1/2设置调整）
M1=60;      % in kg, wheels-axles etc. (for quarter car)
M2=250;     % in kg, chassis (for quarter car)
M3=100;      % in kg, seat and driver (for quarter car)

K1=2000;    % N/m, spring coefficient
K3=100000;  % N/m, spring coefficient
 
C1=800;     % Ns/m, damping coefficient
C3=200;     % Ns/m, damping coefficient

% 要扫描的 K2 和 C2 值
K2_vals = [5000, 13000, 30000, 50000];
C2_vals = [1000, 1500, 3000, 6000];

% 结果矩阵
settlingTimes = zeros(numel(K2_vals), numel(C2_vals));
overshoots    = zeros(numel(K2_vals), numel(C2_vals));

for i = 1:length(K2_vals)
    K2 = K2_vals(i);
    for j = 1:length(C2_vals)
        C2 = C2_vals(j);
        % 将参数写入工作区，供 Simulink 模型使用
        save('suspension_params.mat', 'M1','M2','M3','K1','K2','K3','C1','C2','C3');

        % 运行三自由度模型（确保模型使用绝对位移输出）
        simOut = sim('car_suspension_absolutedisplacements_task3.slx');

        % 提取座椅绝对位移(第4列)
        y_seat = output.Data;
        t = output.Time;

        % 计算阶跃响应指标
        S = stepinfo(y_seat, t, 0.1, 'SettlingTimeThreshold', 0.02);
        settlingTimes(i,j) = S.SettlingTime;
        overshoots(i,j)    = S.Overshoot;
    end
end

% 打印结果表格
fprintf('Settling Time (s) for combinations of K2 and C2:\\n');
disp(array2table(settlingTimes, 'RowNames', string(K2_vals), 'VariableNames', strcat(string(C2_vals))));
fprintf('\\nPercentage Overshoot (%%) for combinations of K2 and C2:\\n');
disp(array2table(overshoots,    'RowNames', string(K2_vals), 'VariableNames', strcat(string(C2_vals))));
