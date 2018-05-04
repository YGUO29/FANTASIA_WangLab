function msg = SetupD
%% SetupD
% To setup all the preset parameters for following procedures 

%% Initiation for TP.D
global TP

%% User Interface
for disp = 1
    TP.UI.Style =               'dark';
    % TP.UI.Style =             'norm';
    TP.UI.LookAndFeel =         'com.sun.java.swing.plaf.windows.WindowsLookAndFeel';
        % lafs = javax.swing.UIManager.getInstalledLookAndFeels; 
        % for lafIdx = 1:length(lafs),  disp(lafs(lafIdx));  end
        % javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
        % javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
        % javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.motif.MotifLookAndFeel');
        % javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
        % javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel');

    TP.UI.Styles.dark.BG =     	[   0       0       0];
    TP.UI.Styles.dark.HL =   	[   0       0       0];
    TP.UI.Styles.dark.FG =     	[   0.6     0.6     0.6];    
    TP.UI.Styles.dark.TextBG  = [   0.25    0.25    0.25];
    TP.UI.Styles.dark.SelectB = [   0       0       0.35];
    TP.UI.Styles.dark.SelectT = [   0       0       0.35];

    TP.UI.Styles.norm.BG =      [   0.8     0.8     0.8];
    TP.UI.Styles.norm.HL =      [   1       1       1];  
    TP.UI.Styles.norm.FG =      [   0       0       0];
    TP.UI.Styles.norm.TextBG =  [   0.94    0.94    0.94];
    TP.UI.Styles.norm.SelectB = [   0.94    0.94    0.94];
    TP.UI.Styles.norm.SelectT = [   0.18    0.57   	0.77];

    % select UI color style
    eval(['TP.UI.C = TP.UI.Styles.',TP.UI.Style,';']);
end;

