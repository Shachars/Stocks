% test to see how a stock performs over time
close all;
clear all;
clc;

% portfolio is going to be 35% bonds and 65% stocks
% compute the mean and std over time 
% put and call

% build a protfolio which has high mean and low std...check correlations

% don't forget to use the gpu!

save_data_name = 'stocks_data7';

% list of stocks (todo - automatic?)
% stock_list = {'^TA100'};
% stock_list = {'^GSPC','^RUT','^STOXX50E','^N225','^GDAXI'};
% stock_list = {'^TA25','^TA75','MSCI','^GSPC','^RUT','^STOXX50E','^N225','^IXIC','^GDAXI','^FTSE','^DJI','^HSI'};
stock_list = {'^TA25','^TA75','MSCI','^GSPC','^RUT','^STOXX50E','^N225','^GDAXI','^FTSE','^DJI','^HSI'};
% stock_list = {'^TA25','^GSPC','^RUT','^GDAXI','^IXIC'};
% stock_list = {'^TA75','GSPC'};
Nstocks = length(stock_list);
% stock_list = {'FXT'};
nStocks = length(stock_list);
stock_return = {};

% create the connection to yahoo
c = yahoo;

% time frame
years = 40;
start = now - (365.25*years);

for iStock=1:nStocks
    iStock
    stock_data{iStock} = fetch(c,stock_list{iStock},'Close',start,now,'m');
    %% plot the data
    aa = datevec(stock_data{iStock}(:,1));
    stock_return{iStock} = stock_data{iStock}(1:end-1,2)./stock_data{iStock}(2:end,2);
%     figure;plot(aa(:,1)+aa(:,2)/12,stock_data{iStock}(:,2));
%     title(stock_list{iStock})
%      grid on;
%     xlabel('Time [Year]')
%     ylabel('Monthly Close Price');
%     figure;plot(aa(1:end-1,1)+aa(1:end-1,2)/12,stock_return{iStock});
%     title(['Return Mean: ',num2str(mean(stock_return{iStock})),' std: ',num2str(std(stock_return{iStock}))]);
%         grid on;
%         % todo - present yearly returns too
%     xlabel('Time [Year]')
%     ylabel('Monthly Return');
    
    %     stock_data(iStock) = builduniverse(c,stock_list{iStock},fromtime,todate);
end

close(c)

save(save_data_name);


