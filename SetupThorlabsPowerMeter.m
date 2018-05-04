function msg = SetupThorlabsPowerMeter
% This function setup Thorlabs Power Meter
% as defined in SetupD

%% import handles and data
global TP

%% Power Meter PM100USB, through NI VISA interface
for i =1:1%size(TP.D.Sys.Power.Meter.ID,1)
    TP.HW.Thorlabs.PM100{i}.name = TP.D.Sys.Power.Meter.ID{i,1};
    TP.HW.Thorlabs.PM100{i}.h = visa('ni', TP.D.Sys.Power.Meter.ID{i,2});
    fopen(TP.HW.Thorlabs.PM100{i}.h);    
    fprintf(TP.HW.Thorlabs.PM100{i}.h,'*RST');	% Reset the device
    fprintf(TP.HW.Thorlabs.PM100{i}.h,'*IDN?');	% Thorlabs,PM100USB,P2004081,1.4.0
    temp = TP.HW.Thorlabs.PM100{i}.h.fscanf;
    if strcmp(temp(1:14),'Thorlabs,PM100')
        % The power meter is correctly connected
        fprintf(TP.HW.Thorlabs.PM100{i}.h,'SYST:SENS:IDN?');         
                                                % S140C,11040529,05-Apr-2011,1,18,289
                                                % S121C,14081201,12-Aug-2014,1,18,289
                                                % S310C,130801,29-JUL-2013,2,18,289
                                                % S170C,701207,17-Dec-2014,1,2,33
        TP.D.Sys.Power.Meter.Sensor = strtok(TP.HW.Thorlabs.PM100{i}.h.fscanf,',');
    end;    
    fprintf(TP.HW.Thorlabs.PM100{i}.h,'SENS:POW:RANG:AUTO 1');
    fprintf(TP.HW.Thorlabs.PM100{i}.h,'SENS:CORR:WAV 920');     
    fprintf(TP.HW.Thorlabs.PM100{i}.h,'SENS:CORR:WAV?'); 
                                                % 9.200000E+02          % in nm
    if strcmp(TP.HW.Thorlabs.PM100{i}.h.fscanf, '9.200000E+02')
        errordlg('The Wavelength Setup is not 920nm');        
    end;
    
    % Send request 1st to save following read time
    if i ==1
        fprintf(TP.HW.Thorlabs.PM100{1}.h,  'MEAS:POW?'); 
        TP.D.Mon.Power.QueryFlag = 1;
    end;
end;

    %     fprintf(PM100USB,'CAL:STR?')            % "Calibrated: 20-Nov-2014" 
    %     fprintf(PM100USB,'SENS:CORR:LOSS?')     % 0.000000E+00          % in dB 
    %     fprintf(PM100USB,'SENS:CORR:BEAM?')     % 5.00000000E+00        % in mm
    %     fprintf(PM100USB,'SENS:CORR:WAV?')      % 6.350000E+02          % in nm
    %     fprintf(PM100USB,'SENS:CORR:WAV 920')
    %     fprintf(PM100USB,'SENS:CORR:WAV?')      % 9.200000E+02          % in nm
    %     fprintf(PM100USB,'SENS:CORR:POW:THER:RESP?')    % 1.28903072E-02    % V/W
    %     fprintf(PM100USB,'SENS:CORR:ENER:PYRO:RESP?')   % 1.28903072E-02    % V/W
    %     fprintf(PM100USB,'SENS:POW:RANG:AUTO?')         % 1
    %     fprintf(PM100USB,'SENS:POW:UNIT?')              % W
    %     fprintf(PM100USB,'MEAS:POW?')                   % read of power

%% LOG MSG
msg = [datestr(now) '\tSetupNIDAQ\tNI-DAQmx tasks initialized\r\n'];

