function varargout = SetupWideField(varargin)
% Flexible And Nimble Two-photon AOD Scanning In vivo imAging
% The Exporter code for exporting raw data into TIFF pictures or videos

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

%% CLEAN AND RECREATE THE WORKSPACE
clc;
% clear all
global TP
global CameraD

TP.WF.Name =            mfilename;
try 
    info = imaqhwinfo('pointgrey',1);
    switch info.DeviceName
        case 'Chameleon CMLN-13S2C';
            CameraD.Mode =                  'F7_BayerGB8_1296x964_mode0';
            CameraD.Brightness_Range =      [0.00   6.24];
            CameraD.Brightness_Default =    0;
            CameraD.Exposure_Range =        [-7.58  2.41];
            CameraD.Exposure_Default =      1.7549;
            CameraD.Exposure_Mode =         'Auto';
            CameraD.Gain_Range =            [-5.63  24.00];
            CameraD.Gain_Default =          0.52805;
            CameraD.Gain_Mode =             'Auto';
            CameraD.Shutter_Range =         [0.01   55.57];
            CameraD.Shutter_Default =       14.07;
            CameraD.Shutter_Mode =          'Auto';
			CameraD.WhiteBalanceRB_Range =	[0 1024];
			CameraD.WhiteBalanceRB_Default =[550 810];
            CameraD.WhiteBalanceRB_Mode =   'Auto';
            CameraD.Image.cData =           zeros(964, 1296, 3);
        case 'Flea3 FL3-U3-88S2C';
            CameraD.Mode =                  'F7_BayerRG8_4096x2160_Mode0';
            CameraD.Brightness_Range =      [0.00   24.90];
            CameraD.Brightness_Default =    4.8828;
            CameraD.Exposure_Range =        [-7.58  2.41];
            CameraD.Exposure_Default =      1.415;
            CameraD.Exposure_Mode =         'Auto';
            CameraD.Gain_Range =            [0.00   24.08];
            CameraD.Gain_Default =          0;
            CameraD.Gain_Mode =             'Auto';
            CameraD.Shutter_Range =         [0.02   47.57];
            CameraD.Shutter_Default =       45.4111;
            CameraD.Shutter_Mode =          'Auto';
			CameraD.WhiteBalanceRB_Range =	[-2.013e+09 4.69e+08];
			CameraD.WhiteBalanceRB_Default =[4.69e+08 -2.013e+09];
            CameraD.WhiteBalanceRB_Mode =   'Auto';
            CameraD.Image.cData =           zeros(2160, 4096, 3);
        otherwise
            errordlg('Unrecognized Camera');
    end;
catch
            errordlg('No PointGrey Camera found');
end;

%             CameraD.FrameRatePerc_Range =   [1      100];
%             CameraD.FrameRatePerc_Default = 100;  
%             CameraD.FrameRatePerc_Mode =    'Auto';  

CameraD.Brightness =	CameraD.Brightness_Default;
CameraD.Exposure =		CameraD.Exposure_Default;
CameraD.Gain = 			CameraD.Gain_Default;
CameraD.Shutter = 		CameraD.Shutter_Default;
CameraD.WhiteBalanceRB =CameraD.WhiteBalanceRB_Default;

TP.HW.PC.hCameraVid =   videoinput('pointgrey', 1, CameraD.Mode);
TP.HW.PC.hCameraSrc =   getselectedsource(TP.HW.PC.hCameraVid);
TP.HW.PC.hCameraVid.FramesPerTrigger = 1;

SetupFigureCamera;

