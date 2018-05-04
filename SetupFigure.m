function msg = SetupFigure
% Initiate the display scale parameters
% TP.UI.S = Two Photon Laser Scanning Microscope. User Interface. Scale
%   S.Screen
%       S.Fig
%           S.Panel
%               S.Panellete
%               S.Axes
%           S.Panel

global TP

%% Turn the JAVA LookAndFeel Scheme "Windows" on
% lafs = javax.swing.UIManager.getInstalledLookAndFeels; 
% for lafIdx = 1:length(lafs),  disp(lafs(lafIdx));  end
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.motif.MotifLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel');
javax.swing.UIManager.setLookAndFeel(TP.UI.LookAndFeel);

%% Global Spacer Scale
S.SP = 10;          % Panelette Side Spacer
S.SD =4;            % Double Spacer
S.S = 2;            % Small Spacer 

%% create Figure in the Screen 
    % Screen scale, get the ends of multiple monitors
        % should be checked again for duplicated mode
    MonitorPositions = get(0,'MonitorPositions');
    S.ScreenEnds = [min(MonitorPositions(:,1)) min(MonitorPositions(:,2)) ...
                    max(MonitorPositions(:,3)) max(MonitorPositions(:,4))];
    S.ScreenWidth =     S.ScreenEnds(3) - S.ScreenEnds(1) +1;
    S.ScreenHeight =    S.ScreenEnds(4) - S.ScreenEnds(2) +1;

    % Figure scale
    S.FigSideTitleHeight =  25; 
    S.FigSideWidth =        2; 

    S.FigWidth =    S.ScreenWidth - 2*S.FigSideWidth;
    S.FigHeight =   S.ScreenHeight - S.FigSideTitleHeight - S.FigSideWidth;

    S.FigCurrentW = S.ScreenEnds(1) + S.FigSideWidth;
    S.FigCurrentH = S.ScreenEnds(2) + S.FigSideWidth;
    
    % create the UI figure 
    TP.UI.H0.hFigTP = figure(...
                'Name',             [   TP.D.Sys.Name,...
                                        '  -  ',...
                                        TP.D.Sys.FullName],...
                'NumberTitle',      'off',...
                'Resize',           'off',...
                'color',         	TP.UI.C.BG,...
                'position',         [   S.FigCurrentW,  S.FigCurrentH,...
                                        S.FigWidth,     S.FigHeight],...
                'menubar',          'none');

%% create Panel:Control &   Panelettes 
    % Panelette Scale
    S.PaneletteWidth = 100;     S.PaneletteHeight = 150;    
    S.PaneletteTitle = 18;

    % Panelette, Total #s of rows and columns
    S.PaneletteRowNum = 6;      S.PaneletteColumnNum = 7;

    % Panelette, layout of rows    
    S.PnltSys.row =         6;    S.PnltSys.column =        1;
    S.PnltMech.row =        5;    S.PnltMech.column =       1;
    S.PnltScan.row =        4;    S.PnltScan.column =       1;
    S.PnltTrial.row =       3;    S.PnltTrial.column =      1;
    S.PnltMonImage.row =    2;    S.PnltMonImage.column	=   1;
    S.PnltMonPower.row =    1;    S.PnltMonPower.column =   1;

    % Control Panel Scale 
    S.PanelCtrlWidth =  S.PaneletteColumnNum *(S.PaneletteWidth+S.S) + 3*(2*S.S);
    S.PanelCtrlHeight = S.PaneletteRowNum *(S.PaneletteHeight+S.S) + S.PaneletteTitle;

    % current Position
	S.PanelCurrentW = S.SD + 0;
    S.PanelCurrentH = S.SD;
    
    % create Panel:Control
    TP.UI.H0.hPanelCtrl = uipanel(...
                'parent',           TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
                'units',            'pixels',...
                'Title',            'CONTROL PANEL',...
                'Position',         [   S.PanelCurrentW     S.PanelCurrentH     	...
                                        S.PanelCtrlWidth    S.PanelCtrlHeight]);
                
      	% create Panelettes                     
        for i = 1:S.PaneletteRowNum
            for j = 1:S.PaneletteColumnNum
                TP.UI.H0.Panelette{i,j}.hPanelette = uipanel(...
                'parent',           TP.UI.H0.hPanelCtrl,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
                'units',            'pixels',...
                'Title',            ' ',...
                'Position',         [   2*S.S+(S.S+S.PaneletteWidth)*(j-1),...
                                        2*S.S+(S.S+S.PaneletteHeight)*(i-1),...
                                        S.PaneletteWidth, S.PaneletteHeight]    );
                        % edge is 2*S.S
            end;
        end;
        createPanelettes(S);
        
