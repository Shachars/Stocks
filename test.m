w = [0.3,0.3,0.2,0.2];
p = [140.55,151.85,1269.17,113.01]/100;

m(1) = 18566.65;
m(2) = 30370;
m(3) = 0;
m(4) = 0;

% w = [0.5525,0.0975,0.175,0.175];
% p = [0.9981,0.9141,1.119,1.3068];
% 
% m(1) = 81296.24;
% m(2) = 14222.48;
% m(3) = 25027.55;
% m(4) = 25123.23;

v = 50000;

% m = m*100;
% v = v*100;

r = round((v+sum(m)).*w./p)

(v+sum(m)).*w-m