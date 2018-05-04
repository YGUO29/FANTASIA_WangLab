function updateImage3Draster
% The function processes the raw data in	TP.D.Vol.DataRaw,
% and puts the processed absolute image to  TP.D.Vol.LayerAbs{i}
% for 2D sweep mode

global TP
 
%% Data Formmating & Pixelizing
    TP.D.Vol.DataColFlt = -single(TP.D.Vol.DataColRaw);

    if TP.D.Ses.Image.NumSmplPerPixl == 1
        TP.D.Vol.PixlCol = TP.D.Vol.DataColFlt;
    else
        TP.D.Vol.PixlSmplMat = ...
            reshape(	TP.D.Vol.DataColFlt,...
                        TP.D.Ses.Image.NumSmplPerPixl, ...
                        TP.D.Ses.Image.NumPixlPerUpdt)';
        TP.D.Vol.PixlCol = ...
            mean(       TP.D.Vol.PixlSmplMat(:,1:end),2);
    end;

    
%% Splitting different layers
    for i = 1:TP.D.Ses.Scan.NumLayrPerVlme

        % Descanning Image
        TP.D.Vol.LayerAbsRaw{i}(...
            TP.D.Ses.Scan.ScanInd{i}.Ind ...
                                            ) =...
            TP.D.Vol.PixlCol(...
                TP.D.Ses.Scan.ScanInd{i}.PixlStart:...
                TP.D.Ses.Scan.ScanInd{i}.PixlStop);

        % Patch the edge, TBD
        TP.D.Vol.LayerAbs{i}= ... 
            TP.D.Vol.LayerAbsRaw{i};
        
    end;                


