clc;
clear all;
close all;

data = [0 0 0 1 1 0 1 1];
subplot(2, 2, 1)
stem(data)
title('Data signal')
pdata = 2 * data - 1;
fc = 1000;
fs = 10 * fc;
ts = 1 / fs;
tc = 1 / fc;
odd = [];
even = [];
exdataOdd = [];
exdataEven = [];
m = 2;
n = m * length(data);
t = 0 : ts : (tc * n - ts) / 2;
tp = 0 : ts : m * tc - ts;
car1 = sin(2 * pi * fc * t);
car2 = cos(2 * pi * fc * t);

for(i = 1 : length(data))
    if(rem(i , 2) == 0)
        odd = [odd pdata(i)];
    else
        even = [even pdata(i)];
    end
end
for (i = 1 : length(odd))
    for(j = 1 : length(tp))
        exdataOdd = [exdataOdd odd(i)];
    end
end
for(i = 1 : length(even))
    for(j = 1 : length(tp))
        exdataEven = [exdataEven even(i)];
    end
end

mod1 = exdataOdd .* car1;
mod2 = exdataEven .* car2;
mod = mod1 + mod2;
subplot(2, 2, 2)
plot(mod)
title('QPSK modulated signal')

snr = 20;
ch_out = awgn(mod, snr);
subplot(2, 2 , 3);
plot(ch_out)
title('Channel output signal')
out1 = [];
out2 = [];
demod1 = ch_out .* car1;
demod2 = ch_out .* car2;
start = 1 ;
finish = length(tp);
for(i = 1 : length(odd))
    if(sum(demod1(start : finish)) > 0)
        out1 = [out1 1];
    else
        out1 = [out1 0];
    end 
    start = start + length(tp);
    finish = finish + length(tp);
end

start = 1 ;
finish = length(tp);
for(i = 1 : length(even))
    if(sum(demod2(start : finish)) > 0)
        out2 = [out2 1];
    else
        out2 = [out2 0];
    end 
    start = start + length(tp);
    finish = finish + length(tp);
end
out = [];
for(i = 1 : length(data))
    if(rem(i , 2) == 0)
        out(i) = out1(i / 2);
    else
        out(i) = out2(floor(i / 2)+ 1);
    end
end

subplot(2, 2, 4)
stem(out)
title('Recovered signal')
        

        
