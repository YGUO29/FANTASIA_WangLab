function scanTriggered(~,~)
% This function is called by 
%   (1) TrigListener Task callbacks 
% and is the only function that accompanys scanning & imaging triggered
% start
% takes ? s on T5810 @ 2015/1

%% State
global TP

%% Time & Flag, for Triggered
    TP.D.Trl.StartTrigStop =        2;
    %   -3 = Timeout,       -2 = Stopping by GUI,   -1=Stopping by ExtTrig, 
    %   0 = Stopped,        1 = Started,            2 = Triggered
    TP.D.Trl.TimeStampTriggered =	datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF'); 

%% Switch AOD & PMT accordingly
    feval(TP.D.Sys.Name,...
  	'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  TP.D.Mon.Power.AOD_CtrlAmpValue]);
        %           PMT Gain Control            AOD Amp, && StartTrigStop==2
    feval(TP.D.Sys.Name,...        
	'GUI_DO_6115',[ TP.D.Ses.Image.Enable;	TP.D.Ses.Image.Enable;	0]);
    	%       	PMTon,                  FANoff,                 PELoff
    % Speed Testing on T3500, 12GB RAM, 7200rpm HD
    % w/ PMT GUI update,    these 2 cells takes ~0.015s,    15ms
    % w/o PMT GUI update,   these 2 cells takes ~0.004s,    4ms
    
%% GUI Exclusive StartTrigStop Selection & Coloring
	h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
	set(TP.UI.H.hTrl_StartTrigStop_Rocker, 'SelectedObject', h(3));
    set(h(3),   'backgroundcolor', TP.UI.C.SelectB);
	set(h(1),   'backgroundcolor', TP.UI.C.TextBG);
	set(h(2),   'backgroundcolor', TP.UI.C.TextBG);

%% MSG LOG
    msg = [datestr(now) '\tScanning Triggered\r\n'];
  	fprintf( TP.D.Sys.PC.hLog,   msg); 
    