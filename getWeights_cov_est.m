% This function will take the stocks

% todo - cover and %25

%% Portfolio
% this section will compute the mean and the variance of the portfolio

% collect different stocks (according to solidit), compute the mean and variance of the optimal
% portfolio
% find the minimum mang fees for them
clear all;
%% Get data
% data_file = 'stocks_data_full';
% data_file = 'stocks_data7_with_ta100';
data_file = 'stocks_data18';
% data_file = 'stocks_data11_with_ta100';
data = load(data_file);
stock_return = data.stock_return;
Nstocks = data.Nstocks;
N_mc = 1;%1e5;


%% find the overlap between the stocks data sets
overlap_len = zeros(Nstocks);
for i=1:Nstocks
    for j=1:Nstocks
        overlap_len(i,j) = min(length(stock_return{i}),length(stock_return{j}));
    end
end

%use parfor!!!! gpu!!!

% show the amount of data

C = zeros(Nstocks);
mu_stocks1 = zeros(N_mc,Nstocks);
cov_stocks_mat = zeros(Nstocks);

%% Monte carlo simulation to find the optimal portfolios (running on random time intervals)
for i=1:N_mc
    for iStock=1:Nstocks
        for jStock=iStock:Nstocks
%             a = overlap_len(iStock,jStock)*rand;
%             b = overlap_len(iStock,jStock)*rand;
            a = 1;
            b = overlap_len(iStock,jStock);
            rand_start = fix(max(a,b)); % since we use the end
            rand_stop = fix(min(a,b));
            len = rand_start - rand_stop + 1;
            if(len < 5)
                continue;
            end

            stock1 = stock_return{iStock}(end-rand_start+1:end-rand_stop-1);
            stock2 = stock_return{jStock}(end-rand_start+1:end-rand_stop-1);
            
            cov_stocks_mat(iStock,jStock) = sum((stock1-mean(stock1)).*(stock2-mean(stock2)))/(len-1);
            cov_stocks_mat(jStock,iStock) = cov_stocks_mat(iStock,jStock);
            
            mu_stocks1(i,iStock) = mean(stock1);
            mu_stocks1(i,jStock) = mean(stock2);
        end
    end
    
    C = C + cov_stocks_mat;% covariance matrix for the stocks in the portfolio
end

C = C/N_mc;
mu_stocks = mu_stocks1;
% figure;hist(mu_stocks1(:,8),100)

%% check the distribution of the returns and risks of each of the portfolios

%% Minimum variance portfolio
w = max(ones(1,Nstocks)*inv(C),0);
data.stock_list
w_min_risk = w/sum(w)
return_min_risk = (mu_stocks*w_min_risk.')
std_min_risk = sqrt(w_min_risk*C*w_min_risk.')
%% Maximum Sharpe ratio portfoio
w = max(mu_stocks*inv(C),0);
data.stock_list
w_max_sharpe = w/sum(w)
return_max_sharpe = (mu_stocks*w_max_sharpe.')
std_max_sharpe = sqrt(w_max_sharpe*C*w_max_sharpe.')

%% Compute the annual return for each portfolio
N = 1e6;
z = zeros(1,N);
risk = [std_min_risk,std_max_sharpe];
return_monthly = [return_min_risk,return_max_sharpe];
for j=1:2
    mean_std = mean(risk(j));
    mean_return = mean(return_monthly(j));
    parfor i=1:N
        n = mean_std*randn(1,12)+mean_return;
        % todo - add here the management costs
        z(i) = exp(sum(log(n)));
    end
    [a,b] = hist(z,100);
    figure;
    a = a/sum(a);
    bar(b,a)
    grid on;
    xlabel('Return');
    ylabel('Probability');
    p0= sum(a(b<1));
    title(['risk under zero - ',num2str(p0)]); % name,risk under 1
    
end