% This function will take the stocks

% todo - cover and %25

%% Portfolio
% this section will compute the mean and the variance of the portfolio


% collect different stocks (according to solidit), compute the mean and variance of the optimal
% portfolio
% find the minimum mang fees for them

%% Get data
data_file = 'stocks_data';
data = load(data_file);
stock_return = data.stock_return;
Nstocks = data.Nstocks;
N_mc = 10000;


%% find the smallest data set
min_len = 1000000;
for i=1:Nstocks
    tmp = length(stock_return{i});
    if(tmp<min_len)
        min_len = tmp;
    end
end


%% Monte carlo simulation to find the optimal portfolios (running on random time intervals)
return_max_sharpe = zeros(N_mc,1);
std_max_sharpe = zeros(N_mc,1);
std_min_risk = zeros(N_mc,1);
return_min_risk = zeros(N_mc,1);
w_min_risk = zeros(N_mc,Nstocks);
w_max_sharpe = zeros(N_mc,Nstocks);
parfor i=1:N_mc
    a = min_len*rand;
    b = min_len*rand;
    rand_start = fix(max(a,b)); % since we use the end
    rand_stop = fix(min(a,b));
    len = rand_start - rand_stop + 1;
    %make sure that all the stocks are aligned in time!!!!
    stocks_mat = zeros(len,Nstocks);
    for iStock=1:Nstocks
        tmp_v = stock_return{iStock};
        stocks_mat(:,iStock) = tmp_v(end-rand_start:end-rand_stop);
    end
    
    C = cov(stocks_mat);% covariance matrix for the stocks in the portfolio
    mu_stocks = mean(stocks_mat);
    
    %% Minimum variance portfolio
    w = max(ones(1,Nstocks)*inv(C),0);
    w_min_risk(i,:) = w/sum(w);
    return_min_risk(i) = mean(stocks_mat*w_min_risk(i,:).');
    std_min_risk(i) = w_min_risk(i,:)*C*w_min_risk(i,:).';
    %% Maximum Sharpe ratio portfoio
    w = max(mu_stocks*inv(C),0);
    w_max_sharpe(i,:) = w/sum(w);
    return_max_sharpe(i) = mean(stocks_mat*w_max_sharpe(i,:).');
    std_max_sharpe(i) = w_max_sharpe(i,:)*C*w_max_sharpe(i,:).';
end

%% todo - cleanup the nans!!!! and outliers
idx_nan_sharpe = (sum(isnan(w_max_sharpe),2))/Nstocks;
idx_nan_min_risk = (sum(isnan(w_min_risk),2))/Nstocks;
std_min_risk = std_min_risk(idx_nan_min_risk~=1);
std_max_sharpe = std_max_sharpe(idx_nan_sharpe~=1);
return_min_risk = return_min_risk(idx_nan_min_risk~=1);
return_max_sharpe = return_max_sharpe(idx_nan_sharpe~=1);
w_max_sharpe = w_max_sharpe(idx_nan_sharpe~=1,:);
w_min_risk = w_min_risk(idx_nan_min_risk~=1,:);
%% check the distribution of the returns and risks of each of the portfolios

%% Compute the annual return for each portfolio
N = 10000;
z = zeros(1,N);
risk = [std_min_risk,std_max_sharpe];
return_monthly = [return_min_risk,return_max_sharpe];
for j=1:2
    mean_std = median(risk(j,:));
    mean_return = median(return_monthly(j,:));
    parfor i=1:N
        n = mean_std*randn(1,12)+mean_return;
        z(i) = exp(sum(log(n)));
    end
    figure;hist(z)
end

median()

%% todo - the approach shouldn't be estimating the median weights, but to estimate the covarince matrix C using different data!


% todo - sepearate the data collection and read from the file of the
% simulation
% run a mointe carlo simulation for the minimum variance portfolio, and the
% set return portfoilio...
% more stocks