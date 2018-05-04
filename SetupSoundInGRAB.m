function SetupSoundInGRAB(~,~)
% This will load a sound file and setup an AO_6323 Task to play that sound
% and build (reset) an "external" trigger CO task to control the other tasks.
% AO_6223, AI_6115, DO_6536, CO_TrigListener are all triggered by this

import dabs.ni.daqmx.*
global TP

%% Load Sound File
[filename, filepath, ~] =  	uigetfile('.wav');
if filename==0
%     MSG = 'load sound wrong';
    return
end
TP.D.Trl.GRAB.SoundFname =   	[filepath, filename];
SoundWave =     audioread(TP.D.Trl.GRAB.SoundFname, 'native');
SoundRawMax =   max(abs(double(SoundWave)));
SoundOutMax =   TP.D.Sys.NI.Chan_AO_SoundWave{4}(2)-0.001;
TP.D.Trl.GRAB.SoundWave = SoundOutMax * double(SoundWave)/SoundRawMax;

%% Setup Timeout Time
lwave = length(TP.D.Trl.GRAB.SoundWave);
tmax =  lwave/TP.D.Sys.NI.Task_AO_6323_UR;
feval(TP.D.Sys.Name, 'GUI_Tmax', tmax);

%% Setup hTask_AO_6223
try TP.HW.NI.T.hTask_AO_6323.abort();       catch;  end;
try TP.HW.NI.T.hTask_AO_6323.delete();      catch;  end;
TP.HW.NI.T.hTask_AO_6323 = Task(TP.D.Sys.NI.Task_AO_6323_Name);
TP.HW.NI.T.hTask_AO_6323.createAOVoltageChan(...
    TP.D.Sys.NI.Chan_AO_SoundWave{1},   TP.D.Sys.NI.Chan_AO_SoundWave{2}, ...
    TP.D.Sys.NI.Chan_AO_SoundWave{3},   TP.D.Sys.NI.Chan_AO_SoundWave{4}(1), ...
    TP.D.Sys.NI.Chan_AO_SoundWave{4}(2),'DAQmx_Val_Volts');
TP.HW.NI.T.hTask_AO_6323.cfgSampClkTiming(...
    TP.D.Sys.NI.Task_AO_6323_UR,...
    'DAQmx_Val_FiniteSamps',            lwave );
TP.HW.NI.T.hTask_AO_6323.cfgOutputBuffer(...
                                        lwave*2 );
% TP.HW.NI.T.hTask_AO_6323.set(...
%   	'sampClkTimebaseRate',              TP.D.Sys.NI.Sys_TimingRate,...
%   	'sampClkTimebaseSrc',               TP.D.Sys.NI.Sys_TimingBridge{2});
TP.HW.NI.T.hTask_AO_6323.set(...
  	'sampClkTimebaseRate',              TP.D.Sys.NI.Sys_TimingRate,...
  	'sampClkTimebaseSrc',               TP.D.Sys.NI.Sys_TimingBridge{2});

TP.HW.NI.T.hTask_AO_6323.writeAnalogData(TP.D.Trl.GRAB.SoundWave, 5 ,false);
TP.HW.NI.T.hTask_AO_6323.cfgDigEdgeStartTrig(...
 	TP.D.Sys.NI.Sys_TrigBridge{2},      'DAQmx_Val_Rising');

%% Setup Start Enable
h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
set(h(2),                               'enable',           'on');

%% MSG
    % loading sound wrong condition
