clc;
clear all;
close all;

BERLop = [];
times = 10;
mpsk=[];

for i=1:3
    %bps
    M=2^i;
    bps=log2(M);
    
    BERLoop=[];
    for j=0:times
       %% input +reshape
        nosymbol = 1000;
        symbols = randint(1,nosymbol,256);
        symbolToBitMapping = de2bi(symbols,8,'left-msb');
        totNoBits = numel(symbolToBitMapping);
        inputReshapedBits = reshape(symbolToBitMapping,1,totNoBits);
        %% padding
        remainder = rem(totNoBits,bps);
        if(remainder == 0)
            userPaddedData = inputReshapedBits;
        else
            paddingBits = zeros(1,bps-remainder);
            userPaddedData = [inputReshapedBits  paddingBits];
        end
        %% crc
        n = bps+1;
        k = bps;
        crcEncoded= encode(userPaddedData,n,k,'cyclic/binary');
        state=8321;
        crcEncodedIntrlv=randintrlv(crcEncoded,state);
        %% Modulation
        reshapedUserPaddedData = reshape(crcEncodedIntrlv,numel(crcEncodedIntrlv)/bps,bps);
        bitToSymbolMapping = bi2de(reshapedUserPaddedData,'left-msb');
        modulatedSymbol = pskmod(bitToSymbolMapping,M);
        
        %% Chanel 
        SNR = [];
        BER = [];
        for snr =0:15
            SNR = [SNR snr];
            ts = 1/totNoBits;
            fd = 100;
            chan = rayleighchan(ts,fd);
            absForm = abs(filter(chan,ones(size(modulatedSymbol))));
            fadedSignal = absForm .* modulatedSymbol;
            noisySymbols = awgn(fadedSignal,snr,'measured');
            demodulatedSymbol = pskdemod(noisySymbols,M);
            
            demodulatedSymbolToBitMapping = de2bi(demodulatedSymbol,'left-msb');
            reshapedDemodulatedBits = reshape(demodulatedSymbolToBitMapping,1,numel(demodulatedSymbolToBitMapping));
            
            %% crc
            state=8321;
            crcDeintrlv= randdeintrlv(reshapedDemodulatedBits,state);
            
          n = bps+1;
          k = bps;
          crcDecoded= decode(crcDeintrlv,n,k,'cyclic/binary');
            %% remove padding
            demodulatedBitsWithoutPadding=crcDecoded(1:totNoBits);
            [noe ber]= biterr(inputReshapedBits,demodulatedBitsWithoutPadding);
            BER=[BER ber];
            
            %% Original Text
            %{
            txtBits =
            reshape(demodulatedBitsWithoutPadding,numel(demodulatedBitsWithoutPadding)/8,8);
            txtBitsDecimal = bi2de(tstBits,'left-msb');
            msg = char(txtBitsDecimal)';
            %}
        end
        BERLoop= [BERLoop; BER];
    end

    BERLop= sum(BERLoop)/times;
    mpsk=[mpsk; BERLop];
end
figure(1)
semilogy(SNR,mpsk(1,:),'-o',SNR,mpsk(2,:),'-o',SNR,mpsk(3,:),'-o');
legend('BPSK','QPSK','8PSK')
xlabel('SNR')
ylabel('BER')
title('SNR vs BER')