%% create Panel:Image &     Axes:Image
    % Axes scale
    S.PanelImageAxesWH =    653;

    % Image Panel Scale
    S.PanelImageWidth =     S.PanelImageAxesWH + 2*S.SD;
    S.PanelImageHeight =    S.PanelImageAxesWH + 1*S.SD + S.PaneletteTitle;
    
    % current Position
    S.PanelCurrentW = S.SD + S.PanelCtrlWidth + S.SD;
    S.PanelCurrentH = S.SD;
    % S.PanelCurrentH = S.PanelCurrentH + S.PanelCtrlHeight + 2*S.S;
    
    % create Panel:Image
    TP.UI.H0.hPanelImage = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'IMAGE PANEL',...
        'Position',[S.PanelCurrentW         S.PanelCurrentH     	...
                    S.PanelImageWidth    S.PanelImageHeight]);
                
        % create Axes:Image
        TP.UI.H0.hAxesImage = axes(...
            'parent', TP.UI.H0.hPanelImage,...
            'units','pixels',...
            'Position',[S.SD                S.SD                    ...              
                        S.PanelImageAxesWH  S.PanelImageAxesWH]);
            
            % crreate Image:Disp
            TP.UI.H0.hImageDisp = image(TP.D.Vol.LayerDisp{1},...
                'parent',TP.UI.H0.hAxesImage);
            axis off
            axis image
            box on  
                    
%% create Panel:Angle &     Axes:Angle
    % Axes Scale
    S.PanelAngleAxesWH = 200;

    % Angle Panel Scale
    S.PanelAngleWidth =     S.PanelAngleAxesWH + S.S + S.SD;
    S.PanelAngleHeight =    S.PanelAngleAxesWH + S.SD + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW ;
    S.PanelCurrentH = S.PanelCurrentH + S.PanelImageHeight + S.SD;
    TP.UI.H0.hPanelAngle = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'ANGLE PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelAngleWidth	S.PanelAngleHeight]);
                        
        % create the Axes
        TP.UI.H0.hAxesAngle = axes(...
            'parent', TP.UI.H0.hPanelAngle,...
            'units','pixels',...
            'Position',[0                   S.S   ...              
                        S.PanelAngleAxesWH  S.PanelAngleAxesWH]);   
        SetupDispAngle(TP.UI.H0.hAxesAngle);      
        
