%% Antenna Input Impedance Noise Calculations
%  This script calculates the noise circles of a LNA for a certain noise
%  temperature at several frequencies. The antenna impedance should be
%  within all circles in order to achieve a noise temperature lower than
%  the maximum allowable noise temperature.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-11-14
clear;
close all;

%% Input data and constants
%  SAV-541+ noise parameters were taken from:
%  https://ww2.minicircuits.com/pdfs/SAV-541+.pdf for bias conditions of
%  Vds = 3V and Ids=40mA

% Reference impedance
Z_0 = 50;

% Filename for S-parameter results, leave empty if no S_11 plot is desired
filename = 'Cloverleaf_Coarse_Ground_Spherical.s1p';
%filename = 'Cloverleaf_Modified_Ground.s2p';
%filename = [];

% Filename for amplifier noise parameters, leave empty if for manual
% settings
filename_amp = 'sav-541+_3V_40mA.mat';
%filename_amp = [];

if isempty(filename_amp)
    % Amplifier noise parameter frequency
    f = [1e9; 2e9; 2.4e9; 3e9];
    %f = 1960e6;

    % Amplifier noise resistance and normalised version
    R_n = [0.041; 0.029; 0.029; 0.034]*50; 
    %R_n = 43.2336;

    % Amplifier optimum noise reflection coefficient
    Gamma_opt_abs   = [0.3563; 0.3885; 0.4009; 0.419];    
    Gamma_opt_angle = [53.32; 102.83; 121.48; 148.20];
    %Gamma_opt_abs   = 0.130;
    %Gamma_opt_angle = 124.48;
    
    % Amplifier minimum noise figure
    F_min_db = [0.146; 0.296; 0.356; 0.446];
    %F_min_db = 10^(1.79/10);
else
    % Load amplifier noise parameters
    load(filename_amp);
    
    % Select frequency range
    f_min = 0.4e9;
    f_max = 3e9;
    
    % Load frequency    
    f = noise_parameters(:,1)*1e9;
    
    % Find indices of f_min and f_max
    f_min_i = find(f >= f_min);
    f_min_i = f_min_i(1);
    
    f_max_i = find(f <= f_max);
    f_max_i = f_max_i(length(f_max_i));
    
    % Reload frequency and all other noise parameters
    f               = noise_parameters(f_min_i:f_max_i,1)*1e9;
    Gamma_opt_abs   = noise_parameters(f_min_i:f_max_i,3);
    Gamma_opt_angle = noise_parameters(f_min_i:f_max_i,4);
    F_min_db        = noise_parameters(f_min_i:f_max_i,2);
    R_n             = noise_parameters(f_min_i:f_max_i,5)*50;
end

F_min       = 10.^(F_min_db/10);
Gamma_opt   = Gamma_opt_abs.*(cosd(Gamma_opt_angle)+1j.*sind(Gamma_opt_angle));
r_n         = R_n/Z_0;

% Maximum allowable noise temperature
T_max = 100;

% Reference temperature
T0 = 290;

% Maximum noise figure
F_max = 1+T_max/T0;
%F_max = 10^(2/10);

% Differential configuration
differential = true;
if differential == true
    % Calculate optimimum noise impedance   
    Z_antenna = (Gamma_opt+1)./(1-Gamma_opt).*Z_0;
    
    % Set new Z_0 to twice the old value
    Z_0 = 2*Z_0;
    
    % Calculate new Gamma_opt
    Gamma_opt = (Z_antenna*2 - Z_0)./(Z_antenna*2+Z_0);
    
    % Calculate new R_n
    R_n = 2*R_n;
    r_n = R_n/Z_0;
end

%% Setup circle
% Calculate N
N = (F_max - F_min)./(4.*r_n).*abs(1+Gamma_opt).^2;

% Circle centre and radius
NC_centre = Gamma_opt./(1+N);
NC_radius = 1./(N+1).*sqrt(N.^2+N-N.*abs(Gamma_opt).^2);

% Plot circle and unit circle
theta = 0:2*pi/100:2*pi;
NC_x = NC_radius.*cos(theta) + real(NC_centre);
NC_y = NC_radius.*sin(theta) + imag(NC_centre);

