function varargout = FANTASIA(varargin)
% Flexible And Nimble Two-photon AOD Scanning Imaging in Awake animals

%% For Standarized SubFunction Callback Control
if nargin==0                % INITIATION
    InitializeTASKS
elseif ischar(varargin{1})  % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)                        
            [varargout{1:nargout}] = feval(varargin{:});
                            % FEVAL switchyard, w/ output
        else
            feval(varargin{:}); 
                            % FEVAL switchyard, w/o output  
        end
    catch MException
        rethrow(MException);
    end
end

function InitializeTASKS

%% CHECK WHETHER LAST PROGRAM IS STILL RUNNING
if CheckRunning;
    return;
end;

%% CLEAN AND RECREATE THE WORKSPACE
clc;
clear java global;
global TP;

%% INITIALIZATION
    StringTemp = SetupD;   
    TP.D.Sys.Name = mfilename;
    if isempty(dir(TP.D.Sys.PC.Data_Dir))
        mkdir(TP.D.Sys.PC.Data_Dir);
    end;        
    logfilename = [TP.D.Sys.PC.Data_Dir, datestr(now,30), '_', TP.D.Sys.Name, '_log.txt'];
    TP.D.Sys.PC.hLog = fopen(logfilename, 'w');
    
    fprintf( TP.D.Sys.PC.hLog,	[datestr(now) '\t', TP.D.Sys.Name,...
                            '\tProgram Opened, What a BEAUTIFUL day!\r\n']);
    fprintf( TP.D.Sys.PC.hLog,	StringTemp);
    fprintf( TP.D.Sys.PC.hLog,	SetupFigure);
        set(TP.UI.H0.hFigTP,    'Visible',  'off');	
%     TP.D.Mon.Power.CalibFlag = 1;
    fprintf( TP.D.Sys.PC.hLog,	SetupThorlabsPowerMeter);
    fprintf( TP.D.Sys.PC.hLog,	SetupThorlabsMotor);
  	fprintf( TP.D.Sys.PC.hLog,	SetupNIDAQ);    

    GUI_ScanScheme(1);  
  	GUI_PresetCfg(16);
    % GUI_ScanScheme should be in ahead of GUI_PresetCfg, otherwise,
    % "Start" would be enabled
  	set(TP.UI.H0.hFigTP,    'Visible',  'on');
    
%% SETUP GUI CALLBACKS
% Sys Registrations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(TP.UI.H.hSys_PowerCalib_Momentary,       'callback',             'SetupPowerCalibration');

% Mky / Exp / Ses Registrations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameter Input
set(TP.UI.H.hMky_ID_Edit,                   'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hExp_Mech_EstX_Edit,         	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hExp_Mech_EstY_Edit,         	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,       	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hSes_Mech_Zs_SM1Z_Edit,        	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hMky_Side_Edit,                 'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
set(TP.UI.H.hMky_AngleXY_Edit,              'callback',             [TP.D.Sys.Name,'(''GUI_MkyExpSes'')']);
    % Wide Field
set(TP.UI.H.hExp_WF_Momentary,            	'callback',             [TP.D.Sys.Name,'(''GUI_ExpWideField'')']);

% Scanning Pattern %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preset Modes
for i =1:length(TP.D.Sys.Scan.PresetGroup)
set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i},  'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_PresetCfg'')']);
end
    % Scan Pattern
set(TP.UI.H.hSys_AOD_FreqBW_Edit,       	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSys_AOD_FreqCF_Edit,         	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Scan_Mode_Rocker,          'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
    % Scan Commit
set(TP.UI.H.hSes_Commit_Rocker,             'SelectionChangeFcn', 	[TP.D.Sys.Name,'(''GUI_SesCommit'')']);     
% Trial Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Scheme
set(TP.UI.H.hTrl_DataLogging_Rocker,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ImageDataLogging'')']);
set(TP.UI.H.hTrl_ScanScheme_Rocker,      	'SelectionChangeFcn',  	[TP.D.Sys.Name,'(''GUI_ScanScheme'')']);
    % START/STOP
set(TP.UI.H.hTrl_StartTrigStop_Rocker,     	'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ScanStartTrigStop'')']);
    % Length
% set(TP.UI.H.hTrl_Tmax_Edit,              	'callback',             [TP.D.Sys.Name,'(''GUI_Tmax'')']);
set(TP.UI.H.hTrl_LoadSound_Momentary,       'callback',             'SetupSoundInGRAB');
% House Keeping Tasks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AO 6115 control
set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,     'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,       'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,  'callback',    	[TP.D.Sys.Name,'(''GUI_AO_6115'')']);
    % DO 6115 control
set(TP.UI.H.hMon_PMT_PMTctrl_Rocker,        'SelectionChangeFcn',	[TP.D.Sys.Name,'(''GUI_DO_6115'')']);
set(TP.UI.H.hMon_PMT_FANctrl_Toggle,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_DO_6115'')']);
set(TP.UI.H.hMon_PMT_PELctrl_Toggle,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_DO_6115'')']);
    % Display State
set(TP.UI.H.hMon_Image_DisplayEnable_Toggle,'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ImageDisplayEnable'')']);
set(TP.UI.H.hMon_Image_DisplayMode_Toggle,  'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ImageDisplayMode'')']);
    % Power
set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,  'callback',     [TP.D.Sys.Name,'(''GUI_PowerHWP'')']);
set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'callback',     [TP.D.Sys.Name,'(''GUI_PowerHWP'')']);
set(TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit,         'callback',     [TP.D.Sys.Name,'(''GUI_PowerMax'')']);     
    % CLEANUP
set(TP.UI.H0.hFigTP,                        'CloseRequestFcn',      [TP.D.Sys.Name,'(''GUI_CleanUp'')']);

%% CALLBACK FUNCTIONS
function flag = CheckRunning
    global TP
    if ~isempty(TP)
        errordlg('Last Program is still running');
        flag = 1;
    else
        flag = 0;
    end;
            
