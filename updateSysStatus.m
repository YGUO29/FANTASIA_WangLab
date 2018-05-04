function updateSysStatus(~,evnt)
% This function updates System Status from DI, AI monitor tasks of NI
% Terminal Definition is in SetupD
% Terminal comments here are updated @4/18/2013, just for reference.

% ~7.6ms for T5810, E5-1630v3, 64GB, 1TB 850ProSSD, 3.6 - 12.4 ms observed

global TP
persistent PmeasuredS121C
persistent sysAIstatus
persistent sysAIstatusd
persistent sysAmp
persistent sysNoise
persistent PMTstatus
persistent C

%% Read PowerMeter Data
    if ~TP.D.Mon.Power.CalibFlag
        try
        PmeasuredS121C = ...
        round(1e7*str2double(TP.HW.Thorlabs.PM100{1}.h.fscanf))/1e4;  
                                                                % xx.xxxx mW
        catch
        end;
    end;
    
%% Read AI_6323 Data
    if ~isempty(evnt.data)
        % if the system is too busy to respond, size(evnt.date) = [0 0] 
        sysAIstatus = evnt.data;
    end;
        % sysAIstatusd = double(sysAIstatus(:,1:3))/32678*10;
    sysAIstatusd =  double(sysAIstatus(:,1:3)) * 3.289e-4 - 0.02367;
        % Dev3/AI: [PMT#1 Gain Mont, AOD X Amp Mont, AOD Y Amp Mont]
        % Calibrated by AI_6115 @2013/07/21  
    sysAmp =        round(mean(sysAIstatusd)*100)/100;
        % in x.xx Volts precision 
    sysNoise =      round(std(sysAIstatusd)*1000);
        % in xx mV precision

%% Read DI_6115 Data
    PMTstatus = logical(TP.HW.NI.T.hTask_DI_6115.readDigitalData);
        % Dev1/line3:7 [M9012, Status, Error, TooBright, TooHot]
        
%% Load C Data
    try 	if ~isfield(C, 'HWP_pmax'); C = TP.D.Sys.Power.C;   end;
    catch;                              C = TP.D.Sys.Power.C;   end;
    
%% Update PMT Gain and AOD Amp & Noise
    if sysAmp(1) ~= TP.D.Mon.PMT.MontGainValue;             % Update PMT Gain Mont
        set(TP.UI.H.hMon_PMT_MontGainValue_Edit,        'string',	sprintf('%5.2f',sysAmp(1)));
        TP.D.Mon.PMT.MontGainValue =            sysAmp(1);
    end;
    if sysAmp(2) ~= TP.D.Mon.Power.AOD_MontAmpValue(1);     % Update AOD X Amp Mont
        set(TP.UI.H.hMon_Power_AOD_MontAmpValueX_Edit,	'string',   sprintf('%5.2f',sysAmp(2)));
        TP.D.Mon.Power.AOD_MontAmpValue(1) =    sysAmp(2);
    end;
    if sysAmp(3) ~= TP.D.Mon.Power.AOD_MontAmpValue(2)      % Update AOD Y Amp Mont
        set(TP.UI.H.hMon_Power_AOD_MontAmpValueY_Edit,  'string',   sprintf('%5.2f',sysAmp(3)));
        TP.D.Mon.Power.AOD_MontAmpValue(2) =    sysAmp(3);
    end;

    if sysNoise(1) ~= TP.D.Mon.PMT.MontGainNoise;           % Update PMT Gain Mont Noise
        set(TP.UI.H.hMon_PMT_MontGainNoise_Edit,        'string',   sprintf('%d',sysNoise(1)));
        TP.D.Mon.PMT.MontGainNoise =            sysNoise(1);
    end;
    if sysNoise(2) ~= TP.D.Mon.Power.AOD_MontAmpNoise(1);   % Update AOD X Amp Mont Noise
        set(TP.UI.H.hMon_Power_AOD_MontAmpNoiseX_Edit,  'string',   sprintf('%d',sysNoise(2)));
        TP.D.Mon.Power.AOD_MontAmpNoise(1) =    sysNoise(2);
    end;
    if sysNoise(3) ~= TP.D.Mon.Power.AOD_MontAmpNoise(2);   % Update AOD Y Amp Mont Noise
        set(TP.UI.H.hMon_Power_AOD_MontAmpNoiseY_Edit,  'string',   sprintf('%d',sysNoise(3)));
        TP.D.Mon.Power.AOD_MontAmpNoise(2) =    sysNoise(3);
    end;

%% Update PMT status LEDs   
    for i = 1:TP.D.Sys.NI.Chan_DI_PMT_Status{6}
        if xor(PMTstatus(i),TP.D.Mon.PMT.StatusLED(i))
            set(TP.D.Sys.NI.Chan_DI_PMT_Status{7}{i}, 'BackgroundColor',...
            (1-PMTstatus(i))*TP.UI.C.BG + PMTstatus(i)*TP.D.Sys.NI.Chan_DI_PMT_Status{4}(i,:));
        end;
    end;
    TP.D.Mon.PMT.StatusLED = PMTstatus;

%% Update PowerMeter Monitored
    if PmeasuredS121C ~= TP.D.Mon.Power.PmeasuredS121C
        TP.D.Mon.Power.PmeasuredS121C =         PmeasuredS121C;
        TP.D.Mon.Power.PinferredAtCtx = ...
            C.ARM_p1 * TP.D.Mon.Power.PmeasuredS121C + C.ARM_p2;
        
        if (TP.D.Mon.Power.PinferredAtCtx > TP.D.Mon.Power.PmaxCtxAllowed)...
            && ~TP.D.Trl.PowerOverload
            feval(TP.D.Sys.Name,...
                'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  0]);
                    %           PMT Gain Control            0, && StartTrigStop==2
            TP.D.Trl.PowerOverload = 1;  
            set(TP.UI.H.hMon_Power_PinferredAtCtx_Edit, 'ForegroundColor', [0.8 0 0]);
        end;
        set(TP.UI.H.hMon_Power_PmeasuredS121C_Edit, 'string', ...
            sprintf('%5.4f',    TP.D.Mon.Power.PmeasuredS121C) );
        set(TP.UI.H.hMon_Power_PinferredAtCtx_Edit, 'string', ...
            sprintf('%5.4f',    TP.D.Mon.Power.PinferredAtCtx) );
    end;
    
%% Send PowerMeter request
    if ~TP.D.Mon.Power.CalibFlag
        fprintf(TP.HW.Thorlabs.PM100{1}.h,  'MEAS:POW?'); 	% 2-6 ms by itself
    end;
    
    