set(TP.WF.UI.H.hCamera_DefaultReset_Momentary,  'Callback',	[TP.WF.Name, '(''Camera_DefaultReset'')']);
set(TP.WF.UI.H.hCamera_Brightness_PotenSlider,  'Callback',	[TP.WF.Name, '(''Camera_Brightness'')']);
set(TP.WF.UI.H.hCamera_Brightness_PotenEdit,    'Callback',	[TP.WF.Name, '(''Camera_Brightness'')']);
set(TP.WF.UI.H.hCamera_Exposure_PotenSlider,    'Callback',	[TP.WF.Name, '(''Camera_Exposure'')']);
set(TP.WF.UI.H.hCamera_Exposure_PotenEdit,      'Callback',	[TP.WF.Name, '(''Camera_Exposure'')']);
set(TP.WF.UI.H.hCamera_Gain_PotenSlider,        'Callback',	[TP.WF.Name, '(''Camera_Gain'')']);
set(TP.WF.UI.H.hCamera_Gain_PotenEdit,          'Callback',	[TP.WF.Name, '(''Camera_Gain'')']);
set(TP.WF.UI.H.hCamera_Shutter_PotenSlider,     'Callback',	[TP.WF.Name, '(''Camera_Shutter'')']);
set(TP.WF.UI.H.hCamera_Shutter_PotenEdit,       'Callback',	[TP.WF.Name, '(''Camera_Shutter'')']);
set(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenSlider,'Callback',[TP.WF.Name, '(''Camera_WhiteBalanceR'')']);
set(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenEdit, 'Callback',	[TP.WF.Name, '(''Camera_WhiteBalanceR'')']);
set(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenSlider,'Callback',[TP.WF.Name, '(''Camera_WhiteBalanceB'')']);
set(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenEdit,	'Callback',	[TP.WF.Name, '(''Camera_WhiteBalanceB'')']);
set(TP.WF.UI.H.hCamera_ExposureMode_Rocker,	'SelectionChangeFcn',	[TP.WF.Name, '(''Camera_ExposureMode'')']);
set(TP.WF.UI.H.hCamera_GainMode_Rocker,    	'SelectionChangeFcn',	[TP.WF.Name, '(''Camera_GainMode'')']);
set(TP.WF.UI.H.hCamera_ShutterMode_Rocker,	'SelectionChangeFcn',	[TP.WF.Name, '(''Camera_ShutterMode'')']);
set(TP.WF.UI.H.hCamera_WhiteBalanceRB_Mode_Rocker,...
											'SelectionChangeFcn',	[TP.WF.Name, '(''Camera_WhiteBalanceRB_Mode'')'])
set(TP.WF.UI.H.hCamera_Preview_Rocker,     	'SelectionChangeFcn',	[TP.WF.Name, '(''Camera_Preview'')']);
set(TP.WF.UI.H0.hFigWF,                   	'CloseRequestFcn',      [TP.WF.Name,'(''Camera_CleanUp'')']);


function SetupFigureCamera
global TP
global CameraD

%% UI Color
S.Color.BG =        [   0       0       0];
S.Color.HL =        [   0       0       0];
S.Color.FG =        [   0.6     0.6     0.6];    
S.Color.TextBG =    [   0.25    0.25    0.25];
S.Color.SelectB =  	[   0       0       0.35];
S.Color.SelectT =  	[   0       0       0.35];

TP.WF.UI.C = S.Color;
TP.UI.C = S.Color;

%% UI Figure
    % Screen Scale 
    MonitorPositions =  get(0,'MonitorPositions');
    S.ScreenEnds = [    min(MonitorPositions(:,1)) min(MonitorPositions(:,2)) ...
                        max(MonitorPositions(:,3)) max(MonitorPositions(:,4))];
    S.ScreenWidth =     S.ScreenEnds(3) - S.ScreenEnds(1) +1;
    S.ScreenHeight =    S.ScreenEnds(4) - S.ScreenEnds(2) +1;
                                        
    % Figure scale
    S.FigSideTitleHeight = 30; 	
    S.FigSideWidth = 8; 
    S.FigSideToolbarWidth = 60;

    S.FigWidth =        S.ScreenWidth - 2*S.FigSideWidth - S.FigSideToolbarWidth;
    S.FigHeight =       S.ScreenHeight - S.FigSideTitleHeight - S.FigSideWidth;

    % create the UI figure 
    TP.WF.UI.H0.hFigWF = figure(...
        'Name',         'Point Grey Camera, Wide Field Imaging',...
        'NumberTitle',  'off',...
        'Resize',       'off',...
        'color',        S.Color.BG,...
        'position',     [   S.FigSideWidth,	S.FigSideWidth,...
                            S.FigWidth,     S.FigHeight],...
        'menubar','none');
  