function msg = GUI_MkyExpSes(varargin)
    global TP 	
        % notes by 10/24/2014
        % need to prepare Mky-Exp-Ses DATABASE etc

    %% Where the Call is from   
    if nargin ==0
        % called by GUI:            GUI_MkyExpSes
     	switch get(gcbo, 'tag')
            case 'hMky_Side_Edit';       	t = 0;
            case 'hMky_AngleXY_Edit';       t = 0;
            case 'hMky_ID_Edit';            t = 1;
            case 'hExp_Mech_EstX_Edit';     t = 1;
            case 'hExp_Mech_EstY_Edit';     t = 1;
            case 'hExp_Mech_Z0_SM1Z_Edit';  t = 2;
            case 'hSes_Mech_Zs_SM1Z_Edit';  t = 2;
            otherwise
                errordlg ('What button did you press?');
        end;
        switch t
            case 0  % Need to update Angel Panel
                TP.D.Mky.Side = 	get(TP.UI.H.hMky_Side_Edit,'String');
                TP.D.Mky.AngleXY = 	str2double(get(TP.UI.H.hMky_AngleXY_Edit,'String'));
                SetupDispAngle(TP.UI.H0.hAxesAngle);
            case 1  % Just update numbers
                TP.D.Mky.ID =           get(TP.UI.H.hMky_ID_Edit,'String');
                TP.D.Exp.Mech.EstX =    str2double(get(TP.UI.H.hExp_Mech_EstX_Edit,'String'));
                TP.D.Exp.Mech.EstY =    str2double(get(TP.UI.H.hExp_Mech_EstX_Edit,'String'));
            case 2  % Update Z and Estimated Z                
                TP.D.Exp.Mech.Z0_SM1Z = str2double(get(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,'String'));
                TP.D.Ses.Mech.Zs_SM1Z = str2double(get(TP.UI.H.hSes_Mech_Zs_SM1Z_Edit,'String'));
                TP.D.Ses.Mech.EstZ = TP.D.Ses.Mech.Zs_SM1Z - TP.D.Exp.Mech.Z0_SM1Z;
                set(TP.UI.H.hSes_Mech_EstZ_Edit, 'string', num2str(TP.D.Ses.Mech.EstZ) );
        end;
    else
        % called by general update: GUI_MkyExpSes('Right', 30) 
        %                       or  GUI_MkyExpSes('Left', 0)   style
        % TP.D.Image.ArmSide =     varargin{1};
        % TP.D.Image.ArmAngle =    varargin{2};
    end;
    
    %% Uncommit the session
    TP.D.Ses.Committed =            0;
    h = get(TP.UI.H.hSes_Commit_Rocker, 'children');
    set(TP.UI.H.hSes_Commit_Rocker, 'SelectedObject',   h(2));
    set(h(2), 	'backgroundcolor',  TP.UI.C.SelectB);
    set(h(3), 	'backgroundcolor',  TP.UI.C.TextBG);
    h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'children');
    set(h(2),   'enable',           'inactive');
    
	%% MSG LOG
    msg = [datestr(now) '\tGUI_MkyExpSes\tUpdated','\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);  

function msg = GUI_ExpWideField
    global TP
        SetupWideField;
        
%% Ses.Scan GUI updates w/o touching NI-DAQ
function msg = GUI_PresetCfg(varargin)  
    global TP
    
    %% Where the call is from
    if nargin==0
        % called from GUI:      GUI_PresetCfg
        ScanCfg = get(get(gcbo,'SelectedObject'),'string');        
        ScanCfgNum = str2double(get(get(gcbo,'SelectedObject'),'tag'));
        ScanCfgGroup = ceil(ScanCfgNum/3);        
    else
        % called from program:  GUI_PresetCfg(x), x = 1~18; 
        ScanCfgNum = varargin{1};
        ScanCfgGroup = ceil(ScanCfgNum/3); 
        ScanCfg = TP.D.Sys.Scan.PresetCfg{ScanCfgNum}.name;
        % select the button, update GUI
        h = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{ScanCfgGroup}, 'Children');
        d = 3 - mod(ScanCfgNum-1,3);
        set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{ScanCfgGroup}, 'SelectedObject', h(d));
    end;

    %% exclusive choice update
    for i=1:length(TP.D.Sys.Scan.PresetGroup)
        % deselect other buttongroups
        if i ~= ScanCfgGroup
            set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i}, 'SelectedObject', []);
        end;
        % label & delabel the button backgroundcolor
     	h = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i}, 'children');
        for j = 1:length(h)
            if str2double(get(h(j), 'tag'))==ScanCfgNum
                set(h(j), 'backgroundcolor', TP.UI.C.SelectB);
            else
                set(h(j), 'backgroundcolor', TP.UI.C.TextBG);
            end;
        end;
    end;

    %% Read the Preset ScanCfg out   
    Cfg = TP.D.Sys.Scan.PresetCfg{ScanCfgNum};

    %% Update further GUI elements 
    h1 = get(TP.UI.H.hSes_Scan_Mode_Rocker,             'children');
  	switch Cfg.ScanMode
        case '2D random';  	Cfg.ScanModeChild = 3;
        case '2D raster'; 	Cfg.ScanModeChild = 2;
        case '3D raster';  	Cfg.ScanModeChild = 1;
    end;  
    set(TP.UI.H.hSes_Scan_Mode_Rocker,              'SelectedObject',   h1(Cfg.ScanModeChild));
        for j = 1:length(h1)
            if j==Cfg.ScanModeChild;    set(h1(j),  'backgroundcolor',  TP.UI.C.SelectB);
            else                        set(h1(j),  'backgroundcolor',  TP.UI.C.TextBG);     end;
        end;
    set(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit,   	'string',   num2str(Cfg.NumSmplPerPixl6115));
    set(TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit,      'string',   num2str(Cfg.NumPixlPerAxis));
    set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit,      'string',   num2str(Cfg.NumLayrPerVlme));
    set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit,      'string',   num2str(Cfg.LayrSpacingInZ));
    set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit,     'string',   num2str(Cfg.NumUpdtPerVlme));
    set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit,     'string',   num2str(1/Cfg.NumUpdtPerVlme));
    
    %% Update TP.D, and Generate ScanSeq
    TP.D.Ses.Scan.GenFunc = Cfg.GenFunc;
    TP.D.Ses.Image.Enable = Cfg.ImagingEnable;
    GUI_ImageDataLogging(Cfg.ImagingEnable);
    GUI_ImageDisplayEnable(Cfg.ImagingEnable);
    GUI_ScanParameters(0);

    %% LOG MSG
    msg = [datestr(now) '\tGUI_ScanCfg\tScanCfg ''',ScanCfg,''' is selected\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);
       
function msg = GUI_ScanParameters(varargin)
    global TP
    
    %% LOG MSG
    if nargin==0
        % called by button down: 	GUI_ScanParameters 
        tag = get(gcbo,'tag');
      	str = ['h = TP.UI.H.' tag ';'];
        eval(str);
        try
            tagmsg = get(h,'string');
        catch 
            tagmsg = get(get(h,'SelectedObject'),'string');
        end;
        msg = [datestr(now) '\tGUI_ScanParameters\t''',...
            tag ,''' is updated to ''',tagmsg,'''\r\n'];
        fprintf( TP.D.Sys.PC.hLog,   msg);
    else
        % called by general update:	GUI_ScanParameters(0)
        % do not have log msg output to the file
        msg = '';
    end;
    
    %% Update TP.D
    TP.D.Sys.AOD.FreqBW =   1e6 * str2double(get(TP.UI.H.hSys_AOD_FreqBW_Edit, 'string'));
    TP.D.Sys.AOD.FreqCF =   1e6 * str2double(get(TP.UI.H.hSys_AOD_FreqCF_Edit, 'string')); 
    % According to Scan.Mode, Change UI components availability, and TP.D
   	TP.D.Ses.Scan.Mode =    get(get(TP.UI.H.hSes_Scan_Mode_Rocker,'SelectedObject'),'string');         
    switch TP.D.Ses.Scan.Mode
        case '2D random';     
            TP.D.Ses.Scan.ModeNum = 1;
            TP.D.Ses.Image.NumSmplPerPixl = round(str2double(get(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit, 'string'))/2)*2;
            set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit,  'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG,	'String', '1');
            set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 	'enable', 'inactive',	'Foregroundcolor', TP.UI.C.FG,	'String', 'NaN');
            set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit, 'enable', 'on',       	'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit, 'enable', 'inactive',  	'Foregroundcolor', TP.UI.C.FG);
            TP.D.Ses.Image.NumUpdtPerVlme = round(str2double(get(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit, 'string')));
            TP.D.Ses.Image.NumVlmePerUpdt = 1/TP.D.Ses.Image.NumUpdtPerVlme;
        case '2D raster';    
            TP.D.Ses.Scan.ModeNum = 2;
            TP.D.Ses.Image.NumSmplPerPixl = round(str2double(get(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit, 'string'))/1)*1;
            set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit,  'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG,  'String', '1');
            set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 	'enable', 'inactive',	'Foregroundcolor', TP.UI.C.FG,	'String', 'NaN');
            set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit,	'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG);
            set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit,	'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            TP.D.Ses.Image.NumVlmePerUpdt = round(str2double(get(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit, 'string')));
            TP.D.Ses.Image.NumUpdtPerVlme = 1/TP.D.Ses.Image.NumVlmePerUpdt;
      	case '3D raster';    
            TP.D.Ses.Scan.ModeNum = 3;
         	TP.D.Ses.Image.NumSmplPerPixl = round(str2double(get(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit, 'string'))/1)*1;
            set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit,  'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit,	'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit,	'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG);
            set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit, 'enable', 'inactive',  	'Foregroundcolor', TP.UI.C.FG);
            TP.D.Ses.Image.NumVlmePerUpdt = round(str2double(get(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit, 'string')));
            TP.D.Ses.Image.NumUpdtPerVlme = 1/TP.D.Ses.Image.NumVlmePerUpdt;
        otherwise
    end;   
    % Change Scan.Mode Button Color
    h = get(TP.UI.H.hSes_Scan_Mode_Rocker, 'children');
    for i = 1:3
        if i ==TP.D.Ses.Scan.ModeNum; 	set(h(4-i), 'backgroundcolor', TP.UI.C.SelectB);
        else                            set(h(4-i), 'backgroundcolor', TP.UI.C.TextBG);    end;
    end;     	
    % Update rounded TP.D
    TP.D.Ses.Scan.NumSmplPerPixl =  TP.D.Ses.Image.NumSmplPerPixl * TP.D.Sys.NI.Task_DO_6536_SR / TP.D.Sys.NI.Task_AI_6115_SR;          
    TP.D.Ses.Scan.NumPixlPerAxis =  round(str2double(get(TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit, 'string')));
    TP.D.Ses.Scan.NumLayrPerVlme =  round(str2double(get(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit, 'string'))/2)*2-1;  % must be odd number 2->1
    TP.D.Ses.Scan.LayrSpacingInZ =  round(str2double(get(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 'string')));

    TP.D.Ses.Scan.NumSmplPerVlme =  NaN;
    TP.D.Ses.Scan.VolumeRate =      NaN;
    TP.D.Ses.Scan.VolumeTime =      NaN;
    TP.D.Ses.Image.NumPixlPerUpdt = NaN;                                        
    TP.D.Ses.Image.NumSmplPerUpdt = NaN;
    TP.D.Ses.Image.UpdateRate =     NaN;
    TP.D.Ses.Image.UpdateTime =     NaN;    
    
    %% Update GUI
 	set(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit,	'string', num2str(TP.D.Ses.Image.NumSmplPerPixl));
    set(TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit, 	'string', num2str(TP.D.Ses.Scan.NumPixlPerAxis));
   	set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit, 	'string', num2str(TP.D.Ses.Scan.NumLayrPerVlme));
   	set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 	'string', num2str(TP.D.Ses.Scan.LayrSpacingInZ));
  	set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit,	'string', num2str(TP.D.Ses.Image.NumUpdtPerVlme));
    set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit,	'string', num2str(TP.D.Ses.Image.NumVlmePerUpdt));    

    set(TP.UI.H.hSes_Scan_VolumeRate_Edit,	'string',   sprintf('%5.2f',TP.D.Ses.Scan.VolumeRate));
  	set(TP.UI.H.hSes_Scan_VolumeTime_Edit,  'string',   sprintf('%5.7f',TP.D.Ses.Scan.VolumeTime));
  	set(TP.UI.H.hSes_Image_UpdateRate_Edit,	'string',   sprintf('%5.2f',TP.D.Ses.Image.UpdateRate));
  	set(TP.UI.H.hSes_Image_UpdateTime_Edit, 'string',   sprintf('%5.7f',TP.D.Ses.Image.UpdateTime));

    %% Uncommit the session
    TP.D.Ses.Committed =            0;
    h = get(TP.UI.H.hSes_Commit_Rocker, 'children');
    set(TP.UI.H.hSes_Commit_Rocker, 'SelectedObject',   h(2));
    set(h(2),	'backgroundcolor',  TP.UI.C.SelectB);
    set(h(3), 	'backgroundcolor',  TP.UI.C.TextBG);    
    h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'children');
    set(h(2),   'enable',           'inactive');

%% GUI updates w/ NI-DAQ modifications
function msg = GUI_SesCommit
    global TP
    global Trl
    %% Generate ScanSeq and ScanLUT, update NumSmplPerUpdt6115 and VolumeRate 
 	[TP.D.Ses.Scan.ScanSeq, TP.D.Ses.Scan.ScanInd] = feval(...
        TP.D.Ses.Scan.GenFunc, ...
        TP.D.Ses.Scan.NumSmplPerPixl,	TP.D.Ses.Image.NumSmplPerPixl, ...
    	TP.D.Ses.Scan.NumPixlPerAxis, ...
		TP.D.Ses.Scan.NumLayrPerVlme,	TP.D.Ses.Scan.LayrSpacingInZ, ...
        TP.D.Sys.AOD.FreqCF,            TP.D.Sys.AOD.FreqBW );
    
    % Volume 
    TP.D.Ses.Scan.NumSmplPerVlme =  length(TP.D.Ses.Scan.ScanSeq);
    TP.D.Ses.Scan.VolumeRate = TP.D.Sys.NI.Task_DO_6536_SR / TP.D.Ses.Scan.NumSmplPerVlme;
    TP.D.Ses.Scan.VolumeTime = TP.D.Ses.Scan.NumSmplPerVlme / TP.D.Sys.NI.Task_DO_6536_SR;
    set(TP.UI.H.hSes_Scan_VolumeRate_Edit,	'string',   sprintf('%5.2f',TP.D.Ses.Scan.VolumeRate));
  	set(TP.UI.H.hSes_Scan_VolumeTime_Edit,  'string',   sprintf('%5.7f',TP.D.Ses.Scan.VolumeTime));
 
  	% Update
    TP.D.Ses.Image.NumPixlPerUpdt = TP.D.Ses.Scan.NumSmplPerVlme / TP.D.Ses.Scan.NumSmplPerPixl / TP.D.Ses.Image.NumUpdtPerVlme;                                    
    TP.D.Ses.Image.NumSmplPerUpdt = TP.D.Ses.Image.NumSmplPerPixl * TP.D.Ses.Image.NumPixlPerUpdt;
    TP.D.Ses.Image.UpdateRate = TP.D.Sys.NI.Task_AI_6115_SR / TP.D.Ses.Image.NumSmplPerUpdt;
    TP.D.Ses.Image.UpdateTime = TP.D.Ses.Image.NumSmplPerUpdt / TP.D.Sys.NI.Task_AI_6115_SR;
  	set(TP.UI.H.hSes_Image_UpdateRate_Edit,	'string',   sprintf('%5.2f',TP.D.Ses.Image.UpdateRate));
  	set(TP.UI.H.hSes_Image_UpdateTime_Edit, 'string',   sprintf('%5.7f',TP.D.Ses.Image.UpdateTime));

    %% NI-DAQ unreserved
    try TP.HW.NI.T.hTask_DO_6536.control('DAQmx_Val_Task_Unreserve');   catch;	end;
    try TP.HW.NI.T.hTask_AI_6115.control('DAQmx_Val_Task_Unreserve');   catch;  end;
    
    %% Allocate Memories
	if TP.D.Ses.Image.Enable     
        % Allocate Memory
        Vmax = floor( TP.D.Trl.Tmax4GB * TP.D.Ses.Scan.VolumeRate);
        SetupImageD;    % Setup TP.D.Vol        
        % Display Image
        TP.UI.H0.hImage = image(...
                TP.D.Vol.LayerDisp{ (TP.D.Ses.Scan.NumLayrPerVlme+1)/2 },...
                'parent',           TP.UI.H0.hAxesImage);
        axis off image; box on;         
    else
    	Vmax = 0;
	end;    
        TP.D.Trl.VS.TimeStampUpdt =             zeros(Vmax,1);
        TP.D.Trl.VS.PMT_PMTctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_FANctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_PELctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_StatusLED =             false(Vmax,5);
        TP.D.Trl.VS.PMT_CtrlGainValue =         zeros(Vmax,1);
        TP.D.Trl.VS.PMT_MontGainValue =         zeros(Vmax,1);
        TP.D.Trl.VS.PMT_MontGainNoise =         zeros(Vmax,1);
        TP.D.Trl.VS.Power_AOD_CtrlAmpValue =	zeros(Vmax,1);
        TP.D.Trl.VS.Power_AOD_MontAmpValue =    zeros(Vmax,2);
        TP.D.Trl.VS.Power_AOD_MontAmpNoise =    zeros(Vmax,2);
        TP.D.Trl.VS.Power_PmeasuredS121C =      zeros(Vmax,1);
        TP.D.Trl.VS.Power_PinferredAtCtx =      zeros(Vmax,1);
    Trl = TP.D.Trl;
    
    %% Save Session Data, and Leave TimeStampTag for later Trls
	TP.D.Ses.Committed =            1;
    TP.D.Ses.TimeStampCommitted =   datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF');
    % this save along takes 1.27s on T5810 @2015/1/4
    save([TP.D.Sys.PC.Data_Dir, datestr(TP.D.Ses.TimeStampCommitted,30),'_Ses.mat'],...
        '-struct','TP','D');
        
    %% NI-DAQ committed    
    % hTask_DO_6536
    TP.HW.NI.T.hTask_DO_6536.cfgSampClkTiming(...
        TP.D.Sys.NI.Task_DO_6536_SR,    'DAQmx_Val_ContSamps',  TP.D.Ses.Scan.NumSmplPerVlme);
    TP.HW.NI.T.hTask_DO_6536.set(...
        'sampClkTimebaseRate',          TP.D.Sys.NI.Sys_TimingRate,...
        'sampClkTimebaseSrc',           TP.D.Sys.NI.Sys_TimingBridge{2});  
    TP.HW.NI.T.hTask_DO_6536.cfgDigEdgeStartTrig(...
        TP.D.Sys.NI.Sys_TrigBridge{2},  'DAQmx_Val_Rising');
    TP.HW.NI.T.hTask_DO_6536.writeDigitalData(TP.D.Ses.Scan.ScanSeq);
        
    % hTask_AI_6115
    TP.HW.NI.T.hTask_AI_6115.cfgSampClkTiming(...
        TP.D.Sys.NI.Task_AI_6115_SR,    'DAQmx_Val_ContSamps',  TP.D.Ses.Image.NumSmplPerUpdt*8);
    TP.HW.NI.T.hTask_AI_6115.cfgDigEdgeStartTrig(...
        TP.D.Sys.NI.Sys_TrigBridge{2},  'DAQmx_Val_Rising');
    TP.HW.NI.T.hTask_AI_6115.registerEveryNSamplesEvent(...
        @updateScanKeeper,              TP.D.Ses.Image.NumSmplPerUpdt,...
        true,                           'native');
    
    %% Session Committed & GUI update & "Start" Enabled
    h = get(TP.UI.H.hSes_Commit_Rocker, 'children');
    set(TP.UI.H.hSes_Commit_Rocker, 'SelectedObject',   h(3));
    set(h(3),	'backgroundcolor',  TP.UI.C.SelectB);
    set(h(2),  	'backgroundcolor',  TP.UI.C.TextBG);
    h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'children');
    set(h(2),   'enable',           'on');
  	
    %% MSG LOG
    msg = [datestr(now) '\tGUI_SesCommit\tSession is committed\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);         
    
function msg = GUI_ScanScheme(varargin)
    global TP;

  	%% where the call is from
    h = get(TP.UI.H.hTrl_ScanScheme_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            GUI_ScanScheme    
        ScanSchemeNum = get(get(TP.UI.H.hTrl_ScanScheme_Rocker,'SelectedObject'),'UserData');
                TP.D.Trl.ScanSchemeNum = ScanSchemeNum;
    else
        % called by general update: GUI_ScanScheme(ScanScheme),
        % ScanScheme =  1,          0,          -1
        %               'FOCUS i',  'GRAB i',   'LOOP e'
        ScanSchemeNum = varargin{1}; 
        switch ScanSchemeNum
            case 1;	set(TP.UI.H.hTrl_ScanScheme_Rocker, 'SelectedObject', h(3));
            case 0;	set(TP.UI.H.hTrl_ScanScheme_Rocker, 'SelectedObject', h(2));
          	case -1;set(TP.UI.H.hTrl_ScanScheme_Rocker, 'SelectedObject', h(1));
           	otherwise;
        end;
    end;
    % exclusive selection
    for i = 1:3
        if i==ScanSchemeNum+2;  set(h(i),   'backgroundcolor', TP.UI.C.SelectB);
        else                    set(h(i),   'backgroundcolor', TP.UI.C.TextBG);	end;
    end;
    
    %% update TP.D, and Tmax_Edit, Start/Stop, Sound Loading on GUI 
    h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
    switch ScanSchemeNum
        case 1
            % set(H.hImage_LengthT_Edit
            TP.D.Trl.ScanScheme =   'FOCUS';
            TP.D.Trl.ScanTrigType = 'internal';
            TP.D.Trl.Tmax =         TP.D.Trl.TmaxFocusDefault;
            set(TP.UI.H.hTrl_Tmax_Edit,             'enable',           'inactive',...
                                                    'Foregroundcolor',  TP.UI.C.FG);
            set(TP.UI.H.hTrl_LoadSound_Momentary,   'enable',           'inactive');
            set(h(2),                               'enable',           'on');
        case 0
            TP.D.Trl.ScanScheme =   'GRAB';
            TP.D.Trl.ScanTrigType = 'internal';
            TP.D.Trl.Tmax =         TP.D.Trl.TmaxGrabDefault;
            set(TP.UI.H.hTrl_Tmax_Edit,             'enable',           'on',...
                                                    'Foregroundcolor',  TP.UI.C.SelectT);
            set(TP.UI.H.hTrl_LoadSound_Momentary,   'enable',           'on');
            set(h(2),                               'enable',           'inactive');
        case -1            
            TP.D.Trl.ScanScheme =   'LOOP';
            TP.D.Trl.ScanTrigType = 'external';            
            TP.D.Trl.Tmax =         TP.D.Trl.TmaxLoopDefault;
            set(TP.UI.H.hTrl_Tmax_Edit,             'enable',           'on',...
                                                    'Foregroundcolor',  TP.UI.C.SelectT);
            set(TP.UI.H.hTrl_LoadSound_Momentary,   'enable',           'inactive');
            set(h(2),                               'enable',           'on');
    end;
    set(TP.UI.H.hTrl_Tmax_Edit, 'string', sprintf('%5.1f',TP.D.Trl.Tmax));
    
    %% NI-DAQ Trigger line connection
    switch TP.D.Trl.ScanTrigType
        case 'internal'
%             TP.HW.NI.T.hTask_CO_IntTrig.start();
%             pause(0.01);
%             TP.HW.NI.T.hTask_CO_IntTrig.stop();            
            % Connect the Internal trigger line to the trigger bridge
            TP.HW.NI.hSys.connectTerms(...
                ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigInternalSrc{2}],...
                ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigBridge{2}]);
        case 'external'
            % Disconnect the Internal trigger line from the trigger bridge
            try
            TP.HW.NI.hSys.disconnectTerms(...
                ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigInternalSrc{2}],...
                ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigBridge{2}]);
            catch
            end
        otherwise
    end;  
    
  	%% MSG LOG
    msg = [datestr(now) '\tGUI_ScanScheme\tScanScheme is selected as ''',...
        TP.D.Trl.ScanScheme, ''' and Start Trigger as ''', TP.D.Trl.ScanTrigType ,'''\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);     

%% Trl/Mon GUI updates w/o touching NI-DAQ
function msg = GUI_Tmax(varargin)
    global TP;

  	%% where the call is from
    if nargin==0
        % called by GUI:            GUI_Tmax    
        Tmax = str2double(get(gcbo,'string'));
    else
        % called by general update: GUI_Tmax(seconds)   
        Tmax = varargin{1};
    end;
    TP.D.Trl.Tmax = ceil((Tmax)*10)/10;    
    set(TP.UI.H.hTrl_Tmax_Edit, 'string', sprintf('%5.1f',TP.D.Trl.Tmax));
    
  	%% MSG LOG
    msg = [datestr(now) '\tGUI_Tmax\tTmax is adjusted to ',...
        num2str(TP.D.Trl.Tmax),' seconds\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);  
    
function msg = GUI_ImageDataLogging(varargin)
    global TP;
    %% Where the Call is from
	h = get(TP.UI.H.hTrl_DataLogging_Rocker, 'Children');    
    if nargin ==0
        % called by GUI:            GUI_ImageDataLogging
        TP.D.Trl.DataLogging = ...
            get(get(TP.UI.H.hTrl_DataLogging_Rocker,'SelectedObject'),'userdata');
    else
        % called by general update: GUI_ImageDataLogging(1) or 0
        TP.D.Trl.DataLogging = varargin{1};
    end;
	switch TP.D.Trl.DataLogging
        case 1
            set(TP.UI.H.hTrl_DataLogging_Rocker, 'SelectedObject', h(3));
            set(h(3),   'backgroundcolor', TP.UI.C.SelectB);
            set(h(2),   'backgroundcolor', TP.UI.C.TextBG);
        case 0
            set(TP.UI.H.hTrl_DataLogging_Rocker, 'SelectedObject', h(2));
            set(h(2),   'backgroundcolor', TP.UI.C.SelectB);
            set(h(3),   'backgroundcolor', TP.UI.C.TextBG);
        otherwise
	end;   
    
	%% MSG LOG
    msg = [datestr(now) '\tGUI_ImageDataLogging\tImage Data Logging selected as ''',...
        TP.D.Trl.DataLogging, '''\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);
    
function msg = GUI_ImageDisplayEnable(varargin)
    global TP;
    %% Where the Call is from
	h = get(TP.UI.H.hMon_Image_DisplayEnable_Toggle, 'Children');    
    if nargin ==0
        % called by GUI:            GUI_ImageDisplayMode
        TP.D.Mon.Image.DisplayEnable = ...
            get(get(TP.UI.H.hMon_Image_DisplayEnable_Toggle, 'SelectedObject'), 'userdata');
    else
        % called by general update: GUI_ImageDisplayMode(1) or 0
        TP.D.Mon.Image.DisplayEnable = varargin{1};
    end;
    switch TP.D.Mon.Image.DisplayEnable
        case 1
            set(TP.UI.H.hMon_Image_DisplayEnable_Toggle, 'SelectedObject', h(3));
            set(h(3),   'backgroundcolor', TP.UI.C.SelectB);
            set(h(2),   'backgroundcolor', TP.UI.C.TextBG);
        case 0
            set(TP.UI.H.hMon_Image_DisplayEnable_Toggle, 'SelectedObject', h(2));
          	set(h(2),   'backgroundcolor', TP.UI.C.SelectB);
          	set(h(3),   'backgroundcolor', TP.UI.C.TextBG);
        otherwise
    end;     
	%% MSG LOG
    msg = [datestr(now) '\tGUI_ImageDisplayEnable\tImage Display Enable selected as ''',...
        TP.D.Mon.Image.DisplayEnable, '''\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);   
        
function msg = GUI_ImageDisplayMode(varargin)
    global TP;
    %% Where the Call is from
	h = get(TP.UI.H.hMon_Image_DisplayMode_Toggle, 'Children');    
    if nargin ==0
        % called by GUI:            GUI_ImageDisplayMode
        TP.D.Mon.Image.DisplayMode = ...
            get(get(TP.UI.H.hMon_Image_DisplayMode_Toggle, 'SelectedObject'), 'String');
    else
        % called by general update: GUI_ImageDisplayMode('Abs') or 'Rltv'
        TP.D.Mon.Image.DisplayMode = varargin{1};
    end;
    switch TP.D.Mon.Image.DisplayMode
        case 'Abs';     set(TP.UI.H.hMon_Image_DisplayMode_Toggle, 'SelectedObject', h(3));
                        set(h(3),   'backgroundcolor', TP.UI.C.SelectB);
                        set(h(2),   'backgroundcolor', TP.UI.C.TextBG);
                        TP.D.Mon.Image.DisplayModeNum = 1;
        case 'Rltv';    set(TP.UI.H.hMon_Image_DisplayMode_Toggle, 'SelectedObject', h(2));
                       	set(h(2),   'backgroundcolor', TP.UI.C.SelectB);
                      	set(h(3),   'backgroundcolor', TP.UI.C.TextBG);
                      	TP.D.Mon.Image.DisplayModeNum = 2;
        otherwise
    end;     
	%% MSG LOG
    msg = [datestr(now) '\tGUI_ImageDisplayMode\tImage Display Mode selected as ''',...
        TP.D.Mon.Image.DisplayMode, '''\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);     
       
%% GUI Inputs w/ Updating Housekeeing NI-DAQ Tasks 
function msg = GUI_AO_6115(varargin)
    global TP;
    
   	%% get the numbers
    if nargin==0
        % called by GUI:            GUI_AO_6115 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider'
                AO1 = get(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,'value');
                AO2 = get(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,'value');
            case 'edit'
                AO1 = str2double(get(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,'string'));
                AO2 = str2double(get(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,'string'));
            otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_AO_6115([AO1 AO2])
        AO = varargin{1};   AO1 = AO(1);    AO2 = AO(2);
    end;
    
    %% prepare numbers as x.xx Volts
    AO1 = round(AO1*100)/100;
    AO2 = round(AO2*100)/100;  
    
    %% whether it's out of the range, then output
    if      AO1 >= TP.D.Sys.PMT.CtrlGainRange(1)...
        &&  AO1 <= TP.D.Sys.PMT.CtrlGainRange(2)...
        &&  AO2 >= TP.D.Sys.Power.AOD_CtrlAmpRange(1)...
        &&  AO2 <= TP.D.Sys.Power.AOD_CtrlAmpRange(2)   
    
        TP.D.Mon.PMT.CtrlGainValue =        AO1;
        TP.D.Mon.Power.AOD_CtrlAmpValue =   AO2;
        TP.HW.NI.T.hTask_AO_6115.writeAnalogData(...
            [AO1 AO2*   (TP.D.Trl.StartTrigStop==2)]);
                        % 0 = Stop: Only update PMT_Gain. 
                        % 1 = Start: Only update PMT_Gain
                        % 2 = Triggered: update both PMT_Gain and AOD_Amp
        %% MSG LOG
        msg = [datestr(now) '\tGUI_AO_6115\tAO_6115 is updated to ''',...
            num2str(AO1),', ',num2str(AO2),''' Volt\r\n'];
        fprintf( TP.D.Sys.PC.hLog,   msg);        
    else
        errordlg('Analog output level is out of range');
        AO1 = TP.D.Mon.PMT.CtrlGainValue;
        AO2 = TP.D.Mon.Power.AOD_CtrlAmpValue;  
    end;
    %% update GUI
    set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,         'value',AO1);
    set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,	'value',AO2);
    set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,       'string',sprintf('%1.2f',AO1));       
    set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,	'string',sprintf('%1.2f',AO2));
    
function msg = GUI_DO_6115(varargin)
    global TP
    
  	%% where the call is from
    
  	h{1} = get(TP.UI.H.hMon_PMT_PMTctrl_Rocker, 'Children');        
	h{2} = get(TP.UI.H.hMon_PMT_FANctrl_Toggle, 'Children');        
  	h{3} = get(TP.UI.H.hMon_PMT_PELctrl_Toggle, 'Children');
    if nargin==0
        % called by GUI:            GUI_DO_6115 
      	% read values from the UI Control Panel
        DO = [ 	get(get(TP.UI.H.hMon_PMT_PMTctrl_Rocker,'SelectedObject'),'UserData');...                  
                get(get(TP.UI.H.hMon_PMT_FANctrl_Toggle,'SelectedObject'),'UserData');... 
                get(get(TP.UI.H.hMon_PMT_PELctrl_Toggle,'SelectedObject'),'UserData')...
                               ]>0;
    else
        % called by general update:	GUI_DO_6115([PMTctrl; FANctrl; PELctrl])
        DO = logical(varargin{1}); 
        % update GUI
        set(TP.UI.H.hMon_PMT_PMTctrl_Rocker, 'SelectedObject', h{1}(DO(1)+2));
        set(TP.UI.H.hMon_PMT_FANctrl_Toggle, 'SelectedObject', h{2}(DO(2)+2));
        set(TP.UI.H.hMon_PMT_PELctrl_Toggle, 'SelectedObject', h{3}(DO(3)+2));
    end;
    %% update TP.D
    for i = 1:length(TP.D.Sys.NI.Chan_DO_PMT_Switch{3})
    	eval(['PMT_Ctrl(i,1)=logical(', TP.D.Sys.NI.Chan_DO_PMT_Switch{3}{i},');']);
    end 
    %% Write Data to the Task
    TP.HW.NI.T.hTask_DO_6115.writeDigitalData(DO);
    %% Change color
    for i = 1:3
        for j = 2:3
            if j ==DO(i)+2  set(h{i}(j),    'backgroundcolor', TP.UI.C.SelectB);
            else         	set(h{i}(j),    'backgroundcolor', TP.UI.C.TextBG);    end;
        end;
    end; 
    %% MSG LOG
    msg = [datestr(now) '\tGUI_DO_6115\tDO_6115 is updated to [',...
        num2str(DO'),']\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);       

function msg = GUI_PowerHWP(varargin)
    global TP;
    
   	%% get the numbers
    if nargin==0
        % called by GUI:            GUI_PowerHWP 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider'
                angle = get(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'value');
            case 'edit'
                angle = str2double(get(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,'string'));            otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        angle = varargin{1};
    end;
    
    %% prepare numbers as xxx.x Angles and 0 < angle < 90
    angle = mod(angle, 360);
    angle = round(angle*10)/10;
    
    %% update GUI & temporarily inactivate them
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'value',	angle);
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'enable',	'inactive');
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'string',   sprintf('%5.1f',angle)); 
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'enable',	'inactive');    
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'Foregroundcolor', TP.UI.C.FG);
    
    %% do motors and check, update angles
    updatePowerRotMove( TP.HW.Thorlabs.hPRM1Z8,	angle,  40);
    updatePowerRotCheck(TP.HW.Thorlabs.hPRM1Z8,	angle,  0.003);
    
    %% update GUI & reactivate them
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'enable',	'on');
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'enable',	'on'); 
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'Foregroundcolor', TP.UI.C.SelectT);
    
    %% MSG LOG
    msg = [datestr(now), '\tGUI_PowerHWP\tHWP Motor is updated to ',...
        sprintf('%5.1f',angle), ' Degree.\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);        

function msg = GUI_PowerMax(varargin)
    global TP;

  	%% where the call is from
    if nargin==0
        % called by GUI:            GUI_PowerMax    
        Pmax = str2double(get(gcbo,'string'));
    else
        % called by general update: GUI_PowerMax(128)   
        Pmax = varargin{1};
    end;
    TP.D.Mon.Power.PmaxCtxAllowed = min(round(Pmax), 300);
    set(TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit,...
        'string',   sprintf('%5.1f',   TP.D.Mon.Power.PmaxCtxAllowed));
    
  	%% MSG LOG
    msg = [datestr(now) '\tGUI_PowerMax\tPowerMax is adjusted to ',...
        num2str(TP.D.Mon.Power.PmaxCtxAllowed),' mW\r\n'];
    fprintf( TP.D.Sys.PC.hLog,   msg);      
    
%% GUI Inputs w/ SCAN & IMAGE Tasks    
function msg = GUI_ScanStartTrigStop(varargin)
    global TP;
    
    %% Where the Call is from
    if nargin ==0
        % called by GUI:            GUI_ScanStartTrigStop
        StartTrigStop = get(get(TP.UI.H.hTrl_StartTrigStop_Rocker,'SelectedObject'),'String');
    else
        % called by general update: GUI_ScanStartTrigStop('Start') or 'Stop'
        StartTrigStop = varargin{1};
    end;
    
    %% Controlling the UI &  Start or Stop
        
 	switch StartTrigStop
      	case 'Start';  
            h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
            set(TP.UI.H.hTrl_StartTrigStop_Rocker, 'SelectedObject', h(2));
            % GUI Exclusive StartTrigStop Selection
            msg = scanStarted; 
      	case 'Stop';               
        	h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
            set(TP.UI.H.hTrl_StartTrigStop_Rocker, 'SelectedObject', h(1));            
            % GUI Exclusive StartTrigStop Selection
            % This part is called by
            %   (1) GUI press 'Stop'
            %   (2) GUI_ScanStartTrigStop('Stop')
            % These two are functionally identical, and different from 
            % externally triggered stop in scanStopped
            msg = scanStopping;        
        case 'Trig'
            % Theoretically not available     
        otherwise
	end;
	%% MSG LOG
    fprintf( TP.D.Sys.PC.hLog, msg);  
       
function GUI_CleanUp
    global TP
    
    choice = questdlg (...
        'Stop & Clean Up Everything?',...
        'Clean Up',...
        'Yes, Clean Up', 'Do Nothing',...
        'Yes, Clean Up'...
        );
    switch choice
        case 'Yes, Clean Up'
            %% Reset Home Values
            try     
                GUI_AO_6115([0 0]);  
            catch
                warndlg('Can not reset NI AO values');
            end
            try     
                GUI_DO_6115([0; 1; 1]); 
            catch
                warndlg('Can not reset NI DO values','Close up error');
            end
            pause(0.5);

            %% Stop & Delete NI-DAQ tasks
            try
                TaskNames = fieldnames(TP.HW.NI.T);
                for i = 1:length(TaskNames)
                    TaskName = strcat('TP.HW.NI.T.',TaskNames{i});
                    eval(strcat('try;',TaskName,'.abort(); end;'));
                    eval(strcat('try;',TaskName,'.delete(); end;'));
                end;
            catch
                warndlg('Can not delete NI-DAQ tasks');
            end;

            %% Stop & Delete Thorlabs Power Meters
            try 
                for i =1:size(TP.D.Sys.Power.Meter.ID,1)                    
                    fprintf(    TP.HW.Thorlabs.PM100{i}.h,'*RST');
                    fclose(     TP.HW.Thorlabs.PM100{i}.h);
                end;
            catch
                warndlg('Can not close Thorlabs Power Meters');
            end

            %% Stop & Delete Thorlabs Motors
            try 
                % Move the PRM1Z8 Motor back to 0
                GUI_PowerHWP(0);
%                 updatePowerRotMove(	TP.HW.Thorlabs.hPRM1Z8, 0,  40);
                updatePowerRotCheck(TP.HW.Thorlabs.hPRM1Z8, 0,  0.003);
                delete(TP.UI.H0.hFigPRM1Z8);
            catch
                warndlg('The PRM1Z8 Motor may not return to the Home position');
            end            

            %% MSG LOG and close log file
            try
                msg = [datestr(now) '\t' TP.D.Sys.Name '\tProgram Closed, Two Photon ROCKS! \r\n'];
                fprintf( TP.D.Sys.PC.hLog, msg);
                fclose(  TP.D.Sys.PC.hLog);
            catch
                warndlg('Can not write log file');
            end;

            %% Clean Up Figure and Data
            try
                delete(TP.UI.H0.hFigTP);
            catch
                warndlg('Can not delete the UI Figure');
            end;
            clear all;
        case 'Do Nothing'
        otherwise
    end;
