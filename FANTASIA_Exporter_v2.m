function varargout = FANTASIA_Exporter_v2(varargin)
% Flexible And Nimble Two-photon AOD Scanning In vivo imAging
% The Exporter code for exporting raw data into TIFF pictures or videos
% This is the Verision 5.1:
%   (1) The setting data saved is TP.D
%   (2) More than that

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
clear all
fclose('all'); % prevent fseek errors when switching files in "SelectFile" (Yueqi)
global TP

TP.EX.Name =            mfilename;
TP.EX.Dir.DirString =   uigetdir('C:\=FANTASIA=Stream=', 'Pick a Directory');
SetupD;
SetupFigurePI;
SetupFileVolumeLists;

set(TP.EX.UI.H0.hFileList,                      'Callback', [TP.EX.Name, '(''SelectFile'')']);
set(TP.EX.UI.H0.hVlmeList,                      'Callback', [TP.EX.Name, '(''SelectVlme'')']);
set(TP.EX.UI.H.hImage_DisplayMode_Rocker,       'SelectionChangeFcn', [TP.EX.Name, '(''SelectDisplayMode'')']);
set(TP.EX.UI.H.hImage_SaveVideoAVI_Momentary,	'Callback', [TP.EX.Name, '(''SaveVideoAVI'')']);
set(TP.EX.UI.H.hImage_SaveVideoMP4_Momentary,   'Callback', [TP.EX.Name, '(''SaveVideoMP4'')']);
set(TP.EX.UI.H.hImage_SaveImageOne_Momentary,	'Callback', [TP.EX.Name, '(''SaveImageOne'')']);
set(TP.EX.UI.H.hImage_SaveSessionOne_Momentary,   'Callback', [TP.EX.Name, '(''SaveSessionOne'')']);
set(TP.EX.UI.H.hImage_SaveSessionAll_Momentary,   'Callback', [TP.EX.Name, '(''SaveSessionAll'')']);
function SetupFigurePI
global TP

%% UI Color
S.Color.BG =        [   0       0       0];
S.Color.HL =        [   0       0       0];
S.Color.FG =        [   0.6     0.6     0.6];    
S.Color.TextBG =    [   0.25    0.25    0.25];
S.Color.SelectB =  	[   0       0       0.35];
S.Color.SelectT =  	[   0       0       0.35];
TP.EX.UI.C =        S.Color;

%% Turn the JAVA LookAndFeel Scheme "Motif" on
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.motif.MotifLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');

%% UI Figure
    % Screen Scale 
    MonitorPositions = get(0,'MonitorPositions');
    S.ScreenEnds = [min(MonitorPositions(:,1)) min(MonitorPositions(:,2)) ...
                    max(MonitorPositions(:,3)) max(MonitorPositions(:,4))];
%     S.ScreenWidth = S.ScreenEnds(3) - S.ScreenEnds(1) +1;
%     S.ScreenHeight = S.ScreenEnds(4) - S.ScreenEnds(2) +1;
    S.ScreenWidth =     1920;
    S.ScreenHeight =    1080;    
    
    % Figure scale
    S.FigSideTitleHeight =  30; 	
    S.FigSideWidth =        8; 
    S.FigSideToolbarWidth = 60;

    S.FigWidth =    S.ScreenWidth - 2*S.FigSideWidth - S.FigSideToolbarWidth;
    S.FigHeight =   S.ScreenHeight - S.FigSideTitleHeight - S.FigSideWidth;

    S.FigCurrentW = S.ScreenEnds(1) + S.FigSideWidth;
    S.FigCurrentH = S.ScreenEnds(2) + S.FigSideWidth;

    % create the UI figure 
    TP.EX.UI.H0.hFigPI = figure(...
        'Name', mfilename,...
        'NumberTitle','off','Resize','off',...
        'color',                S.Color.BG,...
        'position',[S.FigCurrentW,  S.FigCurrentH,...
                    S.FigWidth,     S.FigHeight],...
        'menubar','none');

    javax.swing.UIManager.getLookAndFeelDefaults().put('ScrollBar.track', javax.swing.plaf.ColorUIResource(0,0,0));
    
