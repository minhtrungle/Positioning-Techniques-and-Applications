clc;
clear all;
close all;
prn1 = LMT_generateCAcode(1); %---ma trai pho cua ve tinh 1

L=length(prn1);
prn1 = [prn1(500:L), prn1(1:499)]
tuong_quan=zeros(2,L);
fft_prn1=fft(prn1);

for i=1:2
    fft_prn(i,:)=fft(LMT_generateCAcode(i));
    tuong_quan(i,:)= ifft(fft_prn1.*conj(fft_prn(i,:)));
    figure;
    plot(tuong_quan(i,:));
end 




 