%% create Panel:Hist &      Axes:Hist, HistCM
    % Image Scale
    S.PanelHistAxesWidth = 410;
    S.PanelHistAxesHeight = 200;

    % Image Panel Scale
    S.PanelHistWidth =     S.PanelHistAxesWidth + 2*(S.SD);
    S.PanelHistHeight =    S.PanelHistAxesHeight + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW + S.PanelAngleWidth + S.SD;
    S.PanelCurrentH = S.PanelCurrentH;
    TP.UI.H0.hPanelHist = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'HISTOGRAM PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelHistWidth	S.PanelHistHeight]);
                        
        % create the Axes:Hist
        TP.UI.H0.hAxesHist = axes(...
            'parent', TP.UI.H0.hPanelHist,...
            'units', 'pixels', ...
            'Position', [   25	35	380 170]);
                
            % create Bar:Hist
        
            TP.UI.H0.Hist0.hBarHist  = ...
                bar(    (1:1:300)', TP.D.Vol.PixelHist,...
                        'parent', TP.UI.H0.hAxesHist,...
                        'FaceColor', [.5 .5 .5]);    
            set(TP.UI.H0.Hist0.hBarHist,...
                'Ydata', TP.D.Vol.PixelHist);
            
        set(TP.UI.H0.hAxesHist,...
            'FontSize', 6,          'color',        TP.UI.C.BG,...
            'YTick',    [0 1],      'YTickLabel',   {'0'; 'peak'},...
            'YLim',     [0 1.1],    'YColor',       TP.UI.C.FG,...
            'XTick',    [44 300],   'XTickLabel',   {'0'; 'max'},...
            'XLim',     [1 380],    'XColor',       TP.UI.C.FG,...
            'NextPlot', 'add');
                    
            % create Text:
            text(305, 1.000, 'max', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.750, 'min', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.500, 'peak', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.250, 'mean', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMax = ...
                text(310, 0.875, 'MAX', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMin = ...
                text(310, 0.625, 'MIN', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextPeak = ...
                text(310, 0.375, 'PEAK', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMean = ...
                text(310, 0.125, 'MEAN', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            
            % create Mark:
            TP.UI.H0.Hist0.hMarkMax = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hMarkMin = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hMarkPeak = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
                    
        % create Axes:HistCM
        TP.UI.H0.hAxesHistCM = axes(...
            'parent',   TP.UI.H0.hPanelHist,...
            'units',    'pixels',...
            'Position', [25   2   300 20]);

            imagecontrast = zeros(20,300,3);
            % 300 bins
            imagecontrast(:,44:end-1,2) = repmat(0:1/255:1,20,1);
            imagecontrast(:,end,2)      = 1;
            % 44-300 column, 256 +1
            
            imagesc(imagecontrast, 'parent', TP.UI.H0.hAxesHistCM);
    	set(TP.UI.H0.hAxesHistCM, 'Ytick', [], 'Xtick', []);        
  
%% Adjust Figure Size
        S.FigWidth =    S.SD*2 + S.PanelCtrlWidth + ...
                        max(S.PanelImageWidth,(S.PanelAngleWidth+S.SD+S.PanelHistWidth));
        S.FigHeight =   S.SD*2 + ...
                        max(S.PanelCtrlHeight,(S.PanelImageHeight+S.SD+S.PanelAngleHeight));
        set(TP.UI.H0.hFigTP, ...
          'position',	[   S.FigCurrentW,  S.FigCurrentH,...
                        	S.FigWidth,     S.FigHeight]);
                        
TP.UI.S = S;

%% LOG MSG
msg = [datestr(now) '\tSetupFigure\tGUI initialized\r\n'];

function createPanelettes(S)
%% create panelettes
global TP

%% Sys
for disp=1
    S.PnltCurrent.row       = S.PnltSys.row;
    S.PnltCurrent.column    = S.PnltSys.column;
	for i = 1:ceil(length(TP.D.Sys.Scan.PresetGroup)/2)
        % create Toggle Switch panels 'Scan Preset #1~?'
        WP.name =       strcat('Sys Preset #',num2str(i));
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'ToggleSwitch';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { TP.D.Sys.Scan.PresetGroup{i*2-1}.title,...
                    TP.D.Sys.Scan.PresetGroup{i*2-0}.title};    
        WP.tip = {  TP.D.Sys.Scan.PresetGroup{i*2-1}.tip,...
                    TP.D.Sys.Scan.PresetGroup{i*2-0}.tip};
        WP.inputOptions = { TP.D.Sys.Scan.PresetCfg{i*6-5}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-4}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-3}.name;...
                            TP.D.Sys.Scan.PresetCfg{i*6-2}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-1}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-0}.name};
        WP.inputDefault = [ TP.D.Sys.Scan.PresetGroup{i*2-1}.default...
                            TP.D.Sys.Scan.PresetGroup{i*2-0}.default];
        WP.enable = [   TP.D.Sys.Scan.PresetCfg{i*6-5}.SelectEnable,...
                     	TP.D.Sys.Scan.PresetCfg{i*6-4}.SelectEnable,...
                     	TP.D.Sys.Scan.PresetCfg{i*6-3}.SelectEnable;...
                      	TP.D.Sys.Scan.PresetCfg{i*6-2}.SelectEnable,...
                      	TP.D.Sys.Scan.PresetCfg{i*6-1}.SelectEnable,...
                      	TP.D.Sys.Scan.PresetCfg{i*6-0}.SelectEnable];
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-1} = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-0} = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};    
        clear WP; 
            
        % set tag of each button to be 1~?
        for j =1:2
            htemp = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-2+j}, 'children');
            for k = 1:length(htemp)
                set(htemp(k),'tag',num2str( (i-1)*6 + j*3 - k + 1));
            end;
        end;
    
    end;
    
	WP.name = 'Sys AOD Freq';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Scan Frequency Bandwidth (MHz)',...
                    'Central Drive Frequency (MHz)'};
        WP.tip = {	'Scan Frequency Bandwidth (MHz)',...
                    'Central Drive Frequency (MHz)'};
        WP.inputValue = {   TP.D.Sys.AOD.FreqBW / 1e6,...
                            TP.D.Sys.AOD.FreqCF / 1e6};
        WP.inputFormat = {'%5.1f','%5.1f'};    
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSys_AOD_FreqBW_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSys_AOD_FreqCF_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSys_AOD_FreqBW_Edit, 'tag', 'hSys_AOD_FreqBW_Edit');
        set(TP.UI.H.hSys_AOD_FreqCF_Edit, 'tag', 'hSys_AOD_FreqC_Edit');
        clear WP;
        
	WP.name = 'Sys PowerCalib';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Power Calibration',...
                    ''};
        WP.tip = {[ 'Before press, make sure S170C is connected on PM100A (PM100{2}),\n',...
                    'and PM100A is powered on before launching FANTASIA program, \n',...
                    'The function will calibrate 4 things:\n',...
                    '   1. HWP: Power@S121C vs HWP Angle;\n',... 
                    '   2. ARM: Power@S170C vs Power@S121C;\n',...
                    '   3. AMP: X*Y Voltage vs AOD Ctrrl Voltage;\n',...
                    '   4. AOD: Power@S121C vs Power@S121C;\n',...
                    'Juat follow the instructions in the Matlab command window.\n'],...
                    ''  };
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSys_PowerCalib_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        set(TP.UI.H.hSys_PowerCalib_Momentary, 'tag', 'hSys_CalibPowerIn_Momentary');
        clear WP;        
        
	WP.name = 'Sys PowerParam';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   {   'Dichroic Ratio ~= power@Cortex / power@S121C',...
                        'HWP/PRM1Z8 angle when output laser maximizes'};
        WP.tip =    {   '',...
                        ''};
        WP.inputValue = {	TP.D.Sys.Power.C.ARM_p1,...
                            TP.D.Sys.Power.C.HWP_pmaxAngle};
        WP.inputFormat = {'%5.2f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSys_Power_LaserDichRatio_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hSys_Power_LaserMaxAglHWP_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;
        
end

%% Mky / Exp / Ses.Mech  
for disp=1
    
    S.PnltCurrent.row       = S.PnltMech.row;
    S.PnltCurrent.column    = S.PnltMech.column;
   
    %%%%%%%%%%%%%%%%%%%%%%% Mky
	WP.name = 'Mky Monkey#';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';          
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'RIHGT or LEFT hemesphere',...
                    'Animal ID'};
        WP.tip = WP.text; 
        WP.inputValue = {   TP.D.Mky.Side,...
                            TP.D.Mky.ID};    
        WP.inputFormat = {'%s','%s'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hMky_Side_Edit =    TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hMky_ID_Edit =      TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hMky_Side_Edit,	'tag', 'hMky_Side_Edit');
        set(TP.UI.H.hMky_ID_Edit,   'tag', 'hMky_ID_Edit');
        clear WP;    
        
	WP.name = 'Mky Angle(XY)';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'',...
                    'obj arm turned ?? degree down from horizontal plane'};
        WP.tip = {	'',...
                    'obj arm turned ?? degree down from horizontal plane'}; 
        WP.inputValue = {   NaN,...
                            TP.D.Mky.AngleXY};    
        WP.inputFormat = {'','%2.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hMky_AngleXY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hMky_AngleXY_Edit,	'tag', 'hMky_AngleXY_Edit');
        clear WP;        

    %%%%%%%%%%%%%%%%%%%%%%% Exp
	WP.name = 'Exp Est X&Y';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {	'Estimated Y position, (um), rostral-caudal',...
                        'Estimated X position, (um), dorsal-ventral'};
        WP.tip =    {	'Estimated Y position, define as rostral-caudal direction, in um',...
                        'Estimated X position, define as dorsal-ventral direction, in um'}; 
        WP.inputValue = {   TP.D.Exp.Mech.EstY,...
                            TP.D.Exp.Mech.EstX};    
        WP.inputFormat = {'%4.0f','%4.0f'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_Mech_EstY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_Mech_EstX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_Mech_EstY_Edit,	'tag', 'hExp_Mech_EstY_Edit');
        set(TP.UI.H.hExp_Mech_EstX_Edit,	'tag', 'hExp_Mech_EstX_Edit');
        clear WP;
        
   	WP.name = 'Exp LensCfg';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'RockerSwitch';
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Obj & Comp Lens Configuration'};
        WP.tip = {'\n2D raster = 2D diagonal raster scanning\n3D sweep = 3D diagonal raster scanning across multi-layers'};
        WP.inputOptions = {'10x + 1000mm','25x + 1000mm', '25x + 500mm'};
        WP.inputDefault = 1; % TP.D.Ses.Scan.ModeNum; unfinished
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hExp_Mech_LensCfg_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        htemp = get(TP.UI.H.hExp_Mech_LensCfg_Rocker,'children');
        for j = 1:length(htemp)
            set(htemp(j),'tag','hSes_Scan_Mode_Rocker');
        end;
        clear WP;
   WP.name = 'Exp WideField';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {'Wide field surface image from the CCD',''};
        WP.tip = {  'To Capture the Cortical Surface Image for current "Exp"',''};
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hExp_WF_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        set(TP.UI.H.hExp_WF_Momentary,	'tag', 'hExp_WF_Momentary');
        clear WP;
        
	WP.name = 'Exp Z0_SM1Z';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	''...
                    'Z reading # on SM1Z @ the cortex surface level'};
        WP.tip = {	''...
                    'Z reading # on SM1Z @ the cortex surface level'};
        WP.inputValue = {   NaN,...
                            TP.D.Exp.Mech.Z0_SM1Z};    
        WP.inputFormat = {'','%3.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_Mech_Z0_SM1Z_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,	'tag', 'hExp_Mech_Z0_SM1Z_Edit');
        clear WP;
        
    %%%%%%%%%%%%%%%%%%%%%%% Ses     
	WP.name = 'Ses Zs_SM1Z';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'Estimated Z depth, (um), superfacial-deep',...
                    'Z reading # on SM1Z @ this session level'};
        WP.tip = {	'Estimated Z depth, (um), define as superfacial-deep direction, in um',...
                    'Z reading # on SM1Z @ this session level'}; 
        WP.inputValue = {   TP.D.Ses.Mech.EstZ,...
                            TP.D.Ses.Mech.Zs_SM1Z};    
        WP.inputFormat = {'%4.0f','%2.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_Mech_EstZ_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_Mech_Zs_SM1Z_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Mech_EstZ_Edit,	'tag', 'hSes_Mech_EstZ_Edit');
     	set(TP.UI.H.hSes_Mech_Zs_SM1Z_Edit,	'tag', 'hSes_Mech_Zs_SM1Z_Edit');
        clear WP;
            
end;

%% Ses.Scan 
for disp=1

    S.PnltCurrent.row       = S.PnltScan.row;
    S.PnltCurrent.column    = S.PnltScan.column;
           
 	WP.name = 'Ses Scan.Mode';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'RockerSwitch';
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { '2D or 3D,Random Access or Raster'};
        WP.tip = {'2D random = 2D random access jumping scanning among pixels\n2D raster = 2D diagonal raster scanning\n3D sweep = 3D diagonal raster scanning across multi-layers'};
        WP.inputOptions = {'2D random','2D raster', '3D raster'};
        WP.inputDefault = TP.D.Ses.Scan.ModeNum;
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hSes_Scan_Mode_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
       
        set(TP.UI.H.hSes_Scan_Mode_Rocker, 'tag', 'hSes_Scan_Mode_Rocker');
%         htemp = get(TP.UI.H.hSes_Scan_Mode_Rocker,'children'); 
%         for j = 1:length(htemp)
%             set(htemp(j),'tag','hSes_Scan_Mode_Rocker');
%         end;
        clear WP;
    
	WP.name = 'Ses Scan.Scale1';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'# of PIXELS scanned per axis (pixels)',...
                    '# of SAMPLES on 6115 per pixel (1sample = .1us)'};
        WP.tip = {	'# of PIXELS scanned per axis (pixels)',...
                    '# of SAMPLES on 6115 per pixel (1sample = .1us)'};
        WP.inputValue = {   TP.D.Ses.Scan.NumPixlPerAxis,...
                            TP.D.Ses.Image.NumSmplPerPixl}; 
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_Image_NumSmplPerPixl_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Scan_NumPixlPerAxis_Edit, 'tag', 'hSes_Scan_NumPixlPerAxis_Edit');
        set(TP.UI.H.hSes_Image_NumSmplPerPixl_Edit, 'tag', 'hSes_Scan_NumSmplPerPixl_Edit');
        clear WP;
    
	WP.name = 'Ses Scan.Scale2';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = {	'Layer spacing, in um, within z+-50um',...
                    '# of LAYERS per volume scan (layers)'};
        WP.tip = {	'Layer spacing, in um, within z+-50um',...
                    '# of LAYERS per volume scan (layers)'};
        WP.inputValue = {   TP.D.Ses.Scan.LayrSpacingInZ,...
                            TP.D.Ses.Scan.NumLayrPerVlme};
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');          
        TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Scan_LayrSpacingInZ_Edit, 'tag', 'hSes_Scan_LayrSpacingInZ_Edit');
        set(TP.UI.H.hSes_Scan_NumLayrPerVlme_Edit, 'tag', 'hSes_Scan_NumLayrPerVlme_Edit');
        clear WP;
    
	WP.name = 'Ses Scan.Speed';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;    
        WP.text = {	'Volume Time \n(in Sec)',...
                    'Volume Rate \n(in Hz)'};
        WP.tip = {	'Update Time \n(in 6115 samples, 1sample = 0.1us)',...
                    'Volume Rate \n(in Hz)'};
        WP.inputValue = {   TP.D.Ses.Scan.VolumeTime,...
                            TP.D.Ses.Scan.VolumeRate};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');            
        TP.UI.H.hSes_Scan_VolumeTime_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_Scan_VolumeRate_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Scan_VolumeTime_Edit, 'tag', 'hSes_Scan_VolumeTime_Edit');
        set(TP.UI.H.hSes_Scan_VolumeRate_Edit, 'tag', 'hSes_Scan_VolumeRate_Edit');
        clear WP;   

	WP.name = 'Ses Updt.Scale1';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'# of VOLUMES per update',...
                    '# of UPDATES per volume scanned'};
        WP.tip = {	'# of VOLUMES per update',...
                    '# of UPDATES per volume scanned'};
        WP.inputValue = {   TP.D.Ses.Image.NumVlmePerUpdt,...
                            TP.D.Ses.Image.NumUpdtPerVlme};
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');          
        TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Image_NumUpdtPerVlme_Edit, 'tag', 'hSes_Image_NumUpdtPerVlme_Edit');
        set(TP.UI.H.hSes_Image_NumVlmePerUpdt_Edit, 'tag', 'hSes_Image_NumUpdtPerVlme_Edit');
        clear WP;
    
    WP.name = 'Ses Updt.Speed';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;    
        WP.text = {	'Update Time \n(in Sec)',...
                    'Update Rate \n(in Hz)'};
        WP.tip = {	'Update Time \n(in Sec)',...
                    'Update Rate \n(in Hz)'};
        WP.inputValue = {   TP.D.Ses.Image.UpdateTime,...
                            TP.D.Ses.Image.UpdateRate};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');            
        TP.UI.H.hSes_Image_UpdateTime_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_Image_UpdateRate_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_Image_UpdateTime_Edit, 'tag', 'hSes_Image_UpdateTime_Edit');
        set(TP.UI.H.hSes_Image_UpdateRate_Edit, 'tag', 'hSes_Image_UpdateRate_Edit');
        clear WP; 
        
  	WP.name = 'Ses Commit';  
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';	
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {     'Commit the Session & NI-DAQ'};
        WP.tip = {[     'Commit Ses & scanning parameters\n',...
                        'Generate the scan pattern\n',...
                        'Allocate memories for D.Trl\n',...
                        'Commit NI-DAQ tasks']};
        WP.inputOptions = { 'Commit',   'uncommited',   ''};        
        WP.enable = [       1           0               0];
        WP.inputDefault = 2-TP.D.Ses.Committed;
        Panelette(S, WP, 'TP');
        TP.UI.H.hSes_Commit_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1}; 
        set(TP.UI.H.hSes_Commit_Rocker,	'tag', 'hSes_Commit_Rocker');
        clear WP;
