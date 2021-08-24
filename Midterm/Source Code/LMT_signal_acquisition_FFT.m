function [doppler, code, st] = LMT_signal_acquisition_FFT(file,prn)
% Khai bao lai cac bien toan cuc da duoc su dung o Mainfile
global f_sampling;
global fif;
global code_rate;
global CodeLen;

% Doc du lieu tu file
seek_sec = 0; % Neu khong muon doc tu dau file
fseek(file,ceil(f_sampling*seek_sec),-1);
NoByte = 2e-3 * f_sampling; % Lay luong data tuong duong 1ms
[gpsdata,scount] = fread(file,NoByte,'schar');
%figure; plot(1:100,gpsdata(1:100));
%figure; hist(gpsdata);

Ts = 1/f_sampling;
num_samples = f_sampling/code_rate;% So mau tren mot chip ma trai pho.
acq_metric = 1.4;
N=floor(f_sampling*CodeLen/code_rate)+1; % So mau trong 1 chu ky ma trai pho
Dopplerstep=250;

% Sinh ma trai pho
Loc = LMT_generateCAcode(prn);
Loc = [Loc Loc(1)];
idx=1;
C=[];

for FD=-5000:Dopplerstep:5000;
    corr=zeros(1,N)+j*zeros(1,N);
    % Sinh tin hieu cuc bo tai bo thu
    k=0:N-1;
    SigLOC=Loc(floor(k*code_rate/f_sampling)+1); %ma trai pho sau khi duoc lay ma, lay mau ma trai pho theo tan o lay mau
    SigLOCFFT=conj(fft(SigLOC,N));
    argx=2*pi*(fif+FD)*Ts;
    carrI=cos(argx*k);
    carrQ=sin(argx*k);
    
    SigIN=gpsdata(1:N)';
    % Giai dieu che
    I=SigIN.*carrI;
    Q=SigIN.*carrQ;
    SigINIQ=I+j*Q;
    % Tinh tuong quan
    corr=corr+abs(ifft(fft(SigINIQ,N).*(SigLOCFFT)));
    C(idx,:)=corr;
    idx=idx+1;
end
figure, surf(C), shading interp;

% --- Tim dinh cao nhat va so sanh voi nguong de quyet dinh xem ve tinh co
% hay khong?
% frequency bin index
[bb ind_mixf] = max(max(C'));
[bb ind_mixc] = max(max(C));

if (ind_mixc < ceil(num_samples))
    vect_search_peak2 = [zeros(1,2*ceil(num_samples)), C(ind_mixf,(2*ceil(num_samples)):end)];
elseif (ind_mixc < ceil(num_samples))
    vect_search_peak2 = [C(ind_mixf,1:(end-2*ceil(num_samples)):end), zeros(1,2*ceil(num_samples))];
else
    vect_search_peak2 = [C(ind_mixf,1:(ind_mixc-ceil(num_samples))),zeros(1,2*ceil(num_samples)-1),C(ind_mixf,(ind_mixc+ceil(num_samples)):end)];
end

% --- Tim dinh cao thu hai
second_peak = max(vect_search_peak2);

% --- Xac dinh xem co ve tinh hay khong

if ((bb/second_peak) > acq_metric)
    fprintf('...acquired satellite\n ')
    code = ceil(f_sampling*seek_sec)+((ind_mixc-1));
    doppler = (fif-8e3) + (ind_mixf-1)*Dopplerstep;
    st = 1;
else
    fprintf('...no satellite ')
    code = 0;
    doppler = 0;
    st = 0;
end
%     mat_file = ['../Data_files/GPS_Acq_PRN',num2str(prn)]; save
%     (mat_file);
