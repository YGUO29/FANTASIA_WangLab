function updateImageHistogram(phandle)
% The function computes the pixel birghtness histogram in the
%   TP.D.Vol.PixelColumn
% and output the CData onto phandle 
% (xx ms/xx ms) are time on T3500/T5810

% ~50, 47-104 ms for 2D random 256p     on T5810
% ~11, 8-22 ms for 2D raster 653p       on T5810

% 0.03 ms
global TP
persistent pixelhisttemp
persistent peakhist
persistent binpeak
persistent binmin
persistent binmax

% ~1 ms for 2D random 256p      on T5810
% ~3 ms for 2D raster 1s/px     on T5810
pixelhisttemp = histc(  TP.D.Vol.DataColFlt,...
                        TP.D.Vol.PixelHistEdges);

% 0.03 ms                       on T5810
[peakhist, binpeak] =   max(pixelhisttemp);
binmin =                find(pixelhisttemp, 1, 'first');
binmax =                find(pixelhisttemp, 1, 'last');
pixelhisttemp =         pixelhisttemp/peakhist;
TP.D.Vol.PixelHist =    pixelhisttemp;

%% Update Histogram
% 3-9 ms for 2D random 256p     on T5810
% ~4 ms for 2D raster 1s/px     on T3500
set(phandle.hBarHist,   'Ydata',    TP.D.Vol.PixelHist);

%% Update MarkDot
% 0.04 ms for 2D random 256p   	on T5810  
% 0.08 ms                       on T3500
set(phandle.hMarkMax,   'xdata',	binmax);
set(phandle.hMarkMin,   'xdata',    binmin);
set(phandle.hMarkPeak,  'xdata',    binpeak);

%% Update Text
% 4 ms for 2D random 256p       on T5810
% 0.7  ms for 2D raster 1s/px  	on T5810   
% 0.47 ms for 2D raster 1s/px 	on T3500
TP.D.Vol.SampleMax =    -min(TP.D.Vol.DataColFlt);
TP.D.Vol.SampleMin =    -max(TP.D.Vol.DataColFlt);
TP.D.Vol.SampleMean =   mean(TP.D.Vol.PixlCol)/TP.D.Ses.Image.NumSmplPerPixl;

% 2 ms for	2D random 256p  	on T5810
% 0.40 ms                       on T3500
set(phandle.hTextMax,   'string',   sprintf('%d',   TP.D.Vol.SampleMax) );
set(phandle.hTextMin,   'string',   sprintf('%d',   TP.D.Vol.SampleMin) );
set(phandle.hTextPeak,  'string',   [sprintf('%d',(binpeak-44)*8),'-',sprintf('%d',(binpeak-43)*8)] );
set(phandle.hTextMean,  'string',   sprintf('%5.1f', TP.D.Vol.SampleMean) );
