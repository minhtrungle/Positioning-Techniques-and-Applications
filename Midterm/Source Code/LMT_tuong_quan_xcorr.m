clc;
clear all;
close all;
prn1 = LMT_generateCAcode(1); %---ma trai pho cua ve tinh 1
L=length(prn1);

for i=1:2
    tuong_quan=[];

    prn_i=LMT_generateCAcode(i);
    tuong_quan= xcorr(prn1,prn_i);
    figure;
    plot(tuong_quan);
end 




 