end;

%% Trl
for disp=1
        
    S.PnltCurrent.row       = S.PnltTrial.row;
    S.PnltCurrent.column    = S.PnltTrial.column;  
    
	WP.name = 'Trl Start/Stop';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'Scan Start/Stop  Switch'};
        WP.tip =    {   'Start / Stop the Scanning & Imaging Task'};
        WP.inputOptions = { 'Triggered',    'Start',    'Stop'};
        WP.enable = [       0               1           1];
        WP.inputDefault = 3 - TP.D.Trl.StartTrigStop;
        Panelette(S, WP, 'TP');
        TP.UI.H.hTrl_StartTrigStop_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP;   
    
    WP.name = 'Trl Duration';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';          
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = {	'Duration SCANNING MAX (seconds)',...
                    'Duration SCANNED (seconds)'};
        WP.tip = {	'Duration SCANNING MAX (seconds)',...
                    'Duration SCANNED (seconds)'};
        WP.inputValue = {   TP.D.Trl.Tmax,...
                            TP.D.Trl.Tdone};
        WP.inputFormat = {'%5.1f','%5.1f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_Tmax_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_Tdone_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;
            
	WP.name = 'Trl DataLogging';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Data Logging'};
        WP.tip = {  'Image Data Logging ON/OFF'};
        WP.inputOptions = {'ON', 'OFF', ''};
        WP.inputDefault = 2-TP.D.Trl.DataLogging;
        Panelette(S, WP, 'TP');
        TP.UI.H.hTrl_DataLogging_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
	WP.name = 'Trl ScanScheme'; 
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'FOCUS / GRAB / LOOP similar as in scanimage'};
        WP.tip =    {[  'FOCUS i = \n'...
                        '   Started and \n'...
                        '   Triggered Immediately with GUI "Start" & the Internal trigger, \n'...
                        '   Stopped with GUI "Stop" (no auto timeout) \n\n',...
                        'GRAB i =  \n'...
                        '   Started with GUI "Start", should be following sound loading first, \n'...
                        '   Triggered Immediately with GUI "Start" & the Internal trigger, \n'....
                        '       Triggered together with the AO_6323 task for playing sounds \n'...
                        '   Stopped with either GUI "stop" or PC counted time out\n\n',...
                        'LOOP e =  \n',...
                        '   Start with GUI "Start", and then wait for XBlaster3 control \n'...
                        '   Triggered with real External trigger rising edge, \n'...
                        '       Stopped, and re-Started with real external trigger falling edge or auto time out, \n'... 
                        '   Fully Stopped or Cancelled with GUI "Stop"']};
        WP.inputOptions = {'FOCUS i','GRAB i','LOOP e'};
        WP.inputDefault = TP.D.Trl.ScanSchemeNum;
        Panelette(S, WP, 'TP');
        TP.UI.H.hTrl_ScanScheme_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP; 
        
	WP.name = 'Trl LoadSound';      % may delete the external trigger button
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Load Sound File, Start Sound & Imaging Tasks',...
                    'Wait to be deleted, The External Trigger'};
        WP.tip = {  [   'This will load a sound file and setup an AO_6323 Task to play that sound,\n',...
                        'and build (reset) an "external" trigger CO task to control the other tasks.\n,',...
                        'AO_6223, AI_6115, DO_6536, CO_TrigListener are all triggered by this'],...
                        'To start this "external" trigger and trigger all the tasks mentioned.'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hTrl_LoadSound_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        TP.UI.H.hTrl_IntTrig_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2}; 
        set(TP.UI.H.hTrl_LoadSound_Momentary,	'tag', 'hTrl_LoadSound_Momentary');
        set(TP.UI.H.hTrl_IntTrig_Momentary,     'tag', 'hTrl_IntTrig_Momentary');
        clear WP;
        
