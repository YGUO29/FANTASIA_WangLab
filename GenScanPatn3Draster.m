function [ScanSeq, ScanInd] = GenScanPatn3Draster(...
    NumSmplPerPixlScan,     NumSmplPerPixlImage, ...
    NumPixlPerAxis, ...
	NumLayrPerVlme,         LayrSpacingInZ, ...
    FreqCF, FreqBW ...
    )
% This function generate a divergence beam scanning partern for 2D diagonal
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
NumL =      NumLayrPerVlme;
LayrS =     LayrSpacingInZ;
% FreqCF =    FreqCF;
% FreqBW =    FreqBW;

%% Generate Layer Sequence
load('Zdepth10x.mat')
LayerDepth =    (-LayrS*(NumL-1)/2):LayrS:(LayrS*(NumL-1)/2);   % in um
ScanSeq =       [];
PixelStartT =   0;

for i = 1:NumL
% for each layer

    % Determine the NumPixlPerAxis for Current layer
    RowNum =    find(Zdepth10x(:,1)==LayerDepth(i));
    NumPC = 	Zdepth10x(RowNum, 3);
    NumPIpad =  ceil(NumPC/2);          % image pixel index padding length
    NumSSpad =  NumPIpad * NumSS;    	% scan sample padding length
    
    % Generate raw scanning data
    [ScanSeqCL{i}, ScanIndCLT] = GenScanPatn2Draster(...
            NumSS,  NumSI,	NumPC,	1,  NaN,    FreqCF,	FreqBW );
    ScanIndCL{i} = ScanIndCLT{1};
        
    % Patch the ScanSeq, 
    %   Each ScanSeq for CurrentLayer is Padded for edge consistentcy
    %   The joined together as the full ScanSeq
    ScanSeqCL{i} = [...
        ScanSeqCL{i}(end-NumSSpad+1:end);
        ScanSeqCL{i}; 
     	ScanSeqCL{i}(1:NumSSpad)];
    ScanSeq = [ScanSeq; ScanSeqCL{i}];
    
    % Patch the ScanInd
    %   Label the 3D Z depth, and theoretical depth error
    %   Padding edge length
    %   Pixl start & stop positions in the PixlCol2
    ScanIndCL{i}.LayrDepth =        Zdepth10x(RowNum, 1);
    ScanIndCL{i}.LayrDepthError =   Zdepth10x(RowNum, 2); 
    ScanIndCL{i}.NumPixlPerAxis =  	ScanIndCL{i}.NumPixlPerAxis;
    ScanIndCL{i}.PixlPadded =   NumPIpad;
    ScanIndCL{i}.PixlStart =	PixelStartT + NumPIpad  + 1;    
    ScanIndCL{i}.PixlStop =   	PixelStartT + NumPIpad  + ScanIndCL{i}.PixlLength;
        PixelStartT =           PixelStartT + 2*NumPIpad+ ScanIndCL{i}.PixlLength;
    ScanIndCL{i}.Ind =          ScanIndCL{i}.Ind;
    ScanInd{i} = ScanIndCL{i};
end


%% LOG MSG
msg = [ datestr(now) '\tGenScanPatn3Draster\t',...
        num2str(NumP-1),'x',num2str(NumP),' Pixels Scan Pattern Generated\r\n'];
global TP;
% fprintf( TP.D.Sys.PC.hLog,   msg);
