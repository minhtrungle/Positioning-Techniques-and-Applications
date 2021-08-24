clc;
clear all;
close all;
prn1_serial=generateCAcode(1);
Leng = length(prn1_serial);
prn1_serial=[prn1_serial(500:Leng),prn1_serial(1:499)];

for i=1:30
    gttq=[];
    p(i,:)=generateCAcode(i);
    prn2_double =[p(i,:),p(i,:)];
    for m=0:Leng-1
        temp=0;
        for n=1:Leng
            temp=temp+prn1_serial(n) * prn2_double(n+m);
        end
        gttq=[gttq,temp];
    end
    figure;
    plot(gttq);
end
