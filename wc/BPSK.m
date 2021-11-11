clc;
clear all;
close all;
data = randint(1,1000);
pdata = 2 * data - 1;
fc = 1000;
fs = 10 * fc;
tc = 1 / fc;
ts = 1 / fs;
m = 2;
n = m * length(data);
t = 0 : ts : n * tc;
car = sin(2 * pi * fc * t);
tp = 0 : ts : m * tc;
exdata = [];
% subplot(2, 4, 1)
% stem(data)
% title('Data signal')
% subplot(2, 4, 2)
% plot(car)
% title('Carrier signal')

for i = 1 : length(data)
    for j = 1 : length(tp) - 1
        exdata = [exdata pdata(i)];
    end
end
exdata = [exdata zeros(1, (length(car) - length(exdata)))];
% subplot(2, 4, 3)
% plot(exdata)
% title('Extended data signal')
SNR= [];
BER = [];

mod = car .* exdata;
% subplot(2, 4, 4)
% plot(mod)
% title('Modulated signal')
for(snr = -30  : 50)
    ch_out = awgn(mod, snr);
    % subplot(2, 4, 5)
    % plot(ch_out)
    % title('Channel output signal')
    
    demod = ch_out .* car;
    % subplot(2, 4, 6)
    % plot(demod)
    % title('Demodulated signal')
    arr = [];
    recover = [];
    start = 1;
    finish = length(tp) - 1;
    for i = 1 : length(data)
        add = sum(demod(start : finish));
        if add > 0
            for k = 1 : length(tp) - 1
                arr = [arr 1];
            end
            recover = [recover 1];
        else
            for a = 1 : length(tp) - 1
                arr = [arr -1];
            end
            recover = [recover 0];
        end
        start = start + length(tp) - 1;
        finish = finish + length(tp) - 1;
    end
    arr = [arr zeros(1, (length(car) - length(arr)))];
    
    % subplot(2, 4, 7)
    % plot(arr)
    % title('Recovered extended data signal')
    % subplot(2, 4, 8)
    % stem(recover)
    % title('Recovered data signal')
    
    [noe, ber] = biterr(recover, data);
    SNR = [SNR snr];
    BER = [BER ber];
end

semilogy(SNR, BER)
    
