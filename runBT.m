%% Brute force portfolio selection


% runBT(w,data,Cfg)

Cfg.RB_rate
Cfg.transaction_cost


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
data_file = 'stocks_data60_years';
% data_file = 'stocks_data11_with_ta100';
data = load(data_file);
stock_return = data.stock_return;
Nstocks = data.Nstocks-1;
N_division = 100;%1e5;


%% find the overlap between the stocks data sets
overlap_len = zeros(Nstocks);
for i=1:Nstocks
    for j=1:Nstocks
        overlap_len(i,j) = min(length(stock_return{i}),length(stock_return{j}));
    end
end

%use parfor!!!! gpu!!!

C = zeros(Nstocks);
mu_stocks1 = zeros(N_division,Nstocks);
cov_stocks = cell(1,N_division);
w_min_risk = cell(1,N_division);
return_min_risk = cell(1,N_division);
std_min_risk = cell(1,N_division);
w_max_sharpe = cell(1,N_division);
return_max_sharpe = cell(1,N_division);
std_max_sharpe = cell(1,N_division);
w_mim_loss = cell(1,N_division);
return_mim_loss = cell(1,N_division);
std_mim_loss = cell(1,N_division);

for i=1:N_division
    cov_stocks_mat = zeros(Nstocks);
    for iStock=1:Nstocks
        len_stock = length(stock_return{iStock});
        mu_stocks1(i,iStock) = mean(stock_return{iStock}(1+(i-1)*len_stock/N_division:(i)*len_stock/N_division));
        for jStock=iStock:Nstocks
            overlap = overlap_len(iStock,jStock);
            if(overlap < 5)
                continue;
            end
            if((i)*len_stock/N_division > len_stock - overlap)
                start = max(len_stock - overlap,(i-1)*len_stock/N_division);
                stock1 = stock_return{iStock}(start+1:(i)*len_stock/N_division);
                if(isempty(stock1))
                    continue;
                end
                end_idx = len_stock - (i)*len_stock/N_division;
                len2 = length(stock_return{jStock});
                stock2 = stock_return{jStock}(max(len2 - end_idx-len_stock/N_division+1,1):len2 - end_idx);
                cov_stocks_mat(iStock,jStock) = sum((stock1-mean(stock1)).*(stock2-mean(stock2)))/(length(stock1)-1);
                cov_stocks_mat(jStock,iStock) = cov_stocks_mat(iStock,jStock);
            else
                continue;
            end
            
        end
    end
    cov_stocks{i} = cov_stocks_mat;
    
    %% compute the optimal portfolios
    C = cov_stocks_mat;
    mu_stocks = mu_stocks1(i,:);
    
    %% Minimum variance portfolio
    w = max(ones(1,Nstocks)*inv(C),0);
%     data.stock_list
    w_min_risk{i} = w/sum(w);
    return_min_risk{i} = (mu_stocks*w_min_risk{i}.');
    std_min_risk{i} = sqrt(w_min_risk{i}*C*w_min_risk{i}.');
    %% Maximum Sharpe ratio portfoio
    w = max((mu_stocks)*inv(C),0);
    w_max_sharpe{i} = w/sum(w);
    return_max_sharpe{i} = (mu_stocks*w_max_sharpe{i}.');
    std_max_sharpe{i} = sqrt(w_max_sharpe{i}*C*w_max_sharpe{i}.');
    %% Minimum probability of loss (less than 1) portfoio
    w = max((mu_stocks-1)*inv(C),0);
    w_mim_loss{i} = w/sum(w);
    return_mim_loss{i} = (mu_stocks*w_mim_loss{i}.');
    std_mim_loss{i} = sqrt(w_mim_loss{i}*C*w_mim_loss{i}.');
    %%
    
end

w_mat = zeros(N_division,Nstocks);
for ii=1:N_division
    w_mat(ii,:) = w_mim_loss{ii};
end

figure;hist(mu_stocks1(:,8))
