clc;
clear all;
close all;
prn1 = generateCAcode(1);
Leng = length(prn1);
prn1_FFT = fft(prn1, Leng);
for i = 1:30
  prn = generateCAcode(i);
  result = zeros(1, Leng);
  prn_FFT = fft(prn, Leng);
  result = ifft(prn1_FFT.*conj(prn_FFT));
  figure;
  plot(1:Leng, result, '-b');
end