end;

%% Mon.Image
for disp=1
    
    S.PnltCurrent.row       = S.PnltMonImage.row;
    S.PnltCurrent.column    = S.PnltMonImage.column;
    
	WP.name = 'Mon PMT.HV';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =       {'PMT High Voltage ON/OFF'};
        WP.tip =        {  'H = Turn the PMT HV ON\nL = Turn the PMT HV ON'};
        WP.inputOptions =   {'ON','OFF',''};
        WP.inputDefault =   2 - TP.D.Mon.PMT.PMTctrl;
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_PMTctrl_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP;
    
	WP.name = 'Mon PMT.Cooling';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text =   {'Fan\nOFF/ON','Peltier\nOFF/ON'};
        WP.tip =    {   'H = Turn the fan OFF\nL = Turn the fan ON',...
                        'H = Turn the cooling ON\nL = Turn the cooling OFF'};
        WP.inputOptions =   {'OFF','ON','';'OFF','ON',''};
        WP.inputDefault =   [   2 - TP.D.Mon.PMT.FANctrl,...
                                2 - TP.D.Mon.PMT.PELctrl];
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hMon_PMT_FANctrl_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        TP.UI.H.hMon_PMT_PELctrl_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};
        clear WP;
    
	WP.name = 'Mon PMT.Status';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'LED';            
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   { 'PMT','','M9012',''};
        WP.tip =    {   'H = PMT HV is ON\nFast Flashing (2Hz) = PMT HV OFF & Cooled\nSlow Flashing (1/2Hz) = PMT HV OFF & Cooling\nL = Both PMT HV and Cooling are OFF',...
                        '',...
                        'H = M9012 Power Supply is ON\nL = M9012 Power Supply is OFF',...
                        ''};
        Panelette(S, WP, 'TP');        
        TP.UI.H.hMon_PMT_M9012_LED =        TP.UI.H0.Panelette{WP.row,WP.column}.hLED{3};
        TP.UI.H.hMon_PMT_Status_LED =       TP.UI.H0.Panelette{WP.row,WP.column}.hLED{1};
        clear WP;
    
	WP.name = 'Mon PMT.Error';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'LED';          	
        WP.row =        S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   '2 bright','2 hot','Error',''};
        WP.tip =    {   'H = Too bright, overload protection is on\nL = No overload error',...
                        'H = Too hot, overheat protection is on\nL = No overheat error',...
                        'H = PMT Overload Protection is ON\nF =  PMT Cooling Error\nL = No error\n Tip: overload, turn off M9012 power and start again\n Tip: overheat, eliminate the heat cause, turn off M9012 power and start again',...
                        ''};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hMon_PMT_Error_LED =        TP.UI.H0.Panelette{WP.row,WP.column}.hLED{3};
        TP.UI.H.hMon_PMT_TooBright_LED =    TP.UI.H0.Panelette{WP.row,WP.column}.hLED{1};
        TP.UI.H.hMon_PMT_TooHot_LED =       TP.UI.H0.Panelette{WP.row,WP.column}.hLED{2};
    
        % prepare D's line names and handles 
        for i = 1:TP.D.Sys.NI.Chan_DI_PMT_Status{6}
            str = strcat(   'TP.D.Sys.NI.Chan_DI_PMT_Status{7}{i}= TP.UI.H.hMon_PMT_',...
                            TP.D.Sys.NI.Chan_DI_PMT_Status{3}{i},'_LED;');
            eval(str);
        end;
        clear WP;
    
	WP.name = 'Mon PMT.GainCtrl';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   'PMT Gain Control\n(0-0.9V)'};
        WP.tip =    {   'PMT Gain Control\n(0-0.9V)'};
        WP.inputValue =     TP.D.Mon.PMT.CtrlGainValue;
        WP.inputRange =     TP.D.Sys.PMT.CtrlGainRange;
        WP.inputSlideStep=  TP.D.Sys.PMT.CtrlGainSteps/...
            (TP.D.Sys.PMT.CtrlGainRange(2)-TP.D.Sys.PMT.CtrlGainRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
       
	WP.name = 'Mon PMT.GainMont';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;   
        WP.text =   {   'PMT #1 Gain Noise (mV)', 'PMT #1 Gain Monitor (Volt)'};
        WP.tip =    {   'PMT #1 Gain Noise (mV)', 'PMT #1 Gain Monitor (Volt)'};
        WP.inputValue =     {   TP.D.Mon.PMT.MontGainNoise,...
                                TP.D.Mon.PMT.MontGainValue};    
        WP.inputFormat =    {'%5.0f','%5.2f'};
        WP.inputEnable =    {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_MontGainNoise_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hMon_PMT_MontGainValue_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;
        
   	WP.name = 'Mon Display';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'ToggleSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Display Enable', 'Display Mode'};
        WP.tip = {  'Display Enable ON/OFF', 
                    'Image Display Mode'};
        WP.inputOptions = { 'ON', 'OFF', '';
                            'Abs','Rltv',''};
        WP.inputDefault = [ 2-TP.D.Mon.Image.DisplayEnable,...
                            TP.D.Mon.Image.DisplayModeNum];
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Image_DisplayEnable_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        TP.UI.H.hMon_Image_DisplayMode_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};
%         htemp = get(TP.UI.H.hMon_Image_DisplayEnable_Toggle,'children');
%         for j = 2:3
%             set(htemp(j),'enable', 'inactive');
%         end;
        clear WP;
        
