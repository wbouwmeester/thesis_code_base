%% Export Noise Parameters
%  This script can be used to export the noise parameters calculated by the
%  LNA_noise script. The script generates ascii arrays that should be 
%  copied to a .txt and can then be imported via result templates - 
%  General 1D - Load 1D Data File.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-11-15
close all;
clear;

% Load the noise circle
load('noise.mat');
NC_x = NC_x(4,:);
NC_y = NC_y(4,:);

% Add some random frequency data
f_noise = linspace(1.5e9,3e9,length(NC_x));

% Create the to be copied ASCII array
ascii_noise = [f_noise.' NC_x.' NC_y.'];
ascii_Gamma_opt = [f real(Gamma_opt) imag(Gamma_opt)];
ascii_R_n = [f R_n];
ascii_F_min = [f F_min];