%% D.SYS (System)
for disp = 1
 	TP.D.Sys.Name =           	'FANTASIA';
    TP.D.Sys.FullName =         '[Flexible Agile, and Noise-free Two-photon AOD Scanning Imaging for Awake animals]';
    %%%%%%%%%%%%%%%%%%%%%%% PC
    TP.D.Sys.PC.Data_Dir =  	['D:\=',TP.D.Sys.Name,'=\'];
    TP.D.Sys.PC.CCD_Device =    '';
    
    %%%%%%%%%%%%%%%%%%%%%%% NI
    % ScanImage 5.1, released by end of 2015, support Matlab calling from 
    % Matlab R2015a, to NI-DAQmx 15, in Windows 10 x64 
        % NI Summary? wiring by X. Song @ 2016/1/1
        %'Sys' level
        %   RTSI4
        %   RTSI5
        %   RTSI6       Trigger Bridge   
        %	RTSI7       Timeing Bridge  20MHzTimebase     
        %'Dev1' PCI-6115 terminated on a SCB68      (check on NI)
        % PMT H7422PA-40 on M9012                   (check on Hamamatsu)
        %   P0.0 DO     PMT Ctrl,   	H= turn it ON,      L= turn PMT OFF
        %   P0.1 DO     FAN Ctrl,       H= turn it OFF,     L= turn Fan ON
        %   P0.2 DO     PEL Ctrl,   	H= turn it OFF,     L= turn Pel ON
        %   P0.3 DI     PMT M9012,  	H= M9012 power ON,  L= M9012 power OFF
        %   P0.4 DI     PMT Status, 	H= PMT is ON
        %                               Fast Flashing(2Hz)   = PMT OFF  & Cooled,
        %                               Slow Flashing(1/2Hz) = PMT OFF  & Cooling,
        %                                                   L= PMT OFF  & Cooling is OFF
        %   P0.5 DI     PMT Error,   	H= Overload Protection is ON, 
        %                               F= Cooling Error.   L= No error
        %   P0.6 DI     PMT TooBright
        %   P0.7 DI     PMT TooHot
        %   AI0         PMT Signal (through a PPA-100 pre-amp),
        %                                           (check on Becker&Hickl)
        %   AO0         PMT Gain Ctrl
        %   AO1         AOD X&Y Amplitude Ctrl 
        %   Ctr0        Internal Trigger Line
        %   Ctr1        ??

        %'Dev2' PCIe-6536 terminated on a CB-2162   (check on NI)
        % AOD DTSXY-A15-720.920 on DDSPA            (check on AAoptoelectronic)
        %   port2:3     X axis
        %   line31      X axis scan signal change enable
        %   line16:30   X axis scan signal
        %   port0:1     Y axis
        %   line15      Y axis scan signal change enable
        %   line0:14    Y axis scan signal

        %'Dev3' PCIe-6323 terminated on 2 SCB68   	(check on NI)
        %   AI16        PMT #1 Gain Monitor
        %   AI17        AOD X Amplitude Monitor
        %   AI18        AOD Y Amplitude Monitor
        %   AI19        (Reserved for Sound Calibration connection, 2015/12)
        %   Ctr0        Trigger Listerner      
        %   Ctr1        (Reserved for XB3 TrialTrigger)
        %   Ctr2        (Reserved for XB3 CORecStop)
    %%%%%%%%%%%%%%%%%%%%%%% NI, SYSTEM, TIMING & BRIDGES
    TP.D.Sys.NI.Sys_TimingSource =  	{'Dev1',	'20MHzTimebase'};
    TP.D.Sys.NI.Sys_TimingBridge =  	{'',        'RTSI7'};
    TP.D.Sys.NI.Sys_TimingRate =        20e6;
    
    %%%%%%%%%%%%%%%%%%%%%%% NI, DEVICE
    TP.D.Sys.NI.Dev_Names =            	{'Dev1',    'Dev2',     'Dev3'};
                                        % 6115      6536        6323
                                        
    %%%%%%%%%%%%%%%%%%%%%%% NI, TASK
    TP.D.Sys.NI.Task_AI_6115_Name =     'PMT Signal Aquisition Task';
    TP.D.Sys.NI.Task_AI_6115_SR =       10e6;
        % 10MHz sampling rate for PMT. PCI-6115 max is 10MS/s/ch
    TP.D.Sys.NI.Task_AO_6115_Name =     'PMT Gain and AOD Amp Ctrl Task';
    TP.D.Sys.NI.Task_DO_6115_Name =     'PMT Power Ctrl Task';
    TP.D.Sys.NI.Task_DI_6115_Name =     'PMT Status Monitor Task';

 	TP.D.Sys.NI.Task_DO_6536_Name =     'AOD Scanning Task';
    TP.D.Sys.NI.Task_DO_6536_SR =       20e6;
        % 20MHz sampling rate for AOD. PCIe-6536 max is 25MHz
    
    TP.D.Sys.NI.Task_AI_6323_Name =     'SYSTEM Status Monitor Task';
    TP.D.Sys.NI.Task_AI_6323_SR =       100;
        % that means    if 3 channels are recorded, max SR
        % total throughput on PCIe-6323 is 250kS/s <= 83kS/s
        %               if 5 channels are recorded, max SR < 50kS/s
        % However, due to the scanning sampling cross talk, the 100Hz rate is
        % selected
    TP.D.Sys.NI.Task_AI_6323_UR =       10;
        % system monitor update rate, 10Hz, 100ms per update
    TP.D.Sys.NI.Task_AI_6323_SmplToUpdt = ...
                                        round(  TP.D.Sys.NI.Task_AI_6323_SR/...
                                                TP.D.Sys.NI.Task_AI_6323_UR);
    TP.D.Sys.NI.Task_AI_6323_UpdateFunc = ...
                                        @updateSysStatus;      
    TP.D.Sys.NI.Task_AO_6323_Name =     'GRAB Sound Playback Task';
    TP.D.Sys.NI.Task_AO_6323_UR =       100e3;

    TP.D.Sys.NI.Task_CO_IntTrig_Name =      'Internal Trigger Task';
    TP.D.Sys.NI.Task_CO_TrigListener_Name = 'Trigger Listener Task';
    TP.D.Sys.NI.Task_CO_TrigListener_Func = @scanTriggered;  
    TP.D.Sys.NI.Task_CO_StopListener_Name = 'Stop Listener Task';
    TP.D.Sys.NI.Task_CO_StopListener_Func = @scanStopping;
        % Task_CO_Frame in the future?
    
    %%%%%%%%%%%%%%%%%%%%%%% NI, CHANNAL, ANALOG & DIGITAL 
    TP.D.Sys.NI.Chan_AO_PMT_CtrlGain = ...
        {'Dev1', 0,     'PMT Gain Ctrl',        [-10 10]};
        % dev,   port,  name,                   Vrange
    TP.D.Sys.NI.Chan_AO_AOD_CtrlAmps = ...
        {'Dev1', 1,    	'AOD Amps Ctrl',     	[-10 10]};
    TP.D.Sys.NI.Chan_AO_SoundWave = ...
        {'Dev3', 0,     'Sound Playback',       [-10 10]};    
    TP.D.Sys.NI.Chan_DO_PMT_Switch = ...
        {'Dev1', 'line0:2',...
                    {   'TP.D.Mon.PMT.PMTctrl',...
                        'TP.D.Mon.PMT.FANctrl',...
                        'TP.D.Mon.PMT.PELctrl'}};
                    
    TP.D.Sys.NI.Chan_DI_PMT_Status = ...
        {'Dev1', 'line3:7',...
                    {   'M9012',    'Status',   'Error',    'TooBright',    'TooHot'},...
                        [0 0.8 0; 	0 0.8 0;   	0.8 0 0;  	0.8 0 0;        0.8 0 0],...
                        [1 2 3 4 5]}; 
        % device, port, name, color, proc#
    TP.D.Sys.NI.Chan_DI_PMT_Status{6} = length(TP.D.Sys.NI.Chan_DI_PMT_Status{3});
        % how many lines need to be update

    TP.D.Sys.NI.Chan_AI_PMT_MontGain = ...
        {'Dev3', 16, 	'PMT Gain Mont',        [-10 10]};
    TP.D.Sys.NI.Chan_AI_AOD_MontAmpX = ...
        {'Dev3', 17,   	'AOD X Amp Mont',       [-10 10]};
    TP.D.Sys.NI.Chan_AI_AOD_MontAmpY = ...
        {'Dev3', 18,   	'AOD Y Amp Mont',       [-10 10]};

    TP.D.Sys.NI.Chan_DO_Scan = ...
        {'Dev2', 'port0:3'};
    TP.D.Sys.NI.Chan_AI_PMT1 = ...
        {'Dev1', 0,  	'PMT',                  [-5 5]};

    %%%%%%%%%%%%%%%%%%%%%%% NI, COUNTERS
    TP.D.Sys.NI.Chan_CO_IntTrig = ...
        {'Dev1', 0,   	'Internal Trigger Line',[7e6 7e6], ...
                        '20MHzTimebase',        0,...
                        'DAQmx_Val_Low'};
%         {'Dev1', 0,   	'Internal Trigger Line',[100 100],	'20MHzTimebase'};
        % device,port,  name,                   tick#,      timebase
        % 2^32/20e6 ~= 214.7 seconds
        % 2^24/20e6 ~= 0.839 seconds
        % /Dev3/Ctr0, default is 100 ticks on and 100 ticks off,       5us
        % Dev3/Ctr0 cannot be routed simultaneouly with Dev3/Ctr1 on RTSI6 
        % Dev1/Ctr0 can be routed to RTSI6, by nature of 6115
        % Dev1/Ctr1 CANNOT be routed to RTSI6, by nature of 6115
    TP.D.Sys.NI.Chan_CO_TrigListener = ...
        {'Dev1', 1,   	'Trigger Listener',   	[2 2],      '20MHzTimebase'};
        % device,port,  name,                   tick#,      timebase
        % /Dev3/Ctr0, 10 ticks on and 10 ticks off,         0.1us
        % This task is necessary to listen to external start trigger
        % AOD Amp and PMT power are switched when this task is done
        % 2 ticks is the minimum number DAQmx accepts
    TP.D.Sys.NI.Chan_CO_StopListener = ...
        {'Dev3', 0,   	'Stop Listener',        [2 2],      TP.D.Sys.NI.Sys_TimingBridge{1}};
        % device,port,  name,                   tick#,      timebase
        % /Dev3/Ctr0, 10 ticks on and 10 ticks off,         0.1us
        % This task is necessary to listen to external start trigger
        % AOD Amp and PMT power are switched when this task is done
        % 2 ticks is the minimum number DAQmx accepts
     
    %%%%%%%%%%%%%%%%%%%%%%% NI, SYSTEM, TRIGGER & BRIDGE
    TP.D.Sys.NI.Sys_TrigInternalSrc =   {TP.D.Sys.NI.Chan_CO_IntTrig{1},...
                                                    ['Ctr',num2str(TP.D.Sys.NI.Chan_CO_IntTrig{2}),'InternalOutput']};
    TP.D.Sys.NI.Sys_TrigBridge =        {'',        'RTSI6'};    
    
    % TP.D.Sys.NI.Chan_CO_FrameCounter = ...
    %     {'Dev3', 3,   	'Frame Ctr',            [1000 NaN],	TP.D.Sys.NI.TimingBridge{1}};
    %     % device, port, name, tick#, timebase
    %     % /Dev3/Ctr1, 10 ticks on, 0.5us
        
 	%%%%%%%%%%%%%%%%%%%%%%% AOD
    TP.D.Sys.AOD.FreqBW =           30 * 1e6;	% BandWidth     @920nm
    TP.D.Sys.AOD.FreqCF =        	87 * 1e6;  	% Central Freq  @920nm
    TP.D.Sys.AOD.AcousticSpeed =    650;        % 650m/s in manual
	% to be determined, more related to AOD aperture and position
    % TP.D.Image.Tdelay =          NaN;
    % TP.D.Image.Ttrans =          NaN;
    
	%%%%%%%%%%%%%%%%%%%%%%% PMT
    TP.D.Sys.PMT.CtrlGainRange =    [0 0.9]; 	% 0-0.9V control range 
    TP.D.Sys.PMT.CtrlGainSteps =    [0.01 0.05];% translated into [0.01V 0.05V] real step

	%%%%%%%%%%%%%%%%%%%%%%% Mech
    % TP.D.Sys.Mech                             % save for later
    
	%%%%%%%%%%%%%%%%%%%%%%% Power     
    % Thorlabs APT Software is required to communicate with the TDC001 motor
    % Thorlabs PM100 series driver  + Communicatior are needed
    % Driver                        + 488.2 instrument coding communication 
    TP.D.Sys.Power.Meter.ID(1,1:2) = ...
        {'PM100USB',    'USB0::0x1313::0x8072::P2004081::INSTR'};
                                                        % Thorlabs PM100USB
	TP.D.Sys.Power.Meter.ID(2,1:2) = ...
        {'PM100A',      'USB0::0x1313::0x8079::P1000623::INSTR'};
                                                        % Thorlabs PM100A
    TP.D.Sys.Power.HWProtatorID =       83854755;       % Thorlabs TDC001 SN#
    TP.D.Sys.Power.HWP_RotAnglRange =   [0 90];     	% 0-90 degree rotation range
    TP.D.Sys.Power.HWP_RotAnglSteps =   [1 10];         % translated into [1degree 10degree] real step
    
    TP.D.Sys.Power.AOD_CtrlAmpRange =   [-0.03 5];      % 0-5V control range
    TP.D.Sys.Power.AOD_CtrlAmpSteps =   [0.1 0.5];      % translated into [0.1V 0.5V] real step
    
    try
        % try to load previous calibrated data if they exist
        load('PowerCalibration.mat')
        TP.D.Sys.Power.C = Power.TP;
    catch
        TP.D.Sys.Power.C.HWP_pmin =         NaN;
        TP.D.Sys.Power.C.HWP_pmax =         NaN;
        TP.D.Sys.Power.C.HWP_pmaxAngle =    NaN;
        
        TP.D.Sys.Power.C.ARM_p1 =           NaN;
        TP.D.Sys.Power.C.ARM_p2 =           NaN;
        
        TP.D.Sys.Power.C.AMP_p1 =           NaN;
        TP.D.Sys.Power.C.AMP_p2 =           NaN;
        TP.D.Sys.Power.C.AMP_p3 =           NaN;
        
        TP.D.Sys.Power.C.AOD_p1 =           NaN;
        TP.D.Sys.Power.C.AOD_p2 =           NaN;
        TP.D.Sys.Power.C.AOD_p3 =           NaN;
        TP.D.Sys.Power.C.AOD_p4 =           NaN;
        warndlg('No power calibration data founded, System needs a calibration');
    end;
end;

%% D.Mky (Monkey)
for disp = 1
    
    TP.D.Mky.ID =             	'M00X';
    TP.D.Mky.Side =          	'right';
    TP.D.Mky.AngleXY =       	90;
    
end;

%% D.Exp (Experiment)
for disp = 1
    
	%%%%%%%%%%%%%%%%%%%%%%% Mech
    TP.D.Exp.Mech.EstX =       	NaN; 
        % define as dorsal-ventral direction, in um
    TP.D.Exp.Mech.EstY =       	NaN;
        % define as rostral-caudal direction, in um
    TP.D.Exp.Mech.Z0_SM1Z =  	NaN;
        % Z reading # on SM1Z of the cortex surface level
    TP.D.Exp.SurfaceWF =        [];
        % Surface CCD widefield image
        
end;

%% D.Ses (Session)
for disp = 1
    TP.D.Ses.Committed =                0;
    TP.D.Ses.TimeStampCommitted =       NaN;
 	%%%%%%%%%%%%%%%%%%%%%%% Mech
    TP.D.Ses.Mech.Zs_SM1Z =             NaN;
        % Z reading # on SM1Z of this session level
            % NaN for searching session
  	TP.D.Ses.Mech.EstZ =                NaN;
        % define as superfacial-deep direction, in um
    
    %%%%%%%%%%%%%%%%%%%%%%% Scan
    TP.D.Ses.Scan.Mode =                '2D random';
    TP.D.Ses.Scan.ModeNum =             1;
    
    TP.D.Ses.Scan.GenFunc =             @GenScanPatn2DrandomFullRaster;
    TP.D.Ses.Scan.ScanSeq =             [];
    TP.D.Ses.Scan.ScanInd =             {};     % may be move to "Image" field

    TP.D.Ses.Scan.NumSmplPerPixl =      2e6;
    TP.D.Ses.Scan.NumPixlPerAxis =   	1;
    TP.D.Ses.Scan.NumLayrPerVlme =    	1;
    TP.D.Ses.Scan.NumSmplPerVlme =      NaN;
    
    TP.D.Ses.Scan.LayrSpacingInZ =      NaN;

    TP.D.Ses.Scan.VolumeTime =          NaN;
    TP.D.Ses.Scan.VolumeRate =         	NaN;
        
  	%%%%%%%%%%%%%%%%%%%%%%% Image    
    TP.D.Ses.Image.NumSmplPerPixl = 	1e6;
    TP.D.Ses.Image.NumPixlPerUpdt =   	NaN;
    TP.D.Ses.Image.NumSmplPerUpdt =     NaN;
    TP.D.Ses.Image.NumUpdtPerVlme =     1;
    TP.D.Ses.Image.NumVlmePerUpdt =     1;
    TP.D.Ses.Image.UpdateTime =         NaN;
    TP.D.Ses.Image.UpdateRate =         NaN;
    TP.D.Ses.Image.ImgFunc =            '';
	TP.D.Ses.Image.Enable =             0;   
       
end;

%% D.Trl (Trial)
for disp = 1
    
    TP.D.Trl.ScanScheme =    	'FOCUS';            
    TP.D.Trl.ScanSchemeNum =   	1;
    TP.D.Trl.ScanTrigType =   	'internal';
%     TP.D.Trl.FileName =         '';    

    TP.D.Trl.DataLogging =    	0;     
    TP.D.Trl.Udone =          	0;     	% Update # done
    TP.D.Trl.Vdone =           	0;     	% Volume # done
    TP.D.Trl.Tdone =           	0;    	% Time done (in sec)
    
    TP.D.Trl.Unum =             0;
    TP.D.Trl.Vnum =             0;
    
    TP.D.Trl.Vmax =             NaN;    % Max Volume # in a trial
    TP.D.Trl.Tmax =            	Inf;
    TP.D.Trl.TmaxFocusDefault = Inf;
    TP.D.Trl.TmaxGrabDefault =	214;
    TP.D.Trl.TmaxLoopDefault =  214;    % limited to the external trigger counting:
                                        %   as 2^32/20e6 ~= 214.7 seconds
    TP.D.Trl.Tmax4GB =          214;    % limited to the 4GB Tiff size (w/o compression)
                                        
    
    TP.D.Trl.StartTrigStop =        0;
    %   -3 = Timeout,       -2 = Stopping by GUI,   -1=Stopping by ExtTrig, 
    %   0 = Stopped,        1 = Started,            2 = Triggered
    TP.D.Trl.TimeStampStarted =     0;
    TP.D.Trl.TimeStampTriggered =	0;
    TP.D.Trl.TimeStampStopping =    0;
    TP.D.Trl.TimeStampStopped =     0;
    
    TP.D.Trl.PowerOverload =        0;
    
    TP.D.Trl.VS =               [];

    TP.D.Trl.GRAB.SoundFname =      '';
    TP.D.Trl.GRAB.SoundWave =       [];
end;

%% D.Vol (Volume)
for disp = 1
    % Image Frame Data
    TP.D.Vol.DataColRaw =    	zeros(512, 1, 'int16');   % int16 signed,   raw data
    TP.D.Vol.DataColDble =      zeros(512^2*100,1);     % Double precision float 64b,   for calculations
    TP.D.Vol.PixlSmplMat =    	zeros(512^2,1);         % 
    % TP.D.Vol.LayerRaw{1} =  	zeros(512, 512);
    % TP.D.Vol.LayerDispD{1} = 	zeros(512, 512, 3);
    TP.D.Vol.LayerDisp{1} =   	zeros(512, 512, 3, 'uint8');
    
    TP.D.Vol.PixelHist =         zeros(1,300); 
    TP.D.Vol.PixelHistEdges =    -344:8:2048; 	% 300 bin 
        % N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1).  
        % The last bin will count any values of X that match EDGES(end)
        % -344~-337     is the 1    bin
        % 0~7           is the 44   bin
        % 2040-2047    	is the 299  bin
        % 2048          is the 300  bin
        % there are 256 +1 bin from 0-2048, match with the 8bit color
