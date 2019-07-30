function num = PD_fun(data)
    stopind = regexp(data,'/','start');
    num = data(1:stopind-1);
    num = hex2dec(num);
end