function msg = scanStopping(~,~)
% This function is called by
%   (1) GUI "Stop" button or GUI_ScanStartTrigStop('Stop')
%   (3) External trigger falling edge
% however, stopping function can also be mediated through updateScanKeeper
% timeout
% takes ? s on T5810 @ 2015/1

%% State 
global TP

%% Time & Flag, for Stopping
    TP.D.Trl.TimeStampStopping =	datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF');
    
	str = get(get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'SelectedObject'), 'String');
    if strcmp(str, 'Stop')
        % from GUI or GUI_ScanStartTrigStop
        TP.D.Trl.StartTrigStop =    -2;
        if ~TP.HW.NI.T.hTask_CO_TrigListener.isTaskDone;
            % Not triggered yet, 
            %   if the Trial is already triggered, then just wait for
            %   updateScanKeeper to finish it and "cancel" the current Trial. 
            %   There's a slight chance that the current trial is executing
            %   scanStopped when called by GUI stop again here
            scanStopped;
        end            
    else
        % from external trigger falling edge
        TP.D.Trl.StartTrigStop =  	-1;	
        % GUI Exclusive StartTrigStop Selection
        h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
        set(TP.UI.H.hTrl_StartTrigStop_Rocker, 'SelectedObject', h(1));
    end;
    %   -3 = Timeout,       -2 = Stopping by GUI,   -1=Stopping by ExtTrig, 
    %   0 = Stopped,        1 = Started,            2 = Triggered  
       
%% MSG LOG 
    msg = [datestr(now) '\tscanStopping\tScanning Stopping since Triggered / Pressed\r\n'];