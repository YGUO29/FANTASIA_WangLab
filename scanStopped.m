function scanStopped
% This function is called by
%   (1) scanStopping if
%           GUI "Stop" button or GUI_ScanStartTrigStop('Stop')
%           External trigger falling edge
%   (2) updateScanKeeper if timeout
% and is the only function that controls the trial stopped procedure
% takes ? s on T5810 @ 2015/1

%% State
global 	TP
global  Trl
persistent StartTrigStopT

%% Time & Flag, for Stopped
    StartTrigStopT =                TP.D.Trl.StartTrigStop;        
    TP.D.Trl.StartTrigStop =        0;
    %   -3 = Timeout,       -2 = Stopping by GUI,   -1=Stopping by ExtTrig, 
    %   0 = Stopped,        1 = Started,            2 = Triggered  
    TP.D.Trl.TimeStampStopped =     datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF');  

%% Switch AOD & PMT accordingly
    feval(TP.D.Sys.Name,...
  	'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  TP.D.Mon.Power.AOD_CtrlAmpValue]);
        %           PMT Gain Control            AOD Amp, && StartTrigStop==2
    feval(TP.D.Sys.Name,...        
	'GUI_DO_6115',[ 0;                      0;                      0]);
    	%       	PMTon,                  FANoff,                 PELoff
    
%% Setup NIDAQ
    TP.HW.NI.T.hTask_DO_6536.stop();                    % Scanning
    TP.HW.NI.T.hTask_AI_6115.stop();                    % Imaging
    TP.HW.NI.T.hTask_CO_TrigListener.abort();        	% Trigger Listener
	switch TP.D.Trl.ScanScheme
        case 'FOCUS'
            TP.HW.NI.T.hTask_CO_IntTrig.stop();         % Internal Trigger 
        case 'GRAB'
            TP.HW.NI.T.hTask_CO_IntTrig.stop();         % Internal Trigger  
            TP.HW.NI.T.hTask_AO_6323.abort();         	% Sound Playback   
            TP.HW.NI.T.hTask_AO_6323.delete();            
            h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
            set(h(2),       'enable',           'inactive');
        case 'LOOP'
         	TP.HW.NI.T.hTask_CO_StopListener.abort();   % Stop Listerner
        otherwise
	end;  

%% TP.D Save
    if TP.D.Trl.DataLogging
        % Stream File Closed
        fclose(TP.D.Trl.StreamFid);
        % Save TP.D.Trl, CUT TP.D.Trl.VS. to the finished length?
            %% 
            %%
            %%
            %%
        Trl = TP.D.Trl;
        save([TP.D.Sys.PC.Data_Dir, datestr(TP.D.Trl.TimeStampStarted,30),'.mat'],...
            '-struct','Trl');
    end;   

%% MSG LOG 
    msg = [datestr(now) '\tscanStopped\tScanning Stopped w/ # of Volumes Scanned = ',...
        num2str(TP.D.Trl.Vdone),'\r\n'];
 	fprintf( TP.D.Sys.PC.hLog,   msg); 
  
%% GUI StartTrigStop Coloring
	h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
    set(h(1),   'backgroundcolor', TP.UI.C.SelectB);
    set(h(2),   'backgroundcolor', TP.UI.C.TextBG);
	set(h(3),   'backgroundcolor', TP.UI.C.TextBG);
    
%% Loop Control
    if strcmp(TP.D.Trl.ScanScheme, 'LOOP') && StartTrigStopT==-1
        % LOOP and not final stopped
        feval(TP.D.Sys.Name, 'GUI_ScanStartTrigStop', 'Start');
    end
    