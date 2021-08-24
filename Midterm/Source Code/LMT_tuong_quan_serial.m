clc;
clear all;
close all;
prn1 = LMT_generateCAcode(1); %---ma trai pho cua ve tinh 1
L=length(prn1);
prn1 = [prn1(500:L), prn1(1:499)];

for i=1:2
    tuong_quan=[];
    prni = LMT_generateCAcode(i); %---ma trai pho cua ve tinh ve tinh i
    prn_double=[ prni, prni];
    for m=1:1023
    s=0;
    for n=1:1023
        s = s + prn1(n) * prn_double(n+m);
    end
    tuong_quan=[tuong_quan,s/L];
    end
 figure;
    plot(tuong_quan);
end