%% UI ImagePanel
    % Global Spacer Scale
    S.SP = 10;          % Panelette Side Spacer
    S.SD = 4;           % Side Double Spacer
    S.S = 2;            % Small Spacer 
    S.PaneletteTitle = 18;

    % Image Scale
    S.PanelImageAxesWH = 1024;

    % Image Panel Scale
    S.PanelImageWidth =     S.PanelImageAxesWH + 2*(S.SD);
    S.PanelImageHeight =    S.PanelImageAxesWH + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.SD;
    S.PanelCurrentH = S.SD;
    TP.EX.UI.H0.hPanelImage = uipanel(...
        'parent', TP.EX.UI.H0.hFigPI,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units','pixels',...
        'Title', 'IMAGE PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelImageWidth	S.PanelImageHeight]);

        % create the Axes
        TP.EX.UI.H0.hAxesImage = axes(...
            'parent', TP.EX.UI.H0.hPanelImage,...
            'units','pixels',...
            'Position',[0                   S.SD   ...              
                        S.PanelImageAxesWH  S.PanelImageAxesWH]); 
                    
        %     TP.UI.H0.hImage = image(TP.D.Image.VolumeT.LayerDisp{1},...
        %         'parent',TP.UI.H0.hAxesImage);
        %     axis off
        %     axis image
        %     box on
                    
%% UI Filelist & Volumelist
    % List Scale
    S.ListFileWidth = 220;
    S.ListVlmeWidth = 100;
    S.ListTextWidth = S.ListFileWidth + S.ListVlmeWidth + S.SD;
    
    S.ListTextHeight = 500;
    S.ListHeight = S.PanelImageAxesWH - S.ListTextHeight - S.SD;
    
    % List Panel Scale
    S.PanelListWidth = S.SD + S.ListFileWidth + S.SD + S.ListVlmeWidth + S.SD;
    S.PanelListHeight = S.PanelImageHeight;

    % create the List Panel
  	S.PanelCurrentW  = S.PanelCurrentW + S.PanelImageWidth + S.SD;
    TP.EX.UI.H0.hPanelList = uipanel(...
        'parent', TP.EX.UI.H0.hFigPI,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units','pixels',...
        'Title', 'LIST PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelListWidth	S.PanelListHeight]);   
                
        % Text
        TP.EX.UI.H0.hFileText = uicontrol(...
            'style', 'text',...
            'FontName', 'FixedWidth',...
            'FontSize', 8,...
            'HorizontalAlignment','left',...
            'parent', TP.EX.UI.H0.hPanelList,...
            'BackgroundColor',      S.Color.BG,...
            'ForegroundColor',      S.Color.FG,...
            'units','pixels',...
            'Position',[S.SD                S.SD     	...
                        S.ListTextWidth     S.ListTextHeight]);    
                
        % Filelist
        TP.EX.UI.H0.hFileList = uicontrol(...
            'style', 'listbox',...
            'parent', TP.EX.UI.H0.hPanelList,...
            'BackgroundColor',      S.Color.BG,...
            'ForegroundColor',      S.Color.FG,...
            'units','pixels',...
            'Position',[S.SD                S.SD + S.ListTextHeight + S.SD   	...
                        S.ListFileWidth     S.ListHeight]);

        % Volumelist
        TP.EX.UI.H0.hVlmeList = uicontrol(...
            'style', 'listbox',...
            'parent', TP.EX.UI.H0.hPanelList,...
            'BackgroundColor',      S.Color.BG,...
            'ForegroundColor',      S.Color.FG,...
            'units','pixels',...
            'Position',[S.SD + S.ListFileWidth + S.SD   S.SD + S.ListTextHeight + S.SD     	...
                        S.ListVlmeWidth                 S.ListHeight]);

%% UI Control Panel
    % Panelette Scale
    S.PaneletteWidth = 100;         S.PaneletteHeight = 150;    
    S.PaneletteTitle = 18;

    % Panelette #
    S.PaneletteRowNum = 3;  S.PaneletteColumnNum = 4;
    
    % Control Panel Scale 
    S.PanelCtrlWidth =  S.PaneletteColumnNum *(S.PaneletteWidth+S.S) + 2*S.SD;
    S.PanelCtrlHeight = S.PaneletteRowNum *(S.PaneletteHeight+S.S) + S.PaneletteTitle;
    
    % create the Control Panel
    S.PanelCurrentW = S.PanelCurrentW + S.PanelListWidth + S.SD;
    S.PanelCurrentH = S.SD;
    TP.EX.UI.H0.hPanelCtrl = uipanel(...
        'parent', TP.EX.UI.H0.hFigPI,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units','pixels',...
        'Title', 'CONTROL PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelCtrlWidth    S.PanelCtrlHeight]);

        % create rows of Empty Panelettes                      
        for i = 1:S.PaneletteRowNum
            for j = 1:S.PaneletteColumnNum
                TP.EX.UI.H0.Panelette{i,j}.hPanelette = uipanel(...
                'parent', TP.EX.UI.H0.hPanelCtrl,...
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
S.PnltImage.column = 1;     S.PnltImage.row = 1;

% create MomentarySwitch panels 'Save One Image' (added by Yueqi 8/22/18)
    WP.handleseed = 'TP.EX.UI.H0.Panelette';
    WP.type = 'MomentarySwitch';  WP.name = 'Save One Image';
    WP.row = S.PnltImage.row + 1; 	WP.column = S.PnltImage.column + 3;  
    WP.text = {'Save the CURRENT image',''};
    WP.tip = { 'Save the CURRENT image',''};
    WP.inputEnable = {'on','on'};
    Panelette(S, WP, 'TP');
    TP.EX.UI.H.hImage_SaveImageOne_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
%     TP.EX.UI.H.hImage_SaveImageOne_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2}; 
    clear WP;
    
% create Edit panel 'Image Arm Pos'
    WP.handleseed = 'TP.EX.UI.H0.Panelette';
    WP.type = 'Edit';           WP.name = 'Image Arm Pos';
    WP.row = S.PnltImage.row;  	WP.column = S.PnltImage.column + 0; 
    WP.text = {	'obj arm turned to the ''RIGHT'' or ''LEFT'' side',...
                'obj arm turned ? degree down from horizontal plane'};
    WP.tip = {	'obj arm turned to the ''RIGHT'' or ''LEFT''\n looking from outside',...
                'obj arm turned ?? degree down from horizontal plane'}; 
    WP.inputValue = {   'right',...
                        0};    
    WP.inputFormat = {'%s','%5.0f'};
    WP.inputEnable = {'on','on'};
    Panelette(S, WP, 'TP');    
    TP.EX.UI.H.hImage_ArmSide_Edit = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
    TP.EX.UI.H.hImage_ArmAngle_Edit = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
    clear WP;
    
% create RockerSwitch panelette 'Image Disp Mode'
    WP.handleseed = 'TP.EX.UI.H0.Panelette';
    WP.type = 'RockerSwitch';	WP.name = 'Image Disp Mode';
    WP.row = S.PnltImage.row; 	WP.column = S.PnltImage.column + 1;  
    WP.text = { 'Image Display Mode'};
    WP.tip = {  'Image Display Mode\n'};
    WP.inputOptions = {'Absolute','Relative',''};
  	WP.inputDefault = 1;
    Panelette(S, WP, 'TP');
    TP.EX.UI.H.hImage_DisplayMode_Rocker = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
    TP.EX.D.ImageDisplayMode = 1;
    clear WP;    
  
% create MomentarySwitch panels 'Image Save'
    WP.handleseed = 'TP.EX.UI.H0.Panelette';
    WP.type = 'MomentarySwitch';  WP.name = 'Save Images';
    WP.row = S.PnltImage.row; 	WP.column = S.PnltImage.column + 2;  
    WP.text = {'Save the CURRENT session','Save ALL sessions'};
    WP.tip = { 'Save the CURRENT session','Save ALL sessions'};
    WP.inputEnable = {'on','on'};
    Panelette(S, WP, 'TP');
    TP.EX.UI.H.hImage_SaveSessionOne_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
    TP.EX.UI.H.hImage_SaveSessionAll_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2}; 
    clear WP;
    
% create MomentarySwitch panels 'Video Save'
    WP.handleseed = 'TP.EX.UI.H0.Panelette';
    WP.type = 'MomentarySwitch';  WP.name = 'AVI / MP4 Video';
    WP.row = S.PnltImage.row; 	WP.column = S.PnltImage.column + 3;  
    WP.text = {'Save AVI (uncompressed) video','Save MP4 (quality 100) video'};
    WP.tip = {  'Save AVI (uncompressed) video w/ the sound','Save MP4 (quality 100) video w/o the sound'};
    WP.inputEnable = {'on','on'};
    Panelette(S, WP, 'TP');
    TP.EX.UI.H.hImage_SaveVideoAVI_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
    TP.EX.UI.H.hImage_SaveVideoMP4_Momentary = TP.EX.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2}; 
    clear WP;
    
    
    
%% UI Hist Panel
    % Image Scale
    S.PanelHistAxesWidth = 410;
    S.PanelHistAxesHeight = 200;

    % Image Panel Scale
    S.PanelHistWidth =     S.PanelHistAxesWidth + 2*(S.SD);
    S.PanelHistHeight =    S.PanelHistAxesHeight + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW;
    S.PanelCurrentH = S.PanelCurrentH + S.PanelCtrlHeight + S.SD;
    TP.EX.UI.H0.hPanelHist = uipanel(...
        'parent', TP.EX.UI.H0.hFigPI,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units','pixels',...
        'Title', 'HISTOGRAM PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelHistWidth	S.PanelHistHeight]);
                        
        % create the Axes:Hist
        TP.EX.UI.H0.hAxesHist = axes(...
            'parent', TP.EX.UI.H0.hPanelHist,...
            'units', 'pixels', ...
            'Position', [   25	35	380 170]);
        
            % prepare Histogram related Parameters
            TP.D.Image.VolumeT.PixelHist = zeros(1,300);         % 300
            TP.D.Image.VolumeT.PixelHistEdges =  -344:8:2048; 	% 300 bin 
                % N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1).  
                % The last bin will count any values of X that match EDGES(end)
               	% -344~-337     is the 1    bin
                % 0~7           is the 44   bin
                % 2040-2047    	is the 299  bin
                % 2048          is the 300  bin
                % there are 256 +1 bin from 0-2048, match with the 8bit color
        
            % create the Histogram
            TP.EX.UI.H0.Hist0.hBarHist  = ...
                bar(    (1:1:300)', TP.D.Image.VolumeT.PixelHist,...
                        'parent', TP.EX.UI.H0.hAxesHist,...
                        'FaceColor', [.5 .5 .5]);            
            set(TP.EX.UI.H0.Hist0.hBarHist,...
                'Ydata', TP.D.Image.VolumeT.PixelHist);
            
        set(TP.EX.UI.H0.hAxesHist,...
            'FontSize', 6,          'color',        S.Color.BG,...
            'YTick',    [0 1],      'YTickLabel',   {'0'; 'peak'},...
            'YLim',     [0 1.1],    'YColor',       S.Color.FG,...
            'XTick',    [44 300],   'XTickLabel',   {'0'; 'max'},...
            'XLim',     [1 380],    'XColor',       S.Color.FG,...
            'NextPlot', 'add');
            
            % create Text:
            text(305, 1.000, 'max', 'color', S.Color.FG, 'parent', TP.EX.UI.H0.hAxesHist);
            text(305, 0.750, 'min', 'color', S.Color.FG, 'parent', TP.EX.UI.H0.hAxesHist);
            text(305, 0.500, 'peak', 'color', S.Color.FG, 'parent', TP.EX.UI.H0.hAxesHist);
            text(305, 0.250, 'mean', 'color', S.Color.FG, 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hTextMax = ...
                text(310, 0.875, 'MAX', 'color', [0 .5 0], 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hTextMin = ...
                text(310, 0.625, 'MIN', 'color', [0 .5 0], 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hTextPeak = ...
                text(310, 0.375, 'PEAK', 'color', [0 .5 0], 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hTextMean = ...
                text(310, 0.125, 'MEAN', 'color', [0 .5 0], 'parent', TP.EX.UI.H0.hAxesHist);
            
            % create Mark:
            TP.EX.UI.H0.Hist0.hMarkMax = ...
                plot(44, 1.05, 'g.', 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hMarkMin = ...
                plot(44, 1.05, 'g.', 'parent', TP.EX.UI.H0.hAxesHist);
            TP.EX.UI.H0.Hist0.hMarkPeak = ...
                plot(44, 1.05, 'g.', 'parent', TP.EX.UI.H0.hAxesHist);
                    
        % create the Axes:HistCM
        TP.EX.UI.H0.hAxesHistCM = axes(...
            'parent',   TP.EX.UI.H0.hPanelHist,...
            'units',    'pixels',...
            'Position', [25   2   300 20]);

            imagecontrast = zeros(20,300,3);
            % 300 bins 
            imagecontrast(:,44:end-1,2) = repmat(0:1/255:1,20,1);
            imagecontrast(:,end,2)      = 1;
            % 44-300 column, 256 +1
            
            imagesc(imagecontrast, 'parent', TP.EX.UI.H0.hAxesHistCM);
    	set(TP.EX.UI.H0.hAxesHistCM, 'Ytick', [], 'Xtick', []);

    
%% UI Angle Panel    
    % Image Scale
    S.PanelAngleAxesWH = 200;

    % Image Panel Scale
    S.PanelAngleWidth =     S.PanelAngleAxesWH + S.S + S.SD;
    S.PanelAngleHeight =    S.PanelAngleAxesWH + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW;
    S.PanelCurrentH = S.PanelCurrentH + S.PanelHistHeight + S.SD;
    TP.EX.UI.H0.hPanelAngle = uipanel(...
        'parent', TP.EX.UI.H0.hFigPI,...
        'BackgroundColor',      S.Color.BG,...
        'Highlightcolor',       S.Color.HL,...
        'ForegroundColor',      S.Color.FG,...
        'units','pixels',...
        'Title', 'ANGLE PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelAngleWidth	S.PanelAngleHeight]);
                        
        % create the Axes
        TP.EX.UI.H0.hAxesAngle = axes(...
            'parent', TP.EX.UI.H0.hPanelAngle,...
            'units','pixels',...
            'Position',[0                   S.S   ...              
                        S.PanelAngleAxesWH  S.PanelAngleAxesWH],...
                         'Ylim', [-1 1], 'Xlim', [-1 1]);   
                   


%% Turn the JAVA LookAndFeel Scheme "Motif" off, back on "Windows"
%     pause(.05);
%     javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');

                
function SetupFileVolumeLists 
%% Setup the File Lists and call SelectFile
global TP

    % Setup hFileList
    TP.EX.Dir.FileListR =	dir(fullfile(TP.EX.Dir.DirString,'\*.mat'));    
    TP.EX.Dir.FileListT =	TP.EX.Dir.FileListR(2:end);
%     TP.EX.Dir.FileNum =     length(TP.EX.Dir.FileListR);
%     fileliststring =        reshape([TP.EX.Dir.FileListR.name], 19, []);
    TP.EX.Dir.FileNum =     length(TP.EX.Dir.FileListT);
    fileliststring =        reshape([TP.EX.Dir.FileListT.name], 19, []);
    fileliststring =        [fileliststring; repmat('|',1,size(fileliststring,2))];
    fileliststring =        reshape(fileliststring, 1, []);
    set(TP.EX.UI.H0.hFileList, 'string', fileliststring(1:end-1));
    
    % Setup FileHandles and FileSettings
    for i = 1:TP.EX.Dir.FileNum
        fnametemp = TP.EX.Dir.FileListT(i).name;
        hSessMatTemp = matfile([TP.EX.Dir.DirString, '\', TP.EX.Dir.FileListR(1).name]);
        hFileMatTemp = matfile([TP.EX.Dir.DirString, '\', fnametemp]);
        TP.EX.D.File(i,1).hFileMat =    hFileMatTemp;
        TP.EX.D.File(i,1).D =           hSessMatTemp.D; 
        TP.EX.D.File(i,1).D.Trl =       hFileMatTemp; 
        ttemp = evalc('TP.EX.D.File(i,1).D.Ses.Scan');
        ttemp = ['Scan:' ttemp(9:end)];
            TP.EX.D.File(i,1).SettingsMsg = ttemp;
        ttemp = evalc('TP.EX.D.File(i,1).D.Ses.Image');
        ttemp = ['Image:' ttemp(9:end)];
            TP.EX.D.File(i,1).SettingsMsg = [TP.EX.D.File(i,1).SettingsMsg ttemp];  
        ttemp = TP.EX.D.File(i,1).D.Trl.ScanScheme;
        ttemp = ['Scan Scheme:', char(10), '    ', ttemp, char(10)];
            TP.EX.D.File(i,1).SettingsMsg = [TP.EX.D.File(i,1).SettingsMsg ttemp]; 
        ttemp = TP.EX.D.File(i,1).D.Trl.GRAB;
        ttemp = ttemp.SoundFname;
        tn =    35;
        tl =    ceil(length(ttemp)/tn);
        ttemp = [ttemp char(32*ones(1, tl*tn-length(ttemp)))];
        ttemp = reshape(ttemp, tn, tl);
        ttemp = [char(32*ones(4, tl)); ttemp; char(10*ones(1, tl))];
        ttemp = reshape(ttemp, 1, []);
        ttemp = ['Sound:', char(10), ttemp];
            TP.EX.D.File(i,1).SettingsMsg = [TP.EX.D.File(i,1).SettingsMsg ttemp];      
        TP.EX.D.File(i,1).hFileRec = fopen([TP.EX.Dir.DirString,'\',fnametemp(1:16),'rec'],'r');
    end
    TP.EX.D.CurFileNum = 1;
    SelectFile;

function SelectFile
%% Setup the Selected File and according VlmeList 
global TP
    % Different from FANTASIA('GUI_ScanParameters')
    TP.D =         TP.EX.D.File(TP.EX.D.CurFileNum).D;
    
    TP.D.Ses.Image.NumUpdtPerVlme = 1;    
    TP.D.Ses.Image.NumVlmePerUpdt = 1;
    TP.D.Ses.Image.NumPixlPerUpdt = TP.D.Ses.Scan.NumSmplPerVlme / TP.D.Ses.Scan.NumSmplPerPixl / TP.D.Ses.Image.NumUpdtPerVlme;                                    
    TP.D.Ses.Image.NumSmplPerUpdt = TP.D.Ses.Image.NumSmplPerPixl * TP.D.Ses.Image.NumPixlPerUpdt;
  	TP.D.Ses.Image.NumSmplPerVlme = TP.D.Ses.Image.NumSmplPerUpdt * TP.D.Ses.Image.NumUpdtPerVlme;
    
    TP.EX.D.CurFileNum =    get(TP.EX.UI.H0.hFileList, 'value'); 
    TP.EX.D.CurFileFid =    TP.EX.D.File(TP.EX.D.CurFileNum).hFileRec;    

    % Setup Image Data Releted Structures
    SetupImageD;
    
	TP.EX.UI.H0.hImage = image(...
            TP.D.Vol.LayerDisp{ (TP.D.Ses.Scan.NumLayrPerVlme+1)/2 },...
            'parent',           TP.EX.UI.H0.hAxesImage);
    axis off
    axis image
    box on 
    
    % Setup Rotation Angle
    SetupDispAngle(TP.EX.UI.H0.hAxesAngle);
    
    % Scan Image Parameters Display
    set(TP.EX.UI.H0.hFileText, 'string',...
        TP.EX.D.File(TP.EX.D.CurFileNum).SettingsMsg);
    set(TP.EX.UI.H0.hVlmeList, 'value', 1);
    fseek(TP.EX.D.File(TP.EX.D.CurFileNum).hFileRec, 0, 'eof');
    VlmeNum =  ftell(TP.EX.D.File(TP.EX.D.CurFileNum).hFileRec)/2/653/652;
    fseek(TP.EX.D.File(TP.EX.D.CurFileNum).hFileRec, 0, 'bof');
    TP.EX.D.CurFileVlmeMax = VlmeNum;
    set(TP.EX.UI.H0.hVlmeList, 'string',...
        sprintf(['%0' num2str(floor(log10(VlmeNum)+1)) 'd|'], 1:1:VlmeNum));
    
    SelectVlme;
    
function SelectVlme
%% Setup the Selected Volume
global TP
    TP.EX.D.CurVlmeNum = get(TP.EX.UI.H0.hVlmeList, 'value');
    fseek(TP.EX.D.CurFileFid, ...
        (TP.EX.D.CurVlmeNum-1)*TP.D.Ses.Image.NumSmplPerVlme*2, 'bof');
     
    TP.D.Vol.DataColRaw = ...
        fread(TP.EX.D.CurFileFid, TP.D.Ses.Image.NumSmplPerVlme, 'int16');
    eval(TP.D.Ses.Image.ImgFunc);
      
    if TP.EX.D.ImageDisplayMode
        % Absolute
        a = 2048; 
        b = -8;
    else
        a = max(TP.D.Vol.PixlCol);
        b = min(TP.D.Vol.PixlCol);
    end;
    
    TP.D.Vol.LayerDisp{1}(:,:,2) = ...
        uint8(  (TP.D.Vol.LayerAbs{1}-b)   /(a-b)  *255);
%   	TP.D.Image.VolumeT.LayerDisp{1}(:,:,3) = TP.D.Image.VolumeT.LayerDisp{1}(:,:,1);   
    set(TP.EX.UI.H0.hImage, 'Cdata', ...
        TP.D.Vol.LayerDisp{ (TP.D.Ses.Scan.NumLayrPerVlme+1)/2 } );
    updateImageHistogram(TP.EX.UI.H0.Hist0);
    
function SelectDisplayMode
%% Setup Absolute or Relative Display Mode
global TP
	h = get(TP.EX.UI.H.hImage_DisplayMode_Rocker, 'Children');    
    TP.EX.D.ImageDisplayMode = ...
        get(get(TP.EX.UI.H.hImage_DisplayMode_Rocker,'SelectedObject'),'userdata');
	switch TP.EX.D.ImageDisplayMode
        case 1
            set(TP.EX.UI.H.hImage_DisplayMode_Rocker, 'SelectedObject', h(3));
            set(h(3),   'backgroundcolor', TP.EX.UI.C.SelectB);
            set(h(2),   'backgroundcolor', TP.EX.UI.C.TextBG);
        case 0
            set(TP.EX.UI.H.hImage_DisplayMode_Rocker, 'SelectedObject', h(2));
            set(h(2),   'backgroundcolor', TP.EX.UI.C.SelectB);
            set(h(3),   'backgroundcolor', TP.EX.UI.C.TextBG);
        otherwise   
    end;       
    SelectVlme
    
function SaveVideoAVI
global TP

% for savint through VideoFWriter System object (2015/08/17)

fnametemp = TP.EX.Dir.FileListT(TP.EX.D.CurFileNum).name;
snametemp = TP.D.Trl.GRAB;
snametemp = snametemp.SoundFname;
vnametemp = [TP.EX.Dir.DirString,'\', fnametemp(1:16), 'avi'];
[sounddata, FS] = audioread(snametemp); 
sounddatatype = whos('sounddata');
TP.EX.D.CurVideoObj = vision.VideoFileWriter(vnametemp,...
    'FileFormat',       'AVI',...
    'AudioInputPort',   true,...
    'FrameRate',        TP.D.Ses.Scan.VolumeRate,...
    'VideoCompressor',	'None (uncompressed)',...
    'AudioDataType',    'int16');


% TP.EX.D.CurImgStack = double(TP.D.Vol.LayerAbs{1});
SoundNum = round(FS/TP.D.Ses.Scan.VolumeRate);
% SoundSeq = zeros(444 * SoundNum,1);
SoundSeq = zeros(TP.EX.D.CurFileVlmeMax * SoundNum,1);
SoundSeq(1:length(sounddata)) = sounddata * (strcmp(TP.D.Trl.ScanScheme, 'GRAB'));

for i = 1:TP.EX.D.CurFileVlmeMax
    set(TP.EX.UI.H0.hVlmeList, 'value', i);
    SelectVlme;
    
%     TP.EX.D.ImgSeqBrtns(i) = sum(sum(TP.D.Vol.LayerAbs{1}));
%     TP.EX.D.ImgSeqLayerAbs{i} = TP.D.Vol.LayerAbs{1};
%     TP.EX.D.CurImgStack = TP.EX.D.CurImgStack + double(TP.D.Vol.LayerAbs{1});
    step(   TP.EX.D.CurVideoObj,...
            TP.D.Vol.LayerDisp{1},...
            SoundSeq((i-1)*SoundNum+1:(i-0)*SoundNum)  );
%     waitfor(TP.EX.UI.H0.hImage);
    pause(0.05)
end;

% figure;
% TP.EX.D.CurImgStackD = zeros(size(TP.EX.D.CurImgStack,1), size(TP.EX.D.CurImgStack,2),3);
% TP.EX.D.CurImgStackD(:,:,2) = TP.EX.D.CurImgStack/max(max(TP.EX.D.CurImgStack));
% image(TP.EX.D.CurImgStackD);
release(TP.EX.D.CurVideoObj);


function SaveVideoMP4
global TP

fnametemp = TP.EX.Dir.FileListT(TP.EX.D.CurFileNum).name;
vnametemp = [TP.EX.Dir.DirString,'\', fnametemp(1:16), 'mp4'];
TP.EX.D.CurVideoObj = VideoWriter(vnametemp, 'MPEG-4');
TP.EX.D.CurVideoObj.Quality = 100;
TP.EX.D.CurVideoObj.FrameRate = TP.D.Ses.Scan.VolumeRate;
open(TP.EX.D.CurVideoObj);

TP.EX.UI.H0.hWaitBar = waitbar(0,...
    ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
    num2str(0), ' finished.'],...
    'Name', ['Exporting ', fnametemp(1:16), '.rec to a mp4 video file']);

TP.EX.D.CurImgStack = double(TP.D.Vol.LayerAbs{1});

for i = 1:TP.EX.D.CurFileVlmeMax

    set(TP.EX.UI.H0.hVlmeList, 'value', i);
    SelectVlme;
    
%     TP.EX.D.ImgSeqBrtns(i) = sum(sum(TP.D.Vol.LayerAbs{1}));
%     TP.EX.D.ImgSeqLayerAbs{i} = TP.D.Vol.LayerAbs{1};
%     TP.EX.D.CurImgStack = TP.EX.D.CurImgStack + double(TP.D.Vol.LayerAbs{1});
    writeVideo(TP.EX.D.CurVideoObj, TP.D.Vol.LayerDisp{1});
    TP.EX.UI.H0.hWaitBar = waitbar(...
        i/TP.EX.D.CurFileVlmeMax,...
        TP.EX.UI.H0.hWaitBar,...
        ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
            num2str(i), ' finished.']);
end;
% figure;
% TP.EX.D.CurImgStackD = zeros(size(TP.EX.D.CurImgStack,1), size(TP.EX.D.CurImgStack,2),3);
% TP.EX.D.CurImgStackD(:,:,2) = TP.EX.D.CurImgStack/max(max(TP.EX.D.CurImgStack));
% image(TP.EX.D.CurImgStackD);
close(TP.EX.D.CurVideoObj);
close(TP.EX.UI.H0.hWaitBar);

% =================== Added by Yueqi 5/8/18 (start) ===========================
function SaveImageOne
global TP
% ------------------- select folder for saving tiff -----------------------
TP.EX.Dir.DirSaveString =   uigetdir('D:\=data=\80Z_imaging\img_2p', 'Pick a Directory for saving Tiff files');
% set Tiff name
% TP.EX.Dir.FileList changed to TP.EX.Dir.FileListT in new version of Exporter (5/8/18) by Yueqi 
fnametemp = TP.EX.Dir.FileListT(TP.EX.D.CurFileNum).name; 
vnametemp = num2str(get(TP.EX.UI.H0.hVlmeList, 'value'));
tiffnametemp = [TP.EX.Dir.DirSaveString,'\', fnametemp(1:15), '_', vnametemp,'.tif'];
% ------------------------- if file already exist -------------------------
if exist(tiffnametemp) 
    % popout dialogut window
    choice = questdlg('Tiff file already exist, overwrite or rename?', ...
	'Duplicated file', ...
	'Overwrite','Rename','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Overwrite'
            FIDs = fopen('all');
            if length(FIDs) > 4 % if the object is open in MATLAB, close it. Otherwise delete won't be successful
                fclose(FIDs(end));
            end
            delete(tiffnametemp);    
        case 'Rename'
            prompt={'Enter an alternative file name'};
            name = 'New name for tiff file';
            defaultans = {[fnametemp(1:15), '_', vnametemp]};
            options.Interpreter = 'tex';
            answer = inputdlg(prompt,name,[1 40],defaultans,options);
            tiffnametemp = [TP.EX.Dir.DirSaveString,'\', answer{1}, '.tif'];
        case 'Cancel'
            return
    end
end

SelectVlme
SetupFrame

% ------------------- chose a tiff saving algorithm -----------------
option = 2; % 1 for LibTiff, 2 for TifFantasia
if option == 1
% option 1: use MATLAB LibTiff 
    TP.EX.D.CurTiffObj = Tiff(tiffnametemp,'w');
    % set required tags
    tagTemp.ImageLength = 653;
    tagTemp.ImageWidth = 652;
    tagTemp.Photometric = 1;
    tagTemp.BitsPerSample = 16; % this is not true in the future
    tagTemp.SamplesPerPixel = 1; 
    tagTemp.RowsPerStrip = 16;
    tagTemp.PlanarConfiguration = 1;
    tagTemp.Software = 'FANTASIA';
    setTag(TP.EX.D.CurTiffObj,tagTemp);
    write(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1}); % write selected frame
else
% option 2: use self-defined class based on ScanImage 
    % dateTimeTemp = datestr(TP.D.Trl.TimeStampStopped,'yyyy:mm:dd HH:MM:SS');
    % TP.EX.D.CurTiffObj = TifFantasia(tiffnametemp,652,653,TP.D.Mky.ID,'dateTime',dateTimeTemp);
    TP.EX.D.CurTiffObj = TifFantasia(tiffnametemp,652,653,TP.D);
    appendFrame(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1})
end
close(TP.EX.D.CurTiffObj)
disp(['file ', fnametemp(1:15), '_', vnametemp,' saved!']);


function SaveSessionOne
global TP
% ------------------- select folder for saving tiff -----------------------
TP.EX.Dir.DirSaveString =   uigetdir('D:\=data=\80Z_imaging\img_2p', 'Pick a Directory for saving Tiff files');
% set Tiff name
% TP.EX.Dir.FileList changed to TP.EX.Dir.FileListT in new version of Exporter (5/8/18) by Yueqi 
fnametemp = TP.EX.Dir.FileListT(TP.EX.D.CurFileNum).name;
tiffnametemp = [TP.EX.Dir.DirSaveString,'\', fnametemp(1:15),'.tif'];

% ------------------------- if file already exist -------------------------
if exist(tiffnametemp) 
    % popout dialogut window
    choice = questdlg('Tiff file already exist, overwrite or rename?', ...
	'Duplicated file', ...
	'Overwrite','Rename','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Overwrite'
            FIDs = fopen('all');
            if length(FIDs) > 4 % if the object is open in MATLAB, close it. Otherwise delete won't be successful
                fclose(FIDs(end));
            end
            delete(tiffnametemp);            
        case 'Rename'
            prompt={'Enter an alternative file name'};
            name = 'New name for tiff file';
            defaultans = {fnametemp(1:15)};
            options.Interpreter = 'tex';
            answer = inputdlg(prompt,name,[1 40],defaultans,options);
            tiffnametemp = [TP.EX.Dir.DirSaveString,'\', answer{1}, '.tif'];
        case 'Cancel'
            return
    end
end
set(TP.EX.UI.H0.hVlmeList, 'value', 1);
SelectVlme;
SetupFrame; 

% ------------------- chose a tiff saving algorithm --------------
option = 2; % 1 for LibTiff, 2 for TifFantasia (fastest), 3 for saveastiff (slowest)
tic
% ------------------- set the first frame -----------------
if option == 1    
% option 1: use MATLAB LibTiff 
    TP.EX.D.CurTiffObj = Tiff(tiffnametemp,'w');
    % set required tags
    tagTemp.ImageLength = 653;
    tagTemp.ImageWidth = 652;
    tagTemp.Photometric = 1;
    tagTemp.BitsPerSample = 16;
    tagTemp.SamplesPerPixel = 1;
    tagTemp.RowsPerStrip = 16;
    tagTemp.PlanarConfiguration = 1;
    tagTemp.Software = 'FANTASIA';
    setTag(TP.EX.D.CurTiffObj,tagTemp);
    write(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1}); 
    
else
% option 2: use self-defined class based on ScanImage 
    % ts = TifFantasia(filename, frameWidth, frameHeight, imageDescription, Property1, Value1, ...)
    % dateTimeTemp = datestr(TP.D.Trl.TimeStampStopped,'yyyy:mm:dd HH:MM:SS');
    TP.EX.D.CurTiffObj = TifFantasia(tiffnametemp,652,653,TP.D);
    appendFrame(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1});
end

% progress bar
TP.EX.UI.H0.hWaitBar = waitbar(0,...
    ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
    num2str(0), ' finished.'],...
    'Name', ['Exporting ', fnametemp(1:16), '.rec to a tiff file']);

disp(['file ', fnametemp(1:15),' started...'])

% ------------------- set appending frames -----------------
for i = 2:TP.EX.D.CurFileVlmeMax % start from 2nd frame
    set(TP.EX.UI.H0.hVlmeList, 'value', i);
    SelectVlme;
    SetupFrame;
    
    if option == 1
    % option 1: use MATLAB LibTiff 
    
        writeDirectory(TP.EX.D.CurTiffObj);
        setTag(TP.EX.D.CurTiffObj,tagTemp)
        write(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1}); 

    else
    % option 2: use self-defined class based on ScanImage
        appendFrame(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1});

    end
    
    % progress bar updated every 100 frames
    if mod(i,100) == 0
        waitbar(...
        i/TP.EX.D.CurFileVlmeMax,...
        TP.EX.UI.H0.hWaitBar,...
        ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
        num2str(i), ' finished.']);
    end

end

close(TP.EX.UI.H0.hWaitBar);
close(TP.EX.D.CurTiffObj)
 
disp(['file ', fnametemp(1:15),' saved!']);
toc


function SaveSessionAll
global TP

% ------------------- select folder for saving tiff -----------------------
TP.EX.Dir.DirSaveString =   uigetdir('D:\=data=\80Z_imaging\img_2p', 'Pick a Directory for saving Tiff files');

for k = 1:length(TP.EX.Dir.FileListT)

    % set Tiff name
    % TP.EX.Dir.FileList changed to TP.EX.Dir.FileListT in new version of Exporter (5/8/18) by Yueqi 
    set(TP.EX.UI.H0.hFileList, 'value', k); % iterate through different sessions
    SelectFile;
    
    fnametemp = TP.EX.Dir.FileListT(TP.EX.D.CurFileNum).name;
    tiffnametemp = [TP.EX.Dir.DirSaveString,'\', fnametemp(1:15),'.tif'];

    % ------------------------- if file already exist -------------------------
    if exist(tiffnametemp) 
        % popout dialogut window
        choice = questdlg(['File ', fnametemp(1:15), ' already exist, overwrite or rename?'], ...
        'Duplicated file', ...
        'Overwrite','Rename','Cancel','Cancel');
        % Handle response
        switch choice
            case 'Overwrite'
                FIDs = fopen('all');
                if length(FIDs) > 4 % if the object is open in MATLAB, close it. Otherwise delete won't be successful
                    fclose(FIDs(end));
                end
                delete(tiffnametemp);            
            case 'Rename'
                prompt={'Enter an alternative file name'};
                name = 'New name for tiff file';
                defaultans = {fnametemp(1:15)};
                options.Interpreter = 'tex';
                answer = inputdlg(prompt,name,[1 40],defaultans,options);
                tiffnametemp = [TP.EX.Dir.DirSaveString,'\', answer{1}, '.tif'];
            case 'Cancel'
                return
        end
    end
    set(TP.EX.UI.H0.hVlmeList, 'value', 1); % start from first frame
    SelectVlme;
    SetupFrame; 

    % ------------------- chose a tiff saving algorithm --------------
    option = 2; % 1 for LibTiff, 2 for TifFantasia (fastest), 3 for saveastiff (slowest)
    tic
    % ------------------- set the first frame -----------------
    if option == 1    
    % option 1: use MATLAB LibTiff 
        TP.EX.D.CurTiffObj = Tiff(tiffnametemp,'w');
        % set required tags
        tagTemp.ImageLength = 653;
        tagTemp.ImageWidth = 652;
        tagTemp.Photometric = 1;
        tagTemp.BitsPerSample = 16;
        tagTemp.SamplesPerPixel = 1;
        tagTemp.RowsPerStrip = 16;
        tagTemp.PlanarConfiguration = 1;
        tagTemp.Software = 'FANTASIA';
        setTag(TP.EX.D.CurTiffObj,tagTemp);
        write(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1}); 

    else
    % option 2: use self-defined class based on ScanImage 
        % ts = TifFantasia(filename, frameWidth, frameHeight, imageDescription, Property1, Value1, ...)
        % dateTimeTemp = datestr(TP.D.Trl.TimeStampStopped,'yyyy:mm:dd HH:MM:SS');
        TP.EX.D.CurTiffObj = TifFantasia(tiffnametemp,652,653,TP.D);
        appendFrame(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1});
    end

    % progress bar
    TP.EX.UI.H0.hWaitBar = waitbar(0,...
        ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
        num2str(0), ' finished.'],...
        'Name', ['Exporting ', fnametemp(1:16), '.rec to a tiff file']);

    disp(['file ', fnametemp(1:15),' started...'])

    % ------------------- set appending frames -----------------
    for i = 2:TP.EX.D.CurFileVlmeMax % start from 2nd frame
        set(TP.EX.UI.H0.hVlmeList, 'value', i);
        SelectVlme;
        SetupFrame;

        if option == 1
        % option 1: use MATLAB LibTiff 
            writeDirectory(TP.EX.D.CurTiffObj);
            setTag(TP.EX.D.CurTiffObj,tagTemp)
            write(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1}); 
        else
        % option 2: use self-defined class based on ScanImage
            appendFrame(TP.EX.D.CurTiffObj,TP.D.Vol.Frame{1});
        end

        % progress bar updated every 100 frames
        if mod(i,100) == 0
            waitbar(...
            i/TP.EX.D.CurFileVlmeMax,...
            TP.EX.UI.H0.hWaitBar,...
            ['Totally ', num2str(TP.EX.D.CurFileVlmeMax), ' frames, ',...
            num2str(i), ' finished.']);
        end
    end

    close(TP.EX.UI.H0.hWaitBar);
    close(TP.EX.D.CurTiffObj)
 
    disp(['file ', fnametemp(1:15),' saved!']);
    toc
    
end
disp(['========= All sessions are saved! ==========='])
% =================== Added by Yueqi 5/8/18 (end) ===========================