%     TP.D.Vol.PixelHistEdges =    -352:16:2048; 	% 150 bin 
    TP.D.Vol.SampleMax =        0;
    TP.D.Vol.SampleMin =        0;
    TP.D.Vol.SampleMean =   	0;
    
end;

%% D.Mon (Monitor)
for disp = 1
    TP.D.Mon.Power.AOD_CtrlAmpValue =   0;
    TP.D.Mon.Power.AOD_MontAmpValue =   [0.00 0.00];	% in Volt
    TP.D.Mon.Power.AOD_MontAmpNoise =   [0 0];         	% in mV

    TP.D.Mon.Power.PmaxAtCurAngle =     NaN;            % in mW, need calibration
    TP.D.Mon.Power.PmaxCtxAllowed =     200;            % in mW, need calibration
    TP.D.Mon.Power.PinferredAtCtx =     0;              % Predicted by Power Control
    TP.D.Mon.Power.PmeasuredS121C =     0;              % Monitored at Dichroic   
   
    TP.D.Mon.Power.CalibFlag =          0;
    
    TP.D.Mon.PMT.PMTctrl =              0;
    TP.D.Mon.PMT.FANctrl =              0;
    TP.D.Mon.PMT.PELctrl =              0;
    TP.D.Mon.PMT.StatusLED =            logical([0 0 0 0 0])';
                                                        % Dev1/line3:7 [M9012, Status, Error, TooBright, TooHot]
    TP.D.Mon.PMT.CtrlGainValue =        0;
    TP.D.Mon.PMT.MontGainValue =        0.00;          	% in Volt
    TP.D.Mon.PMT.MontGainNoise =        0;             	% in mV
    
    TP.D.Mon.Image.DisplayEnable =      0;    
    TP.D.Mon.Image.DisplayMode =     	'Rltv';
    TP.D.Mon.Image.DisplayModeNum =     2;
	TP.D.Mon.Image.UpdtCallback =       @updateImage2Drandom;