%% UI ImagePanel
    % Global Spacer Scale
    S.SP = 10;          % Panelette Side Spacer
    S.SD = 4;           % Side Double Spacer
    S.S = 2;            % Small Spacer 
    S.PaneletteTitle = 18;

    % Image Scale
    S.AxesImageWidth =     2048;
    S.AxesImageHeight =    1080;

    % Image Panel Scale
    S.PanelImageWidth =     S.AxesImageWidth + 2*(S.SD);
    S.PanelImageHeight =    S.AxesImageHeight + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.SD;
    S.PanelCurrentH = S.SD;
    TP.WF.UI.H0.hPanelImage = uipanel(...
        'parent',           TP.WF.UI.H0.hFigWF,...
        'BackgroundColor',  S.Color.BG,...
        'Highlightcolor',   S.Color.HL,...
        'ForegroundColor',  S.Color.FG,...
        'units',            'pixels',...
        'Title',            'IMAGE PANEL',...
        'Position',         [   S.PanelCurrentW     S.PanelCurrentH     	...
                                S.PanelImageWidth	S.PanelImageHeight]);

        % create the Axes
        TP.WF.UI.H0.hAxesImage = axes(...
            'parent',       TP.WF.UI.H0.hPanelImage,...
            'units',        'pixels',...
            'Position',     [   0                   S.SD   ...              
                                S.AxesImageWidth    S.AxesImageWidth]);
        TP.WF.UI.H0.hImage = image(CameraD.Image.cData,...
            'parent',       TP.WF.UI.H0.hAxesImage);                            
                    
%% UI Control Panel
    % Panelette Scale
    S.PaneletteWidth = 100;         S.PaneletteHeight = 150;    
    S.PaneletteTitle = 18;

    % Panelette #
    S.PaneletteRowNum = 1;  S.PaneletteColumnNum = 14;
    
    % Control Panel Scale 
    S.PanelCtrlWidth =  S.PaneletteColumnNum *(S.PaneletteWidth+S.S) + 2*S.SD;
    S.PanelCtrlHeight = S.PaneletteRowNum *(S.PaneletteHeight+S.S) + S.PaneletteTitle;
    
    % create the Control Panel
    S.PanelCurrentW = S.PanelCurrentW+  S.SD;
    S.PanelCurrentH = S.PanelCurrentH+  S.PanelImageHeight+   S.SD;
    TP.WF.UI.H0.hPanelCtrl = uipanel(...
        'parent',               TP.WF.UI.H0.hFigWF,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units',                'pixels',...
        'Title',                'CAMERA CONTROL PANEL',...
        'Position',             [   S.PanelCurrentW     S.PanelCurrentH ...
                                    S.PanelCtrlWidth    S.PanelCtrlHeight]);

        % create rows of Empty Panelettes                      
        for i = 1:S.PaneletteRowNum
            for j = 1:S.PaneletteColumnNum
                TP.WF.UI.H0.Panelette{i,j}.hPanelette = uipanel(...
                'parent', TP.WF.UI.H0.hPanelCtrl,...
                'BackgroundColor', 	S.Color.BG,...
                'Highlightcolor',  	S.Color.HL,...
                'ForegroundColor',	S.Color.FG,...
                'units','pixels',...
                'Title', ' ',...
                'Position',[S.SD+(S.S+S.PaneletteWidth)*(j-1),...
                            S.SD+(S.S+S.PaneletteHeight)*(i-1),...
                            S.PaneletteWidth, S.PaneletteHeight]);
                        % edge is 2*S.S
            end;
        end;
        
