function [doppler, code, st] = signal_acquisition_serial(file,prn)
global f_sampling;
global nominalfreq;
global code_rate;
global CodeLen;

% Doc du lieu tu file
seek_sec = 0;
fseek(file,ceil(f_sampling*seek_sec),-1);
[gpsdata,scount] = fread(file,40000*6,'schar');


Ts = 1/f_sampling;
num_samples = f_sampling/code_rate;% So mau tren mot chip ma trai pho.
acq_metric = 1.4;
fif=rem(nominalfreq,f_sampling);
N=floor(f_sampling*CodeLen/code_rate)+1;
Dopplerstep=250;

% Sinh ma trai pho
Loc = generateCAcode(prn);
Loc = [Loc Loc(1)];  
C=[];
% Sinh tin hieu cuc bo tai bo thu
k=0:N-1;
Loc_Samples=Loc(floor(k*code_rate/f_sampling)+1);
FD=-5000:Dopplerstep:5000;
for FD_index = 1:length(FD)
    argx=2*pi*(fif+FD(FD_index))/f_sampling;
    carrI=cos(argx*k);
    carrQ=sin(argx*k);
    SigIN=gpsdata(1:2*N)';
    tau=0:1:(N-1);
    for tau_index = 1:length(tau)
        SigIN_forCorr = SigIN((1+tau(tau_index)):(N+tau(tau_index)));
        I=SigIN_forCorr.*carrI;
        Q=SigIN_forCorr.*carrQ;
        % Tinh tuong quan
        corrI = 0; corrQ = 0;
        for index = 1:N
            corrI = corrI + I(index)*Loc_Samples(index);
            corrQ = corrQ + Q(index)*Loc_Samples(index);
        end
        corr = corrI^2 + corrQ^2;
        C(FD_index,tau_index)=corr;
    end
   end
   figure, surf(C), shading interp;
%     % --- Tim dinh cao nhat
%     % frequency bin index
    [bb ind_mixf] = max(max(C'));
    [bb ind_mixc] = max(max(C));
% 
    if (ind_mixc < ceil(num_samples)),
         vect_search_peak2 = [zeros(1,2*ceil(num_samples)), C(ind_mixf,(2*ceil(num_samples)):end)];
    elseif (ind_mixc < ceil(num_samples))
         vect_search_peak2 = [C(ind_mixf,1:(end-2*ceil(num_samples)):end), zeros(1,2*ceil(num_samples))];
    else
         vect_search_peak2 = [C(ind_mixf,1:(ind_mixc-ceil(num_samples))),zeros(1,2*ceil(num_samples)-1),C(ind_mixf,(ind_mixc+ceil(num_samples)):end)];
    end
% 
%     % --- Tim dinh cao thu hai
     second_peak = max(vect_search_peak2);
% 
%     % --- Xac dinh xem co ve tinh hay khong
% 
     if ((bb/second_peak) > acq_metric)
         fprintf('...acquired satellite\n ')
         code = ceil(f_sampling*seek_sec)+((ind_mixc-1));
         doppler = (nominalfreq-8e3) + (ind_mixf-1)*Dopplerstep;
         st = 1;
     else
         fprintf('...no satellite ')
        code = 0;
         doppler = 0;
         st = 0;
   end
% %     mat_file = ['../Data_files/GPS_Acq_PRN',num2str(prn)]; save
% %     (mat_file);
