% -------------------------------------------------------------------------------------------
% This program calls two generic acquisition engines (on user choice):
%       1-  signal_acquisition_FFT.m that performs an FFT signal acquisition;
%       2-  signal_acquisition_SERIAL.m that performs a serial search.

% -------------------------------------------------------------------------------------------
close all;fclose all;
global isNewRun;
isNewRun = 1; % flag to set whether a function needs to rerun or not (old results in MAT files are used instead)
global f_sampling; f_sampling = 16.3676e6; % sampling frequency [Hz]
global nominalfreq; nominalfreq = 4.1304e6; % IF frequency [Hz]
% global f_sampling; f_sampling = 12e6; % sampling frequency [Hz]
% global nominalfreq; nominalfreq = 3.563e6; % IF frequency [Hz]
global samplesPDI; samplesPDI = ceil(f_sampling*4e-3); % 4 ms for GALILEO

global CNo_WINDOW; % [ms] window for C/No estimation
CNo_WINDOW =  1000; % [ms] 100 ms window
global FIFO_IP; FIFO_IP = zeros(1,CNo_WINDOW/4);
global FIFO_QP; FIFO_QP = zeros(1,CNo_WINDOW/4);
global Freq_sum; Freq_sum = 0;
global Old_Freq_sum; Old_Freq_sum = 0;




 %PRN_vect = [9,15,12,17,22,27,25,30];
PRN_vect = [1:30];

PRN_inview = []; % to store PRN in view
for ik = 1:length(PRN_vect)
     %str = '..\Data_files\Tung_test_2_1_E1_STATIC_GATE_1a.bin';
     str = '.\test2.bin';
%     str = 'H:\E1-L1_amplitude_dutycycle\SIGE_20101008_103848_raw.grab';

    fid=fopen(str,'rb');
%     test_raw_samples(fid,f_sampling);
    if (fid == -1)
        disp('Could not open the required data file, exiting...')
        return
    end
    PRN = PRN_vect(ik);
    %% FFT signal acquisition
    [doppler_est, code_phase, status] = signal_acquisition_FFT(fid,PRN);
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

        %% FLL Tracking Phase
        fprintf('Start the tracking phase with the FLL \n');
        fll_time = 40e3; % [ms]
        [StatusFLL,cnt_skp,doppler_estFLL,code_phaseFLL] = trackcarrFLL_DLL(fid,PRN,code_phase,doppler_est,fll_time,2);
        fprintf('Doppler [Hz]: %d \n',doppler_estFLL-nominalfreq);
        if (StatusFLL == 1)
            disp('FLL is locked, switch to a PLL structure...')
            disp('------------------------------------------------------');

            %% PLL Tracking Phase
            fprintf('Start the tracking phase with the PLL \n');
            track_time = 5e3; % [ms]
            close all
            trackcarrPLL_DLL(fid,PRN,cnt_skp,code_phaseFLL,doppler_estFLL,track_time,1);
        else
            disp('FLL not locked, passed timeout, back to the acquisition...')
        end
    end
end
% Save data in channel structure for data modulation (GPS_channels.mat in Data_files)
data_saving_for_demodulation(PRN_inview);