%% Calculate system noise temperature
if ~isempty(filename)
    % Load data
    data = nport(filename);
    
    f_noise     = data.NetworkData.Frequencies;
    S11_noise   = squeeze(data.NetworkData.Parameters(1,1,:));
    
    % Interpolate noise figure data
    Gamma_opt_abs_noise     = interp1(f, Gamma_opt_abs, f_noise);
    Gamma_opt_angle_noise   = interp1(f, Gamma_opt_angle, f_noise);
    F_min_noise             = interp1(f, F_min, f_noise);
    R_n_noise               = interp1(f, R_n, f_noise);
    
    % Calculate Gamma_opt_noise
    Gamma_opt_noise = Gamma_opt_abs_noise.*(cosd(Gamma_opt_angle_noise)+1j.*sind(Gamma_opt_angle_noise));
    
    % Calculate noise temperature
    T_noise = (F_min_noise + 4.*R_n_noise./Z_0.*abs(S11_noise-Gamma_opt_noise).^2./((1-abs(S11_noise).^2).*abs(1+Gamma_opt_noise).^2)-1).*T0;
    
    figure; hold on;
    plot(f_noise, T_noise);
        
    title('Receiver noise temperature');
    xlabel('Frequency [Hz]'); ylabel('Noise Temperature [K]');
    ylim([0 T_max*1.3]);
    grid on;
end


%% Plot antenna impedance and noise circles
smith_grid = [50 20 10 5 4 3 2 1.8 1.6 1.4 1.2 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1;
              Inf 20 20 10 5 5 5 2 2 2 2 5 2 2 2 2 2 2 2 2 2];

figure; hold on;
if isempty(filename)
    smithplot('GridValue', smith_grid, ...
              'TitleTop', ['SAV-541+ (V_{DS} = 3V, I_{DS}=40mA) Noise Circles @ T = ' num2str(T_max) 'K'], ...
              'TitleTopTextInterpreter', 'tex', 'GridBackgroundColor', 'w', ...
              'TitleBottom', ['Z_0 = ' num2str(Z_0)], 'TitleBottomTextInterpreter', 'tex');
else
    smithplot(data, 1, 1,  ...
              'GridValue', smith_grid, ...
              'TitleTop', ['SAV-541+ (V_{DS} = 3V, I_{DS}=40mA) Noise Circles @ T = ' num2str(T_max) 'K'], ...
              'TitleTopTextInterpreter', 'tex', ...
              'TitleBottom', ['Z_0 = ' num2str(Z_0)], 'TitleBottomTextInterpreter', 'tex');
end

cmap = get(gca, 'colororder');
for i = 1:length(f)
    line(NC_x(i,:), NC_y(i,:), 'DisplayName', [num2str(f(i)./1e9) ' GHz'], 'color', cmap(rem(i-1,7)+1,:));
    
    graphics_centre = line(real(Gamma_opt(i)), imag(Gamma_opt(i)), 'Marker', '+', 'color', cmap(rem(i-1,7)+1,:));
    graphics_centre.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
legend;

% Annotate points
t_offset_x = 0.025;
t_offset_y = -0.025;
for i = 1:length(f)
    text(real(Gamma_opt(i))+t_offset_x, imag(Gamma_opt(i))+t_offset_y, [num2str(f(i)/1e9) ' GHz']);
end

% Plot and calculate ideal antenna impedances
if ~isempty(filename)
    Z_antenna = (Gamma_opt_noise+1)./(1-Gamma_opt_noise).*Z_0;
    
    if differential == true
        Z_antenna = Z_antenna/2;
    end
    
    figure;
    subplot(2,1,1);  hold on;
    plot(f_noise, real(Z_antenna), 'DisplayName', 'Real');
    plot(f_noise, imag(Z_antenna), 'DisplayName', 'Imaginary');
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Input Impedance [\Omega]');
    title('Single-ended');
    
    subplot(2,1,2); hold on;
    plot(f_noise, real(Z_antenna*2), 'DisplayName', 'Real');
    plot(f_noise, imag(Z_antenna*2), 'DisplayName', 'Imaginary');
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Input Impedance [\Omega]');
    title('Differential');
    
end
