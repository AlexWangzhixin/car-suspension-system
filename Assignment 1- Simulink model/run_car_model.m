% TITLE AND PURPOSE OF CODE
% AUTHOR
% DATE

M1=60;      % in kg, wheels-axles etc. (for quarter car)
M2=250;     % in kg, chassis (for quarter car)
M3=25;      % in kg, seat and driver (for quarter car)
 
K1=2000;    % N/m, spring coefficient
K2=10000;   % N/m, spring coefficient
K3=100000;  % N/m, spring coefficient
 
C1=800;     % Ns/m, damping coefficient
C2=1000;    % Ns/m, damping coefficient
C3=200;     % Ns/m, damping coefficient

sim('car_suspension_absolutedisplacements');

%% Plotting
f_size = 15; 
figure
plot(output.Time,output.Data(:,1),'linewidth',2,'markersize',12)  % plot 1st output data vs time, i.e. r
xlabel('Time [s]','interpreter','latex','fontsize',f_size); % name the x axis
ylabel('Input - r(t)','interpreter','latex','fontsize',f_size); % name the y axis
grid on; % show the grid