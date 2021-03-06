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
% expectation distribution - heavy tail
% Matrix norm

if(0)
    mu_stocks = mean(mu_stocks1);
    % figure;hist(mu_stocks1(:,8),100)
    
    %% check the distribution of the returns and risks of each of the portfolios
    
    %% Minimum variance portfolio
    w = max(ones(1,Nstocks)*inv(C),0);
    data.stock_list
    w_min_risk = w/sum(w)
    return_min_risk = (mu_stocks*w_min_risk.')
    std_min_risk = sqrt(w_min_risk*C*w_min_risk.')
    %% Maximum Sharpe ratio portfoio
    w = max((mu_stocks)*inv(C),0);
    data.stock_list
    w_max_sharpe = w/sum(w)
    return_max_sharpe = (mu_stocks*w_max_sharpe.')
    std_max_sharpe = sqrt(w_max_sharpe*C*w_max_sharpe.')
    %% Minimum probability of loss (less than 1) portfoio
    w = max((mu_stocks-1)*inv(C),0);
    data.stock_list
    w_mim_loss = w/sum(w)
    return_mim_loss = (mu_stocks*w_mim_loss.')
    std_mim_loss = sqrt(w_mim_loss*C*w_mim_loss.')
    
    %% Back-test the portfolio on the real data
    % we can rebalance every T times
    
    % cross validation - learn the optimal protfolio based on one time
    % interval and check on another
    
    % i can perform an optimal portfolio of each time inteval and then
    % check the performance - see how different the weights are? - see the
    % distrubuton of the final return for a specofic weight allocation
    % we can also check on different time allocations - make it random!!!!
    
    % optimal capon robust for the mu
    
    % more stocks
    
    %% Compute the annual return for each portfolio based on Gaussian assumption
    N = 1e6;
    z = zeros(1,N);
    risk = [std_min_risk,std_max_sharpe,std_mim_loss];
    return_monthly = [return_min_risk,return_max_sharpe,return_mim_loss];
    for j=1:3
        mean_std = mean(risk(j));
        mean_return = mean(return_monthly(j));
        parfor i=1:N
            n = mean_std*randn(1,12)+mean_return;
            % todo - add here the management costs
            z(i) = prod(n);
        end
        [a,overlap] = hist(z,100);
        figure;
        a = a/sum(a);
        bar(overlap,a)
        grid on;
        xlabel('Yearly Return');
        ylabel('Probability');
        p0= sum(a(overlap<1));
        title(['risk under zero - ',num2str(p0)]); % name,risk under 1
        
    end
end