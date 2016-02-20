%% Fixed & Variable Rate Mortgage Calculator
%% Based on - http://en.wikipedia.org/wiki/Mortgage_calculator
clear all;
close all;
clc;

% todo - insert inflation and max and min (std) of the prime rate

% Parameters
Mortgage = 800e3;% Initial fund
Prime = 2.75; % Prime intrest rate [%]
prime_minus = 1.00; % Prime minus rate [Precentage]
ratio_fixed = 2/3;
ratio_variable = 1/3;
r_year = 3.75; % Yearly intrest [%]
num_years = 15; % number of years for return;

% Computations
P_fixed = ratio_fixed*Mortgage; 
P_variable = ratio_variable*Mortgage; 
r_fixed = r_year/100/12; % Fixed monthly return
r_variable = (Prime-prime_minus)/100/12;

N = 12*num_years;

c_fixed = P_fixed*r_fixed/(1-(1+r_fixed)^(-N)); % Monthly fixed return
c_variable = P_variable*r_variable/(1-(1+r_variable)^(-N)); % Monthly variable return

disp(['The initial fund - ',num2str(Mortgage),' NIS']);
disp(['The monthly fixed return is - ',num2str(c_fixed),' NIS']);
disp(['The monthly variable return is - ',num2str(c_variable),' NIS']);
disp(['The total monthly return is - ',num2str(c_variable+c_fixed),' NIS']);
disp(['The total return after ',num2str(num_years),' years - ',num2str((c_fixed + c_variable)*12*15),' NIS']);
disp(['Total intrest paid - ',num2str((c_fixed + c_variable)*12*15-Mortgage),' NIS']);
