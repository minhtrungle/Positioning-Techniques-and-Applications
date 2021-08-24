% Acquisizione FFT in Time domain

function [doppler, code, st] = signal_acquisition_FFT(file,prn)
global f_sampling;
global nominalfreq;
global isNewRun;
if (isNewRun==1)

    acq_metric = 1.4;

    seek_sec = 0;

    fseek(file,ceil(f_sampling*seek_sec),-1);
    [gpsdata,scount] = fread(file,40000*6,'schar'); %...solitamente leggere schar, da NordNav
    %gpsdata = gpsdata-128;  % ATT! minus 127 required when the data set has been acquired with the NavSAS front end

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %                        BLANKING
    % index = find(abs(gpsdata)>2);
    % gpsdata(index)=0;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Ts = 1/f_sampling;
    code_rate = 1.023*1e6;              % Nominal GPS C/A code rate.
    num_samples = f_sampling/code_rate;         % Number of samples per chip.


    K=1; % Downsampling

    Fs=f_sampling/K;
    Rc=1.023e6;
    CodeLen=1023;
    fif=rem(nominalfreq,Fs/K);

    gpsdata=gpsdata(1:K:end);

    N=floor(Fs*CodeLen/Rc)+1;
    Dopplerstep=250;

    C=[];

    S=prn;

    % Genero il codice Locale
    %Loc=CAGen(S);
    Loc = generateCAcode(S);

    Loc = [Loc Loc(1)];  % extend the local code of 1 chip. The floor operation used with high sampling freq lead to sampling the local code at chip 1024.

    idx=1;

    for FD=-8000:Dopplerstep:8000;

        corr=zeros(1,N)+j*zeros(1,N);

        % Ricampiono

        k=0:N-1;
        SigLOC=Loc(floor(k*Rc/Fs)+1);

        % FFT codice locale e complesso coniugato

        SigLOCFFT=conj(fft(SigLOC,N));

        argx=2*pi*(fif+FD)/Fs;
        carrI=cos(argx*k);
        carrQ=sin(argx*k);

        for M=0:0


            SigIN=gpsdata(N*M+1:N*M+N)';

            % Demodulo

            I=SigIN.*carrI;
            Q=SigIN.*carrQ;

            SigINIQ=I+j*Q;

            corr=corr+abs(ifft(fft(SigINIQ,N).*(SigLOCFFT)));

        end

        C(idx,:)=corr;
        idx=idx+1;

    end

   figure, surf(C), shading interp;

    % --- Find the main peak in the correlation floor and the corresponding frequency bin index
    [bb ind_mixf] = max(max(C'));
    [bb ind_mixc] = max(max(C));

    if (ind_mixc < ceil(num_samples/K)),
        vect_search_peak2 = [zeros(1,2*ceil(num_samples/K)), C(ind_mixf,(2*ceil(num_samples/K)):end)];
    elseif (ind_mixc < ceil(num_samples/K))
        vect_search_peak2 = [C(ind_mixf,1:(end-2*ceil(num_samples/K)):end), zeros(1,2*ceil(num_samples/K))];
    else
        vect_search_peak2 = [C(ind_mixf,1:(ind_mixc-ceil(num_samples/K))),zeros(1,2*ceil(num_samples/K)-1),C(ind_mixf,(ind_mixc+ceil(num_samples/K)):end)];
    end


    % --- Find the second highest peak in the correlation floor
    second_peak = max(vect_search_peak2);


    % --- compare the acquisition metric to a predefined threshold

    if ((bb/second_peak) > acq_metric)
        fprintf('...acquired satellite\n ')
        code = ceil(f_sampling*seek_sec)+((ind_mixc-1)*K);% - 20;
        % 20 is a sistematic error, which simulates the number of offset samples, which makes the acquisition estimation not correct, since it took time (not negligible).
        % The effect on the carrier frequency can be neglected, no problems for that!

        doppler = (nominalfreq-8e3) + (ind_mixf-1)*Dopplerstep;

        st = 1;
    else
        fprintf('...no satellite ')
        code = 0;
        doppler = 0;
        st = 0;
    end
    mat_file = ['../Data_files/GPS_Acq_PRN',num2str(prn)];
    save (mat_file);
else
    mat_file = ['../Data_files/GPS_Acq_PRN',num2str(prn)];
    load(mat_file);
end
