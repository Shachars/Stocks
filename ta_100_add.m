a = zeros(size(Data20151016ta100,1),2);


for i=1:size(Data20151016ta100,1)
    a(i,1) = datenum(Data20151016ta100{i,1});
    a(i,2) = Data20151016ta100{i,2};
end
stock_data{13} = a;
stock_return{13} = stock_data{12}(1:end-1,2)./stock_data{12}(2:end,2);
Nstocks = 13;
stock_list{13} = 'TA100';
save('stocks_data11_with_ta100');
