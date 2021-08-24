% -------------------------------------------------------------------------------------------
% This program calls two generic acquisition engines (on user choice):
%       1-  signal_acquisition_FFT.m that performs an FFT signal acquisition;
% -------------------------------------------------------------------------------------------
close all;
fclose all;
global f_sampling; f_sampling = 16.3676e6; % Tan so lay mau [Hz]
global fif; fif = 4.1304e6; % Tan so song mang con lai sau khi h? tan so [Hz]
global code_rate; code_rate = 1.023e6; % Tan so cua ma trai pho
global CodeLen; CodeLen = 1023; % Do dai ma trai pho
PRN_vect = [24]; % Mang chua so hieu ve tinh 
PRN_inview = []; % Mang luu so hieu ve tinh co tren bau troi (sau do` tin hieu)
for ik = 1:length(PRN_vect) % Lap qua tat ca cac ve tinh
    str = 'sat_signal.bin';
    fid=fopen(str,'rb');
    if (fid == -1)
        disp('Could not open the required data file, exiting...')
        return
    end
    PRN = PRN_vect(ik);
    %% FFT signal acquisition: Do` tin hieu thong qua tinh tuong quan bang FFT
   %% [doppler_est, code_phase, status] = signal_acquisition_FFT(fid,PRN);
    [doppler_est, code_phase, status] = LMT_signal_acquisition_serial(fid,PRN);
    if (status == 0)
        fprintf('PRN %i has not been found\n',PRN)
    else
        PRN_inview = [PRN_inview PRN];
        disp('------------------------------------------------------');
        fprintf('PRN %i has been found \n',PRN);
        fprintf('Code Phase [samples]: %d \n',code_phase);
        fprintf('Mixing Frequency [Hz]: %d \n',doppler_est);
        fprintf('Doppler [Hz]: %d \n',doppler_est-fif);
        disp('------------------------------------------------------');
    end
end