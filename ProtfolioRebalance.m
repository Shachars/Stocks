%% Rebalance portfolio script

% Weigths
w = [0.75,0.25,0,0];
if(sum(w)~=1)
    error('weigths do not sum to 1 ...');
end

% Asset price
p = [141.19,144.27,1088.18,113.03]/100;

% Asset name
names = {'MTF TLV 100','GOV Bond','Gold','MAKAM'};

% Current portfolio composition
m(1) = 29438.11;
m(2) = 28854;
m(3) = 16834.14;
m(4) = 19553.06;

% Added fund
v = 2500;

% new number of shares per asset
r = round((v+sum(m)).*w./p);

% ampunt of money to add/sell
d = (v+sum(m)).*w-m;

% print results
clc;
disp('******************************************');
disp('******************************************');
disp(['New portfoio worth : ',num2str(v+sum(m))]);
disp('******************************************');
disp('******************************************');
for i=1:length(p)
    disp(['Asset: ',names{i}]);
    disp(['Asset with price = ',num2str(p(i))]);
    disp([num2str(r(i)),' shares']);
    disp(['Buy with ',num2str(d(i)),' Shekels']);
    disp(['Buy ',num2str(d(i)/p(i)),' shares']);
    disp('------------------------------------------');
end



