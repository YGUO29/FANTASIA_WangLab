function [ScanSeq, ScanInd] = GenScanPatn2DrandomFullRandom(...
    NumSmplPerPixlScan,     NumSmplPerPixlImage, ...
    NumPixlPerAxis, ...
	NumLayrPerVlme,         LayrSpacingInZ, ...
    FreqCF, FreqBW ...
    )
% This function generate a full frame scanning partern for 2D random access
%  scanning mode, following a "randomized" pixel arrangement, to potentially 
%  reduce crosstalk between adjacent pixels during scanning jump
% S is TP.D.Scan
% ScanSeq is a sequence of 32 bit samples for AOD scanning control
%   check AA DDSPA-B415b-0 for line definition
% ScanInd is the a linear reconstruction index for pixel rearrangement

global TP;

NumSS =     NumSmplPerPixlScan;
NumSI =     NumSmplPerPixlImage;
NumP =      NumPixlPerAxis;
FreqCF =    FreqCF / 1e6;
FreqBW =    FreqBW / 1e6;

%% Generate Scan pixel Look Up Table (LUT) for the layer 
% layer 0 (only 1 layer for 2D scanning mode)
% [X Y] pixel #, e.g.
% NumP = 1, ScanLUT = [ 1 1];
% NumP = 3, ScanLUT = [ 1 1;    2 1;    3 1;
%                       1 2;    2 2;    3 2;
%                       1 3;    2 3;    3 3];
ScanLUT = [ repmat((1:NumP)', NumP,1)...
            reshape(ones(NumP,1)*(1:NumP),[],1) ];
permindex = randperm(length(ScanLUT));
ScanLUT = ScanLUT(permindex,:);

%% Generate the Linear Reconstruction Index for Pixel Rearrangement
% layer 0 (only 1 layer for 2D scanning mode)
% LayrNum=0 means Z bias=0, LayrNum=-1 means deeper, 1 means upper
ScanInd{1}.LayrDepth =          0;
ScanInd{1}.PixlLength =         length(ScanLUT);
ScanInd{1}.SmplLengthScan =     ScanInd{1}.PixlLength * NumSS;
ScanInd{1}.SmplLengthImage =  	ScanInd{1}.PixlLength * NumSI;
ScanInd{1}.Ind =                uint32(sub2ind([NumP NumP], ScanLUT(:,1), ScanLUT(:,2)));

%% Generate Scan Sequence Data
% [X Y] normalized to [-FreqBW/2 FreqBW/2] range
% NumP = 1, ScanSeqF = [	0   0   ];
% NumP = 3, ScanSeqF = [    -1  -1;     0	-1;     1   -1;
%                           -1  0;      0   0;      1   0;
%                           -1  1;      0   1;      1   1];
ScanSeqF = (ScanLUT(:,1:2)-(NumP+1)/2) / max(0.5, (NumP-1)/2);

% [X Y] to absolute Scan frequency, in [FreqC-FreqBW/2 FreqC+FreqBW/2] range
ScanSeqF = FreqCF + FreqBW/2*ScanSeqF;

% [X Y] to 15bit code,  F(MHz) = N*500/2^15,    N = F(MHz)*2^15/500,
ScanSeqFu = uint32(ScanSeqF*2^15/500);

% [X Y] to 16bit code, the bit 16 is change enabling flag
ScanSeqFu = ScanSeqFu + 2^15;

% [X+Y] to 32bit code, port0:1 is Y, port2:3 is X
ScanSeqFu = ScanSeqFu(:,1)*2^16 + ScanSeqFu(:,2); 

% repitition of each pixel by NumS (# of 6536 samples per pixel)
ScanSeq = reshape(repmat(ScanSeqFu', NumSS, 1),[],1);

%% LOG MSG
msg = [ datestr(now) '\tGenScanPatn2DrandomFullRandom\t',...
        num2str(NumP),'^2 Pixels Scan Pattern Generated\r\n'];
fprintf( TP.UI.H0.log,   msg);