%% UI Panelettes   
S.PnltCurrent.row = 1;      S.PnltCurrent.column = 1;

	WP.name = 'Default Reset';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Reset to defaults',...
                    ''};
        WP.tip = {[ 'Reset to defaults',''],...
                  [	'', '']  };
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_DefaultReset_Momentary = TP.WF.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        set(TP.WF.UI.H.hCamera_DefaultReset_Momentary, 'tag', 'hCamera_DefaultReset_Momentary');
        clear WP; 

    WP.name = 'Brightness';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =	{   ['Camera Brightness [', num2str(CameraD.Brightness_Range), '] %%']};
        WP.tip =	{   ['Camera Brightness [', num2str(CameraD.Brightness_Range), '] %%']};
        WP.inputValue =     CameraD.Brightness_Default;
        WP.inputRange =     CameraD.Brightness_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_Brightness_PotenSlider =	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_Brightness_PotenEdit =   TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;    
    
    WP.name = 'Exposure';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   ['Camera Exposure [', num2str(CameraD.Exposure_Range), '] EV']};
        WP.tip =    {   ['Camera Exposure [', num2str(CameraD.Exposure_Range), '] EV']};
        WP.inputValue =     CameraD.Exposure_Default;
        WP.inputRange =     CameraD.Exposure_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_Exposure_PotenSlider =	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_Exposure_PotenEdit =     TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
        
	WP.name = 'Exposure Mode';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Camera Exposure Mode'};
        WP.tip = {  'Camera Exposure Mode'};
        WP.inputOptions = {'Auto', 'Manual', 'Off'};
        WP.inputDefault = find( cellfun(@strcmp, WP.inputOptions, ...
            cellstr(repmat(CameraD.Exposure_Mode,3,1))' ) );
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_ExposureMode_Rocker =    TP.WF.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
  	WP.name = 'Gain';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   ['Camera Gain [', num2str(CameraD.Gain_Range), '] dB']};
        WP.tip =    {   ['Camera Gain [', num2str(CameraD.Gain_Range), '] dB']};
        WP.inputValue =     CameraD.Gain_Default;
        WP.inputRange =     CameraD.Gain_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_Gain_PotenSlider =       TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_Gain_PotenEdit =         TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;

	WP.name = 'Gain Mode';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Camera Gain Mode'};
        WP.tip = {  'Camera Gain Mode'};
        WP.inputOptions = {'Auto', 'Manual', ''};
        WP.inputDefault = find( cellfun(@strcmp, WP.inputOptions, ...
            cellstr(repmat(CameraD.Gain_Mode,3,1))' ) );
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_GainMode_Rocker =        TP.WF.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
	WP.name = 'Shutter';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   ['Camera Shutter [', num2str(CameraD.Shutter_Range), '] ms']};
        WP.tip =    {   ['Camera Shutter [', num2str(CameraD.Shutter_Range), '] ms']};
        WP.inputValue =     CameraD.Shutter_Default;
        WP.inputRange =     CameraD.Shutter_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_Shutter_PotenSlider = 	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_Shutter_PotenEdit =   	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;

	WP.name = 'Shutter Mode';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Camera Shutter Mode'};
        WP.tip = {  'Camera Shutter Mode'};
        WP.inputOptions = {'Auto', 'Manual', ''};
        WP.inputDefault = find( cellfun(@strcmp, WP.inputOptions, ...
            cellstr(repmat(CameraD.Shutter_Mode,3,1))' ) );
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_ShutterMode_Rocker =        TP.WF.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
	WP.name = 'WhiteBalance R';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   'WhiteBalance R'};
        WP.tip =    {   'WhiteBalance R'};
        WP.inputValue =     CameraD.WhiteBalanceRB_Default(1);
        WP.inputRange =     CameraD.WhiteBalanceRB_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_WhiteBalanceR_PotenSlider = 	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_WhiteBalanceR_PotenEdit =   	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
        
	WP.name = 'WhiteBalance B';
        WP.handleseed =	'TP.WF.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;   
        WP.text = 	{   'WhiteBalance B'};
        WP.tip =    {   'WhiteBalance B'};
        WP.inputValue =     CameraD.WhiteBalanceRB_Default(2);
        WP.inputRange =     CameraD.WhiteBalanceRB_Range;
        WP.inputSlideStep=  [0.01 0.1];
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_WhiteBalanceB_PotenSlider = 	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.WF.UI.H.hCamera_WhiteBalanceB_PotenEdit =   	TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;

	WP.name = 'WhiteBalanceMode';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'White Balance RB Mode'};
        WP.tip = {  'White Balance RBMode'};
        WP.inputOptions = {'Manual', 'Off', ''};
        WP.inputDefault = 1;
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_WhiteBalanceRB_Mode_Rocker =        TP.WF.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
	WP.name = 'Preview';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Preview'};
        WP.tip = {  'Preview'};
        WP.inputOptions = {'Preview', 'Stop', ''};
        WP.inputDefault = 2;
        Panelette(S, WP, 'TP');
        TP.WF.UI.H.hCamera_Preview_Rocker =             TP.WF.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP;
        
 	WP.name = 'Frame';
        WP.handleseed = 'TP.WF.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'Frame Average Brightness',...
                    'Frame Rate(Hz)'};
        WP.tip = {	'Frame Average Brightness',...
                    'Frame Rate(Hz)'};
        WP.inputValue = {   NaN,...
                            NaN};    
        WP.inputFormat = {'%4.2f','%4.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.WF.UI.H.hCamera_FrameAve_Edit =              TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.WF.UI.H.hCamera_FrameRate_Edit =            TP.WF.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.WF.UI.H.hCamera_FrameAve_Edit,	'tag', 'hCamera_FrameAve_Edit');
     	set(TP.WF.UI.H.hCamera_FrameRate_Edit,	'tag', 'hCamera_FrameRate_Edit');
        clear WP;
        
        
%% UI Hist Panel
%     % Image Scale
%     S.PanelHistAxesWidth = 410;
%     S.PanelHistAxesHeight = 200;
% 
%     % Image Panel Scale
%     S.PanelHistWidth =     S.PanelHistAxesWidth + 2*(S.SD);
%     S.PanelHistHeight =    S.PanelHistAxesHeight + 1*(S.SD) + S.PaneletteTitle;
% 
%     % create the Image Panel
%     S.PanelCurrentW = S.PanelCurrentW;
%     S.PanelCurrentH = S.PanelCurrentH + S.PanelCtrlHeight + S.SD;
%     TP.WF.UI.H0.hPanelHist = uipanel(...
%         'parent', TP.WF.UI.H0.hFigPI,...
%         'BackgroundColor',      S.Color.BG,...
%         'Highlightcolor',       S.Color.HL,...
%         'ForegroundColor',      S.Color.FG,...
%         'units','pixels',...
%         'Title', 'HISTOGRAM PANEL',...
%         'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
%                     S.PanelHistWidth	S.PanelHistHeight]);
%                         
%         % create the Axes:Hist
%         TP.WF.UI.H0.hAxesHist = axes(...
%             'parent', TP.WF.UI.H0.hPanelHist,...
%             'units', 'pixels', ...
%             'Position', [   25	35	380 170]);
%         
%             % prepare Histogram related Parameters
%             TP.D.Image.VolumeT.PixelHist = zeros(1,300);         % 300
%             TP.D.Image.VolumeT.PixelHistEdges =  -344:8:2048; 	% 300 bin 
%                 % N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1).  
%                 % The last bin will count any values of X that match EDGES(end)
%                	% -344~-337     is the 1    bin
%                 % 0~7           is the 44   bin
%                 % 2040-2047    	is the 299  bin
%                 % 2048          is the 300  bin
%                 % there are 256 +1 bin from 0-2048, match with the 8bit color
%         
%             % create the Histogram
%             TP.WF.UI.H0.Hist0.hBarHist  = ...
%                 bar(    (1:1:300)', TP.D.Image.VolumeT.PixelHist,...
%                         'parent', TP.WF.UI.H0.hAxesHist,...
%                         'FaceColor', [.5 .5 .5]);            
%             set(TP.WF.UI.H0.Hist0.hBarHist,...
%                 'Ydata', TP.D.Image.VolumeT.PixelHist);
%             
%         set(TP.WF.UI.H0.hAxesHist,...
%             'FontSize', 6,          'color',        S.Color.BG,...
%             'YTick',    [0 1],      'YTickLabel',   {'0'; 'peak'},...
%             'YLim',     [0 1.1],    'YColor',       S.Color.FG,...
%             'XTick',    [44 300],   'XTickLabel',   {'0'; 'max'},...
%             'XLim',     [1 380],    'XColor',       S.Color.FG,...
%             'NextPlot', 'add');
%             
%             % create Text:
%             text(305, 1.000, 'max', 'color', S.Color.FG, 'parent', TP.WF.UI.H0.hAxesHist);
%             text(305, 0.750, 'min', 'color', S.Color.FG, 'parent', TP.WF.UI.H0.hAxesHist);
%             text(305, 0.500, 'peak', 'color', S.Color.FG, 'parent', TP.WF.UI.H0.hAxesHist);
%             text(305, 0.250, 'mean', 'color', S.Color.FG, 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hTextMax = ...
%                 text(310, 0.875, 'MAX', 'color', [0 .5 0], 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hTextMin = ...
%                 text(310, 0.625, 'MIN', 'color', [0 .5 0], 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hTextPeak = ...
%                 text(310, 0.375, 'PEAK', 'color', [0 .5 0], 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hTextMean = ...
%                 text(310, 0.125, 'MEAN', 'color', [0 .5 0], 'parent', TP.WF.UI.H0.hAxesHist);
%             
%             % create Mark:
%             TP.WF.UI.H0.Hist0.hMarkMax = ...
%                 plot(44, 1.05, 'g.', 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hMarkMin = ...
%                 plot(44, 1.05, 'g.', 'parent', TP.WF.UI.H0.hAxesHist);
%             TP.WF.UI.H0.Hist0.hMarkPeak = ...
%                 plot(44, 1.05, 'g.', 'parent', TP.WF.UI.H0.hAxesHist);
%                     
%         % create the Axes:HistCM
%         TP.WF.UI.H0.hAxesHistCM = axes(...
%             'parent',   TP.WF.UI.H0.hPanelHist,...
%             'units',    'pixels',...
%             'Position', [25   2   300 20]);
% 
%             imagecontrast = zeros(20,300,3);
%             % 300 bins 
%             imagecontrast(:,44:end-1,2) = repmat(0:1/255:1,20,1);
%             imagecontrast(:,end,2)      = 1;
%             % 44-300 column, 256 +1
%             
%             imagesc(imagecontrast, 'parent', TP.WF.UI.H0.hAxesHistCM);
%     	set(TP.WF.UI.H0.hAxesHistCM, 'Ytick', [], 'Xtick', []);
%     updateImageHistogram(TP.WF.UI.H0.Hist0);
    
%% Turn the JAVA LookAndFeel Scheme on "Windows"
%     javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
  
function Camera_DefaultReset(varargin)
    global CameraD  
    
    % update CameraD
    CameraD.Brightness =        CameraD.Brightness_Default;
    CameraD.Exposure =          CameraD.Exposure_Default;
    CameraD.Exposure_Mode =     'Auto';
    CameraD.Gain =              CameraD.Gain_Default;
    CameraD.Gain_Mode =         'Auto';  
    CameraD.Shutter =           CameraD.Shutter_Default;
    CameraD.Shutter_Mode =      'Auto';
    CameraD.WhiteBalanceRB =    CameraD.WhiteBalanceRB_Default;
    
    % update GUI & Hardware through callbacks
    Camera_Brightness(      CameraD.Brightness);
    Camera_Exposure(        CameraD.Exposure);
    Camera_ExposureMode(    CameraD.Exposure_Mode);
    Camera_Gain(            CameraD.Gain);
    Camera_GainMode(        CameraD.Gain_Mode);
    Camera_Shutter(         CameraD.Shutter);
    Camera_ShutterMode(     CameraD.Shutter_Mode);
    Camera_WhiteBalanceR(   CameraD.WhiteBalanceRB(1));
    Camera_WhiteBalanceB(   CameraD.WhiteBalanceRB(2));
    
function Camera_Brightness(varargin)
    global TP
    global CameraD
	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  brightness = get(TP.WF.UI.H.hCamera_Brightness_PotenSlider, 'value');
            case 'edit';  	brightness = str2double(get(TP.WF.UI.H.hCamera_Brightness_PotenEdit,'string'));	otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        brightness = varargin{1};
    end;
    CameraD.Brightness =                brightness;
    TP.HW.PC.hCameraSrc.Brightness =    CameraD.Brightness;

    set(TP.WF.UI.H.hCamera_Brightness_PotenSlider,  'value',	CameraD.Brightness);    
    set(TP.WF.UI.H.hCamera_Brightness_PotenEdit,	'string',   sprintf('%5.2f', CameraD.Brightness));   

function Camera_Exposure(varargin)
    global TP
    global CameraD
	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  exposure = get(TP.WF.UI.H.hCamera_Exposure_PotenSlider, 'value');
            case 'edit';    exposure = str2double(get(TP.WF.UI.H.hCamera_Exposure_PotenEdit,'string'));	otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        exposure = varargin{1};
    end;
    CameraD.Exposure =              exposure;
    TP.HW.PC.hCameraSrc.Exposure =  exposure;

    set(TP.WF.UI.H.hCamera_Exposure_PotenSlider,	'value',	exposure);    
    set(TP.WF.UI.H.hCamera_Exposure_PotenEdit,      'string',   sprintf('%5.2f',exposure)); 
    
function Camera_ExposureMode(varargin)
    global TP;
    global CameraD;
  	%% where the call is from
    h = get(TP.WF.UI.H.hCamera_ExposureMode_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            Camera_ExposureMode
        cmdstr = get(get(TP.WF.UI.H.hCamera_ExposureMode_Rocker,'SelectedObject'),'string');
    else
        % called by general update: Camera_ExposureMode('Auto')'Manual''Off'
        cmdstr = varargin{1};
    end;
    switch cmdstr
        case 'Auto'
            selectnum = 3;
            TP.HW.PC.hCameraSrc.ExposureMode = 'Auto';
        case 'Manual'
            selectnum = 2;
            TP.HW.PC.hCameraSrc.ExposureMode = 'Manual';
        case 'Off'        
            selectnum = 1;
            TP.HW.PC.hCameraSrc.ExposureMode = 'Off';    
        otherwise
    end;
    % exclusive selection
    set(TP.WF.UI.H.hCamera_ExposureMode_Rocker, 'SelectedObject', h(selectnum)); 
    for i = 1:3
        if i==selectnum;    set(h(i),   'backgroundcolor', TP.WF.UI.C.SelectB);
        else                set(h(i),   'backgroundcolor', TP.WF.UI.C.TextBG);	end;
    end;

function Camera_Gain(varargin)
    global TP
    global CameraD
	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  gain = get(TP.WF.UI.H.hCamera_Gain_PotenSlider, 'value');
            case 'edit';    gain = str2double(get(TP.WF.UI.H.hCamera_Gain_PotenEdit,'string'));	otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        gain = varargin{1};
    end;
    CameraD.Gain =              gain;
    TP.HW.PC.hCameraSrc.Gain =	gain;

    set(TP.WF.UI.H.hCamera_Gain_PotenSlider,	'value',	gain);    
    set(TP.WF.UI.H.hCamera_Gain_PotenEdit,      'string',   sprintf('%5.2f',gain));

function Camera_GainMode(varargin)
    global TP;
    global CameraD;
  	%% where the call is from
    h = get(TP.WF.UI.H.hCamera_GainMode_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            Camera_GainMode
        cmdstr = get(get(TP.WF.UI.H.hCamera_GainMode_Rocker,'SelectedObject'),'string');
    else
        % called by general update: Camera_GainMode('Auto')'Manual''Off'
        cmdstr = varargin{1};
    end;
    switch cmdstr
        case 'Auto'
            selectnum = 3;
            TP.HW.PC.hCameraSrc.GainMode = 'Auto';
        case 'Manual'
            selectnum = 2;
            TP.HW.PC.hCameraSrc.GainMode = 'Manual';
        otherwise
    end;
    % exclusive selection
    set(TP.WF.UI.H.hCamera_GainMode_Rocker, 'SelectedObject', h(selectnum)); 
    for i = 1:3
        if i==selectnum;    set(h(i),   'backgroundcolor', TP.WF.UI.C.SelectB);
        else                set(h(i),   'backgroundcolor', TP.WF.UI.C.TextBG);	end;
    end;

function Camera_Shutter(varargin)
    global TP
    global CameraD
 	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  shutter = get(TP.WF.UI.H.hCamera_Shutter_PotenSlider, 'value');
            case 'edit';    shutter = str2double(get(TP.WF.UI.H.hCamera_Shutter_PotenEdit,'string'));	otherwise
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        shutter = varargin{1};
    end;
    CameraD.Shutter =           	shutter;
    TP.HW.PC.hCameraSrc.Shutter =	shutter;

    set(TP.WF.UI.H.hCamera_Shutter_PotenSlider,	'value',	shutter);    
    set(TP.WF.UI.H.hCamera_Shutter_PotenEdit, 	'string',   sprintf('%5.2f',shutter));

function Camera_ShutterMode(varargin)
    global TP;
    global CameraD;
  	%% where the call is from
    h = get(TP.WF.UI.H.hCamera_ShutterMode_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            Camera_ShutterMode
        cmdstr = get(get(TP.WF.UI.H.hCamera_ShutterMode_Rocker,'SelectedObject'),'string');
    else
        % called by general update: Camera_ShutterMode('Auto')'Manual''Off'
        cmdstr = varargin{1};
    end;
    switch cmdstr
        case 'Auto'
            selectnum = 3;
            TP.HW.PC.hCameraSrc.ShutterMode = 'Auto';
        case 'Manual'
            selectnum = 2;
            TP.HW.PC.hCameraSrc.ShutterMode = 'Manual';
        otherwise
    end;
    % exclusive selection
    set(TP.WF.UI.H.hCamera_ShutterMode_Rocker, 'SelectedObject', h(selectnum)); 
    for i = 1:3
        if i==selectnum;    set(h(i),   'backgroundcolor', TP.WF.UI.C.SelectB);
        else                set(h(i),   'backgroundcolor', TP.WF.UI.C.TextBG);	end;
    end;
    
function Camera_WhiteBalanceR(varargin)
    global TP
    global CameraD
 	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  wbr = get(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenSlider, 'value');
            case 'edit';    wbr = str2double(get(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenEdit,'string'));	otherwise;
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        wbr = varargin{1};
    end;
    CameraD.WhiteBalanceRB =                [wbr CameraD.WhiteBalanceRB(2)];
    TP.HW.PC.hCameraSrc.WhiteBalanceRB =	CameraD.WhiteBalanceRB;

    set(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenSlider,	'value',	wbr);    
    set(TP.WF.UI.H.hCamera_WhiteBalanceR_PotenEdit, 	'string',   sprintf('%d',wbr));
    
function Camera_WhiteBalanceB(varargin)
    global TP
    global CameraD
 	%% get the numbers
    if nargin==0
        % called by GUI: 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  wbb = get(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenSlider, 'value');
            case 'edit';    wbb = str2double(get(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenEdit,'string'));	otherwise;
                errordlg('What''s the hell is this?');
                return;
        end;
    else
        % called by general update:	GUI_PowerHWP(34.2)
        wbb = varargin{1};
    end;
    CameraD.WhiteBalanceRB =                [CameraD.WhiteBalanceRB(1) wbb];
    TP.HW.PC.hCameraSrc.WhiteBalanceRB =	CameraD.WhiteBalanceRB;

    set(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenSlider,	'value',	wbb);    
    set(TP.WF.UI.H.hCamera_WhiteBalanceB_PotenEdit, 	'string',   sprintf('%d',wbb));
    
function Camera_WhiteBalanceRB_Mode(varargin)
    global TP;
    global CameraD;
  	%% where the call is from
    h = get(TP.WF.UI.H.hCamera_WhiteBalanceRB_Mode_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            Camera_WhiteBalanceRB_Mode
        cmdstr = get(get(TP.WF.UI.H.hCamera_WhiteBalanceRB_Mode_Rocker,'SelectedObject'),'string');
    else
        % called by general update: Camera_WhiteBalanceRB_Mode('Manual'), or 'Off'
        cmdstr = varargin{1};
    end;
    switch cmdstr
        case 'Manual'
            selectnum = 3;
            TP.HW.PC.hCameraSrc.WhiteBalanceRBMode = 'Manual';
        case 'Off'
            selectnum = 2;
            TP.HW.PC.hCameraSrc.WhiteBalanceRBMode = 'Off';
        case ''            
        otherwise
    end;
    % exclusive selection
    set(TP.WF.UI.H.hCamera_WhiteBalanceRB_Mode_Rocker, 'SelectedObject', h(selectnum)); 
    for i = 1:3
        if i==selectnum;    set(h(i),   'backgroundcolor', TP.WF.UI.C.SelectB);
        else                set(h(i),   'backgroundcolor', TP.WF.UI.C.TextBG);	end;
    end;

function Camera_Preview(varargin)
    global TP;
  	%% where the call is from
    h = get(TP.WF.UI.H.hCamera_Preview_Rocker, 'Children');      
    if nargin==0
        % called by GUI:            Camera_Preview
        cmdstr = get(get(TP.WF.UI.H.hCamera_Preview_Rocker,'SelectedObject'),'string');
    else
        % called by general update: Camera_Preview('Preview'), or 'Stop'
        cmdstr = varargin{1};
    end;
    switch cmdstr
        case 'Preview'
            selectnum = 3;            
            setappdata(TP.WF.UI.H0.hImage, 'UpdatePreviewWindowFcn', @frameFunc);
            preview(TP.HW.PC.hCameraVid, TP.WF.UI.H0.hImage);
        case 'Stop'
            selectnum = 2;
            stoppreview(TP.HW.PC.hCameraVid);
        case ''            
        otherwise
    end;
    % exclusive selection
    set(TP.WF.UI.H.hCamera_Preview_Rocker, 'SelectedObject', h(selectnum)); 
    for i = 1:3
        if i==selectnum;    set(h(i),   'backgroundcolor', TP.WF.UI.C.SelectB);
        else                set(h(i),   'backgroundcolor', TP.WF.UI.C.TextBG);	end;
    end;
    
function Camera_CleanUp
    global TP
    global CameraD

    delete(TP.WF.UI.H0.hFigWF);
    
function frameFunc(obj,event,hImage)
    global TP
    global CameraD
    persistent LastFrameTime 
    persistent CurFrameTime
    CurFrameTime = datevec(event.Timestamp);
%     sprintf('%s',CurFrameTime)
    try
%       etime(CurFrameTime,LastFrameTime)
        FrameRate = 1/etime(CurFrameTime,LastFrameTime);
        set(TP.WF.UI.H.hCamera_FrameRate_Edit, 'string', sprintf('%4.2f', FrameRate));
    catch
    end;
        CurImage = event.Data;
        FrameAve = mean(mean(mean(CurImage)));
        set(TP.WF.UI.H.hCamera_FrameAve_Edit, 'string', sprintf('%4.2f', FrameAve));
    
    LastFrameTime = CurFrameTime;
    set(TP.WF.UI.H0.hImage, 'CData', event.Data)
    