end

%% Mon.Power
for disp=1
    
    S.PnltCurrent.row       = S.PnltMonPower.row;
    S.PnltCurrent.column    = S.PnltMonPower.column;
    
	WP.name = 'Power AOD Ctrl';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';  
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD X&Y Scanning Amp Ctrl\n(0-5V)'};
        WP.tip =    {   'AOD X&Y Scanning Amp Ctrl\n(0-5V)'};  
        WP.inputValue =     TP.D.Mon.Power.AOD_CtrlAmpValue;
        WP.inputRange =     TP.D.Sys.Power.AOD_CtrlAmpRange;
        WP.inputSlideStep=  TP.D.Sys.Power.AOD_CtrlAmpSteps/...
            (TP.D.Sys.Power.AOD_CtrlAmpRange(2)-TP.D.Sys.Power.AOD_CtrlAmpRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
       
	WP.name = 'Power X Monitor';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD X Axis Scanning Noise (mV)','AOD X Axis Scanning Amplitude (Volt)'};
        WP.tip =    {   'AOD X Axis Scanning Noise (mV)','AOD X Axis Scanning Amplitude (Volt)'};
        WP.inputValue = {   TP.D.Mon.Power.AOD_MontAmpNoise(1),...
                            TP.D.Mon.Power.AOD_MontAmpValue(1)};
        WP.inputFormat = {'%5.0f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_MontAmpNoiseX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_AOD_MontAmpValueX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;

	WP.name = 'Power Y Monitor';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD Y Axis Scanning Noise (mV)','AOD Y Axis Scanning Amplitude (Volt)'};
        WP.tip =    {   'AOD Y Axis Scanning Noise (mV)','AOD Y Axis Scanning Amplitude (Volt)'};
        WP.inputValue = {	TP.D.Mon.Power.AOD_MontAmpNoise(2),...
                            TP.D.Mon.Power.AOD_MontAmpValue(2)};
        WP.inputFormat = {'%5.0f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_MontAmpNoiseY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_AOD_MontAmpValueY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;    

	WP.name = 'Power Predicted';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text =   {   'Laser Power \nMax Allowed\n@Cortex (mW)',...
                        'Laser Power Max\nat current angle\n@Cortex (mW)'};
        WP.tip =    {   'Laser Power Max Allowed @Cortex (mW)',...
                        'Laser Power when AOD@5V @Cortex (mW)'};
        WP.inputValue = {	TP.D.Mon.Power.PmaxCtxAllowed,...
                            TP.D.Mon.Power.PmaxAtCurAngle};
        WP.inputFormat = {'%5.1f','%5.1f'};
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon.Power_PmaxAtCurAngle_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;      
    
	WP.name = 'Power Monitored';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   {   'Laser Power \nInferred \n@Cortex (mW)',...
                        'Laser Power \nMeasured \n@S121C (mW)'};
        WP.tip =    {   'Laser Power Inferred @Cortex (mW)',...
                        'Laser Power Measured @S121C (mW)'};
        WP.inputValue = {	TP.D.Mon.Power.PinferredAtCtx,...
                            TP.D.Mon.Power.PmeasuredS121C};
        WP.inputFormat = {'%5.4f','%5.4f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_PinferredAtCtx_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_PmeasuredS121C_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP; 
        
	WP.name = 'Power HWP';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';  
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'PRM1Z8 control angle, which rotates the HWP'};
        WP.tip =    {   'PRM1Z8 control angle, which rotates the HWP'};  
        WP.inputValue =     0;
        WP.inputRange =     TP.D.Sys.Power.HWP_RotAnglRange;
        WP.inputSlideStep=  TP.D.Sys.Power.HWP_RotAnglSteps/...
            (TP.D.Sys.Power.HWP_RotAnglRange(2)-TP.D.Sys.Power.HWP_RotAnglRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
        
end;
 
% % create Edit panel 'Image Delays'
%     WP.handleseed = 'TP.UI.H0.Panelette';
%     WP.type = 'Edit';           WP.name = 'Image Delays';
%     WP.row      = S.PnltCurrent.row;
%     WP.column   = S.PnltCurrent.column;
%         S.PnltCurrent.column = S.PnltCurrent.column + 1;
%     WP.text = {	'Tdelay, samples to reach laser beam (1S=0.1us)',...
%                 'Ttrans, samples to go across laser beam (1S=0.1us)'};
%     WP.tip = {	'Tdelay, samples to reach laser beam (1S=0.1us)',...
%                 'Ttrans, samples to go across laser beam (1S=0.1us)'}; 
%     WP.inputValue = {   TP.D.Image.Tdelay,...
%                         TP.D.Image.Ttrans};    
%     WP.inputFormat = {'%5.0f','%5.0f'};
%     WP.inputEnable = {'inactive','inactive'};
%     Panelette(S, WP, 'TP');    
%     TP.UI.H.hImage_Tdelay_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
%     TP.UI.H.hImage_Ttrans_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
%     clear WP;
    




    