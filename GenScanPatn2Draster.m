function [ScanSeq, ScanInd] = GenScanPatn2Draster(...
    NumSmplPerPixlScan,     NumSmplPerPixlImage, ...
    NumPixlPerAxis, ...
	NumLayrPerVlme,         LayrSpacingInZ, ...
    FreqCF, FreqBW ...
    )
% This function generate a divergent beam scanning partern for 2D diagonal
%  raster scanning mode
% ScanSeq is a sequence of 32 bit samples for AOD scanning control
%   check AA DDSPA-B415b-0 for line definition
% ScanInd{i} is a struct for the layer(i)
%   .LayrDepth          Relative depth from the nominal focal plane
%   .LayrDepthError     Relative theoretical depth error   
%   .NumPixlPerAxis     Number of Pixel Per Axis
%   .PixlLength         Total Pixel Number for Imaging Part
%   .PixlStart          1           for 2D raster
%   .PixlStop           PixlLength  for 2D raster
%   .Ind                linear reconstruction index for pixel rearrangement

NumSS =     NumSmplPerPixlScan;     % should be 2
NumSI =     NumSmplPerPixlImage;    % usually is 1
NumP =      NumPixlPerAxis;
if NumLayrPerVlme~=1
    errordlg('Check the NumberLayerPerVolume parameter, it should be 1 for 2D');
end;
if ~isnan(LayrSpacingInZ)
    errordlg('Check the LayrSpacingInZ parameter, it should be NaN for 2D');
end;
FreqCF =    FreqCF / 1e6;
FreqBW =    FreqBW / 1e6;

%% Generate Scan pixel Look Up Table (LUT) for the layer 
% (only 1 layer for 2D scanning mode)
% [X Y] pixel #, e.g.
% NumP = 1, ScanLUT = [ 1 1];
% NumP = 3, ScanLUT = [ 1 1;    2 1;    3 1;
%                       1 2;    2 2;    3 2;
%                       1 3;    2 3;    3 3];
ScanLUT = [ repmat((NumP:-1:1)', NumP-1,1)...
            repmat((NumP-1:-1:1)', NumP,1) ];
        
%% Generate the Linear Reconstruction Index for Pixel Rearrangement
% layer 0 (only 1 layer for 2D scanning mode)
% LayrNum=0 means Z bias=0, LayrNum=-1 means deeper, 1 means upper
ScanInd{1}.LayrDepth =          NaN;  % it can be off, further calculation needed
ScanInd{1}.LayrDepthError =  	NaN;
ScanInd{1}.NumPixlPerAxis =     NumP;
ScanInd{1}.PixlLength =         length(ScanLUT);
ScanInd{1}.PixlPadded =         NaN;
ScanInd{1}.PixlStart =          1;
ScanInd{1}.PixlStop =           ScanInd{1}.PixlLength;
ScanInd{1}.Ind =                uint32(sub2ind([NumP NumP-1], ScanLUT(:,1), ScanLUT(:,2)));

%% Generate Scan Sequence Data
% Number of Samples per Line in y / x
NumSpLx = NumSS * NumP;      % sNumSpLy = NumSS * (NumP-1);      

% (X,Y) scan sequence in [FreqC-FreqBW/2 FreqC+FreqBW/2]
%   chirping speed of both axes need to be exactly the same to keep the 
%   focus in the same plane
% X is in [FreqC-FreqBW/2 FreqC+FreqBW/2] range
% Y is totally one pixel short, cut from the f+ side first
ScanSeqFpLx = linspace( FreqCF+FreqBW/2, FreqCF-FreqBW/2, NumSpLx)';
ScanSeqFpLy = ScanSeqFpLx(1+ceil(NumSS/2):end-floor(NumSS/2));      
        
% [X Y] to absolute Scan frequency
% (NumP  	pixels on X) is scanned for NumP-1	times
% (NumP-1 	pixels on Y) is scanned for NumP 	times
ScanSeqF = [    repmat(ScanSeqFpLx, NumP-1,1)...
                repmat(ScanSeqFpLy, NumP,1)];

% [X Y] to 15bit code,  F(MHz) = N*500/2^15,    N = F(MHz)*2^15/500,
ScanSeqFu = uint32(ScanSeqF*2^15/500);

% [X Y] to 16bit code, the bit 16 is change enabling flag
ScanSeqFu = ScanSeqFu + 2^15;

% [X+Y] to 32bit code, port0:1 is Y, port2:3 is X
ScanSeq = ScanSeqFu(:,1)*2^16 + ScanSeqFu(:,2); 

%% LOG MSG
msg = [ datestr(now) '\tGenScanPatn2Draster\t',...
        num2str(NumP-1),'x',num2str(NumP),' Pixels Scan Pattern Generated\r\n'];
global TP;
% fprintf( TP.D.Sys.PC.hLog,   msg);
