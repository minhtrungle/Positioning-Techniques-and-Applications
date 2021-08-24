% -------------------------------------------------------------------------------------------
% This program calls two generic acquisition engines (on user choice):
%       1-  signal_acquisition_FFT.m that performs an FFT signal acquisition;
% -------------------------------------------------------------------------------------------
%close all;
fclose all;
global f_sampling; f_sampling = 16.3676e6; % sampling frequency [Hz]
global nominalfreq; nominalfreq = 4.1304e6; % IF frequency [Hz]
global code_rate; code_rate = 1.023e6;
global CodeLen; CodeLen = 1023;
PRN_vect = [24];
PRN_inview = []; % to store PRN in view
for ik = 1:length(PRN_vect)
    str = 'sat_signal.bin';
    fid=fopen(str,'rb');
    if (fid == -1)
        disp('Could not open the required data file, exiting...')
        return
    end
    PRN = PRN_vect(ik);
    %% FFT signal acquisition
    [doppler_est, code_phase, status] = signal_acquisition_serial(fid,PRN);
    if (status == 0)
        fprintf('PRN %i has not been found\n',PRN)
    else
        PRN_inview = [PRN_inview PRN];
        disp('------------------------------------------------------');
        fprintf('PRN %i has been found \n',PRN);
        fprintf('Code Phase [samples]: %d \n',code_phase);
        fprintf('Mixing Frequency [Hz]: %d \n',doppler_est);
        fprintf('Doppler [Hz]: %d \n',doppler_est-nominalfreq);
        disp('------------------------------------------------------');
    end
end
