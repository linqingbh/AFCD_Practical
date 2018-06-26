%==========================================================================
%   This program initialises the matrices and constants required for the
%   F16 terrain follow system model and runs the Simulink model
% 
%   Author: Lukas
% 
%==========================================================================
clear;

% load reduced longitudinal state-space matrices and trim state

load redu_ss_terrainfollow
load trim_lo

% Unit conversion factor
ft2m      = 0.3048;

% simulation parameters

h0  = 1500;  % initial altitude [m]
v0  = ft2m*trim_state_lo(7); % initial speed [m/s]
th0 = trim_thrust_lo; % trim thrust setting [lb]
de0 = trim_control_lo(1); % trim elevator deflection [deg]

gclear = 40;    % ground clearance [m]

% control saturation limits

ele_lowlim = -25    - de0;
ele_uplim  = 25     - de0;
th_lowlim  = 1000   - th0;
th_uplim   = 19000  - th0;

% -------------------LQR Outer---------------------------------------------

% assign weights
w_h  = 100;
w_th = 1;
w_v  = 1;
w_a  = 1;
w_q  = 1;

% assemble Q and R matrix
Q_f = diag([w_h, w_th, w_v, w_a, w_q]);
R_f = diag([0.0015 15]);

K_f = lqr(A,B,Q_f,R_f); % full outer matrix

% crop outer LQR matrix
K_o = K_f(:,1);

K_i = K_f(:,2:5);


% -------------------run simulation----------------------------------------

% open_system('terrainfollow_bigcanyon')
sim('terrainfollow_bigcanyon')

% -------------------plot figures------------------------------------------

% altitude figure
figure('pos',[100 100 1200 800]) 

% flightpath(distance)
subplot(2,1,1)
hold on
plot(distance.data(:,1),flightpath.data(:,3),distance.data(:,1),flightpath.data(:,2),':k')
canyon = area(distance.data(:,1),flightpath.data(:,1));
hold off
canyon.FaceColor = [0.5 0.5 0.5];
axis([0,13000,0,1000])
title('Flight Path')
xlabel('Position [m]')
ylabel('Altitude [m]')
legend('Flight Path','Reference Altitude','Canyon Profile','Location','southeast')
grid on

% altitude error(distance)
subplot(2,1,2)
hold on
alterr = plot(distance.data(:,1),alt_error.data(:,3));
uplim  = plot(distance.data(:,1),alt_error.data(:,2),':k');
lowlim = plot(distance.data(:,1),alt_error.data(:,1),':k');
hold off
xlim([0 13000])
title('Tracking Performance')
xlabel('Position [m]')
ylabel('Error [m]')
legend([alterr,uplim],{'Altitude Error','Overshoot Limits'},'Location','southeast')
grid on

print -depsc2 -r1200 figures/flightpath_err_bigcanyon


% Actuator Figure
figure('pos',[100 100 1200 800])

% thrust setting(time)
subplot(2,1,1)
hold on
ele_tot     = plot(ele_inputs.time,ele_inputs.data(:,1));
ele_out     = plot(ele_inputs.time,ele_inputs.data(:,2));
ele_in      = plot(ele_inputs.time,ele_inputs.data(:,3));
hold off
% axis([0,120,-5000,5000])
title('Elevator Input')
xlabel('Time [s]')
ylabel('Elevator deflection [deg]')
legend('Sum','Outer Loop','Inner Loop','Location','northeast')
xlim([0 140])
grid on

% elevator deflection(time)
subplot(2,1,2)
hold on
ele_tot     = plot(ele_inputs.time,ele_inputs.data(:,1));
hold off
% axis([0,120,-5000,5000])
title('Elevator Input (Detail)')
xlabel('Time [s]')
ylabel('Elevator deflection [deg]')
legend('Sum','Location','northeast')
ylim([-2 2])
xlim([0 140])
grid minor

print -depsc2 -r1200 figures/ele_inputs_bigcanyon











