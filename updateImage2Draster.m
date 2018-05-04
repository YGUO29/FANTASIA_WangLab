function updateImage2Draster
% The function processes the raw data in	TP.D.Vol.DataRaw,
% and puts the processed absolute image to  TP.D.Vol.LayerAbs{i}
% for 2D sweep mode

global TP
 
%% Data Formmating & Pixelizing
    TP.D.Vol.DataColFlt = -single(TP.D.Vol.DataColRaw); % convert to single to save memory -----------------------has to be floating point numbers to do "mean"?

% if #sample/pix is not 1, average every "#sample/pix" adjacent samples as
% one pixel
    if TP.D.Ses.Image.NumSmplPerPixl == 1 % update every scan
        TP.D.Vol.PixlCol = TP.D.Vol.DataColFlt;
    else % update every "NumSmplPerPixl" scans, each frame is the mean of "NumSmplPerPixl" scans
        TP.D.Vol.PixlSmplMat = ...
            reshape(	TP.D.Vol.DataColFlt,...
                        TP.D.Ses.Image.NumSmplPerPixl, ...
                        TP.D.Ses.Image.NumPixlPerUpdt)';
        TP.D.Vol.PixlCol = ...
            mean(       TP.D.Vol.PixlSmplMat(:,1:end),2); 
    end;
 
%% Updating Normalization

% if #volume/update is not one, average every "#volume/update" volumes as
% one updated frame
    if TP.D.Ses.Image.NumVlmePerUpdt == 1
        TP.D.Vol.PixlCol2 = TP.D.Vol.PixlCol;
    else
        TP.D.Vol.PixlSmplMat2 = ...
            reshape(    TP.D.Vol.PixlCol, ...
                        TP.D.Ses.Image.NumPixlPerUpdt / TP.D.Ses.Image.NumVlmePerUpdt, ...
                        TP.D.Ses.Image.NumVlmePerUpdt);
        TP.D.Vol.PixlCol2 = ...
             mean(   	TP.D.Vol.PixlSmplMat2(:,1:end),2);
    end;
                    

%% Descanning Image
% TP.D.Vol.LayerAbsRaw{1} is pre-defined as a 653x652 matrix, so using a
% linear index here to convert column pixels to matrix
 	TP.D.Vol.LayerAbsRaw{1}(...
        TP.D.Ses.Scan.ScanInd{1}.Ind ...
                                        ) =...
        TP.D.Vol.PixlCol2; 
% LayerAbsRaw is now a matrix with pixels aligned in the image order    

% ------------------------------------------------------------------------------ deal with image edges ?????
    TP.D.Vol.LayerAbs{1} = [...
        TP.D.Vol.LayerAbsRaw{1}(...
            end-TP.D.Ses.Image.NumPixlPerEdge+1:end,	end-TP.D.Ses.Image.NumPixlPerEdge+1:end ),...
        TP.D.Vol.LayerAbsRaw{1}(...
            end-TP.D.Ses.Image.NumPixlPerEdge+1:end,	1:end-TP.D.Ses.Image.NumPixlPerEdge );...
        TP.D.Vol.LayerAbsRaw{1}(...
            1:end-TP.D.Ses.Image.NumPixlPerEdge,	end-TP.D.Ses.Image.NumPixlPerEdge+1:end ),...
        TP.D.Vol.LayerAbsRaw{1}(...
        	1:end-TP.D.Ses.Image.NumPixlPerEdge,	1:end-TP.D.Ses.Image.NumPixlPerEdge )];