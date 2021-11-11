clc;
close all;
clear all;

text='INFORMATION';
symbol=double(text);
bin=de2bi(symbol,8);
totalBit=numel(bin);
reshapedInput=reshape(bin,1,[]);
m=8;
bps=log2(m);
remainder=rem(totalBit,bps);
if(remainder==0)
    paddedinput=reshapedInput;
else
    paddedinput=[reshapedInput,zeros(1,(bps-remainder))];
end
reshapeAgain=reshape(paddedinput,[],bps);
symbolagain=bi2de(reshapeAgain);
modulation=pskmod(symbolagain,m);
fd=5;
fs=1/numel(paddedinput);
k=4;
chan=ricianchan(fs,fd,k);
absform=abs(filter(chan,ones(size(modulation))));
faddsignal=absform.*modulation;
SNR = [];
BER = [];
for(snr = -30 : 50)
    ch_out = awgn(faddsignal, snr);
    demod = pskdemod(ch_out, 8);
    bin2 = de2bi(demod);
    reshape3 = reshape(bin2, 1, []);
    recover= reshape3(1 : totalBit);
    reshape4 = reshape(recover, [], 8);
    symbolAgain = bi2de(reshape4);
    information2 = char(symbolAgain');
    [noe, ber] = biterr(recover,reshapedInput);
    SNR = [SNR snr];
    BER = [BER ber];
end
semilogy(SNR,BER)