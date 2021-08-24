prn1 = generateCAcode(1);
prn2 = generateCAcode(2);
corr_value = xcorr(prn1,prn1);
figure;
plot(corr_value);