end;

%% D.Sys (System Preset Scan Configurations
for disp = 1
    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{1}.mode       = '2D random';
    TP.D.Sys.Scan.PresetGroup{1}.title      = '2D \n random';
    TP.D.Sys.Scan.PresetGroup{1}.tip        = '2D jumping points';
    TP.D.Sys.Scan.PresetGroup{1}.default    = 1;
    %--------------------------------------------------------------------------
        Cfg.name            = 'center'; 
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{1}.mode;
        Cfg.NumSmplPerPixl6115  = 1e6;
        Cfg.NumPixlPerAxis      = 1;   	Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable   = 0;
        Cfg.NumUpdtPerVlme      = 1; 	Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{1} = Cfg;
        clear Cfg;

        Cfg.name            = '3x3 s'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{1}.mode;
        Cfg.NumSmplPerPixl6115  = 3e6;
        Cfg.NumPixlPerAxis      = 3;  	Cfg.SelectEnable    = 1;  
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 0;
        Cfg.NumUpdtPerVlme      = 9;  Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{2} = Cfg; 
        clear Cfg;

        Cfg.name            = '5x5 f';	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{1}.mode;
        Cfg.NumSmplPerPixl6115  = 200;
        Cfg.NumPixlPerAxis      = 5;    Cfg.SelectEnable    = 1;    
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable	= 0;
        Cfg.NumUpdtPerVlme      = 1;    Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{3} = Cfg;
        clear Cfg;

    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{2}.mode       = '2D random';
    TP.D.Sys.Scan.PresetGroup{2}.title      = '2D \n random';
    TP.D.Sys.Scan.PresetGroup{2}.tip        = '2D jumping points';
    TP.D.Sys.Scan.PresetGroup{2}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name            = '256p'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{2}.mode;
        Cfg.NumSmplPerPixl6115  = 100;
        Cfg.NumPixlPerAxis      = 256;  Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;  	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 1;  	Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{4} = Cfg;
        clear Cfg;

        Cfg.name            = '512p';	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{2}.mode;
        Cfg.NumSmplPerPixl6115  = 200;
        Cfg.NumPixlPerAxis      = 512; 	Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 1;  	Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{5} = Cfg;
        clear Cfg;

        Cfg.name            = '1024p';  
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{2}.mode;
        Cfg.NumSmplPerPixl6115  =200;
        Cfg.NumPixlPerAxis      = 1024;	Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 4;   	Cfg.GenFunc = @GenScanPatn2DrandomFullRaster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{6} = Cfg;
        clear Cfg;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{3}.mode       = '2D random';
    TP.D.Sys.Scan.PresetGroup{3}.title      = '2D \n random';
    TP.D.Sys.Scan.PresetGroup{3}.tip        = '2D jumping points';
    TP.D.Sys.Scan.PresetGroup{3}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name            = 'auto'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{3}.mode;
        Cfg.NumSmplPerPixl6115  = NaN;
        Cfg.NumPixlPerAxis      = 1;    Cfg.SelectEnable    = 0;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;  	Cfg.GenFunc = @GenScanPatn2DrandomAuto;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{7} = Cfg;
        clear Cfg;

        Cfg.name            = 'manu'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{3}.mode;
        Cfg.NumSmplPerPixl6115  = NaN;
        Cfg.NumPixlPerAxis      = 1;    Cfg.SelectEnable    = 0; 
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn2DrandomManu;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{8} = Cfg;
        clear Cfg;

        Cfg.name            = '1024R';	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{3}.mode;
        Cfg.NumSmplPerPixl6115  = 200;
        Cfg.NumPixlPerAxis      = 1024; Cfg.SelectEnable    = 0;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 4;    Cfg.GenFunc = @GenScanPatn2DrandomFullRandom;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{9} = Cfg;
        clear Cfg;

    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{4}.mode       = '2D raster';
    TP.D.Sys.Scan.PresetGroup{4}.title      = '2D \n raster';
    TP.D.Sys.Scan.PresetGroup{4}.tip        = '2D diagonal sweep';
    TP.D.Sys.Scan.PresetGroup{4}.default    = 0;
    %--------------------------------------------------------------------------

        Cfg.name = '';                  Cfg.SelectEnable    = 0;
        TP.D.Sys.Scan.PresetCfg{10}= Cfg;   
        clear Cfg;
        
        Cfg.name = '';                  Cfg.SelectEnable    = 0;
        TP.D.Sys.Scan.PresetCfg{11}= Cfg;   
        clear Cfg;
        
        Cfg.name = '';                  Cfg.SelectEnable    = 0;
        TP.D.Sys.Scan.PresetCfg{12}= Cfg;   
        clear Cfg;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{5}.mode       = '2D raster';
    TP.D.Sys.Scan.PresetGroup{5}.title      = '2D \n raster';
    TP.D.Sys.Scan.PresetGroup{5}.tip        = '2D diagonal sweep';
    TP.D.Sys.Scan.PresetGroup{5}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name            = '327,2s'; 
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{5}.mode;
        Cfg.NumSmplPerPixl6115  = 2;
        Cfg.NumPixlPerAxis      = 327;  Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable  	= 1;   
        Cfg.NumUpdtPerVlme      = 0.25;	Cfg.GenFunc = @GenScanPatn2Draster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{13}= Cfg;
        clear Cfg;

        Cfg.name = '';                  Cfg.SelectEnable    = 0;
        TP.D.Sys.Scan.PresetCfg{14}= Cfg;
        clear Cfg;
        
        Cfg.name = '';                  Cfg.SelectEnable    = 0;
        TP.D.Sys.Scan.PresetCfg{15}= Cfg;
        clear Cfg;

    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{6}.mode       = '2D raster';
    TP.D.Sys.Scan.PresetGroup{6}.title      = '2D \n raster';
    TP.D.Sys.Scan.PresetGroup{6}.tip        = '2D diagonal sweep';
    TP.D.Sys.Scan.PresetGroup{6}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name            = '653,1u'; 
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{6}.mode;
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;	Cfg.GenFunc = @GenScanPatn2Draster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{16}= Cfg;
        clear Cfg;

        Cfg.name            = '653,2u'; 
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{6}.mode;
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 0.5;	Cfg.GenFunc = @GenScanPatn2Draster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{17}= Cfg;
        clear Cfg;

        Cfg.name            = '653,4u'; 
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{6}.mode;
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1;
        Cfg.NumLayrPerVlme      = 1;   	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 0.25;	Cfg.GenFunc = @GenScanPatn2Draster;
        Cfg.LayrSpacingInZ      = NaN;
        TP.D.Sys.Scan.PresetCfg{18}= Cfg;
        clear Cfg;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{7}.mode       = '3D raster';
    TP.D.Sys.Scan.PresetGroup{7}.title      = '3D \n raster';
    TP.D.Sys.Scan.PresetGroup{7}.tip        = '3D diagonal sweep, layer by layer';
    TP.D.Sys.Scan.PresetGroup{7}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name          	= '3/20u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 3;    Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 20;
        TP.D.Sys.Scan.PresetCfg{19} = Cfg;
        clear Cfg;

        Cfg.name          	= '5/10u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 5;  	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 10;
        TP.D.Sys.Scan.PresetCfg{20} = Cfg;
        clear Cfg;

        Cfg.name          	= '21/2u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 21;  	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 2;
        TP.D.Sys.Scan.PresetCfg{21} = Cfg;
        clear Cfg;

    % Preset Scan Configurations Groups
    TP.D.Sys.Scan.PresetGroup{8}.mode       = '3D raster';
    TP.D.Sys.Scan.PresetGroup{8}.title      = '3D \n raster';
    TP.D.Sys.Scan.PresetGroup{8}.tip        = '3D diagonal sweep, layer by layer';
    TP.D.Sys.Scan.PresetGroup{8}.default    = 0;
    %--------------------------------------------------------------------------
        Cfg.name          	= '3/50u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 3;    Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 50;
        TP.D.Sys.Scan.PresetCfg{22} = Cfg;
        clear Cfg;

        Cfg.name          	= '11/10u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 11;  	Cfg.ImagingEnable 	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 10;
        TP.D.Sys.Scan.PresetCfg{23} = Cfg;
        clear Cfg;

        Cfg.name          	= '51/2u'; 	
        Cfg.ScanMode            = TP.D.Sys.Scan.PresetGroup{7}.mode; 
        Cfg.NumSmplPerPixl6115  = 1;
        Cfg.NumPixlPerAxis      = 653;  Cfg.SelectEnable    = 1; 
        Cfg.NumLayrPerVlme      = 51;  	Cfg.ImagingEnable	= 1;   
        Cfg.NumUpdtPerVlme      = 1;   	Cfg.GenFunc = @GenScanPatn3Draster;
        Cfg.LayrSpacingInZ      = 2;
        TP.D.Sys.Scan.PresetCfg{24} = Cfg;
        clear Cfg;
end;

%% LOG MSG
msg = [datestr(now) '\tSetupD\tTP.D initialized\r\n'];