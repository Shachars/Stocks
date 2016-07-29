%% Rebalance portfolio script

% Weigths
w = [0.3,0.3,0.2,0.2];
if(sum(w)~=1)
    error('weigths do not sum to 1 ...');
end

% Asset price
p = [140.55,151.85,1269.17,113.01]/100;

% Current portfolio composition
m(1) = 18566.65;
m(2) = 30370;
m(3) = 0;
m(4) = 0;

% Added fund
v = 50000;

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
    disp(['Asset with price = ',num2str(p(i))]);
    disp([num2str(r(i)),' shares']);
    disp(['Buy with ',num2str(d(i)),' Shekels']);
    disp('------------------------------------------');
end



