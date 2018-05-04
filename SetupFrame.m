function SetupFrame
% setup frame for tiff files, one at a time, 16-bit

global TP
 
%% Data Formmating & Pixelizing
% calculation speed no significant difference with int16/uint16/double
    DataColFlt = - TP.D.Vol.DataColRaw; % choise 1: int16 (from -2047 to 2048)
%     DataColFlt = uint16(TP.D.Vol.DataColRaw - min(TP.D.Vol.DataColRaw)); % choice 2: use uint16
%     DataColFlt = - TP.D.Vol.DataColRaw; % choice 3: use double 
%     DataColFlt = -single(TP.D.Vol.DataColRaw); % choice 4: use single 
    
   

% if #sample/pix is not 1, add up every "#sample/pix" adjacent samples as
% one pixel
    if TP.D.Ses.Image.NumSmplPerPixl == 1 % update every scan
        PixlCol = DataColFlt;
    else % update every "NumSmplPerPixl" scans, each frame is the mean of "NumSmplPerPixl" scans
        PixlSmplMat = ...
            reshape(	DataColFlt,...
                        TP.D.Ses.Image.NumSmplPerPixl, ...
                        TP.D.Ses.Image.NumPixlPerUpdt)';
        PixlCol = ...
            sum(       PixlSmplMat(:,1:end),2,'native');  % native to keep int16 data type
        
    end;
 
%% Updating Normalization

% if #volume/update is not one, add up every "#volume/update" volumes as
% one updated frame
    if TP.D.Ses.Image.NumVlmePerUpdt == 1
        PixlCol2 = PixlCol;
    else
        PixlSmplMat2 = ...
            reshape(    PixlCol, ...
                        TP.D.Ses.Image.NumPixlPerUpdt / TP.D.Ses.Image.NumVlmePerUpdt, ...
                        TP.D.Ses.Image.NumVlmePerUpdt);
        PixlCol2 = ...
             sum(   	PixlSmplMat2(:,1:end),2,'native');
    end;
                    
%% from int16 to uint16
%      PixlCol2 = uint16(PixlCol2 - min(PixlCol2));
% ==== 5/1/18 by Yueqi====
% ==== the method above converts the image to relative magnitudes ====
PixlCol2 = uint16(double(PixlCol2) + ones(size(PixlCol2)).*2^15);


%% Descanning Image
% TP.D.Vol.LayerAbsRaw{1} is pre-defined as a 653x652 matrix, so using a
% linear index here to convert column pixels to matrix
    FrameRaw = zeros(  TP.D.Ses.Scan.NumPixlPerAxis,...
                        TP.D.Ses.Scan.NumPixlPerAxis-1, ...
                                                        'uint16');
 	FrameRaw(...
        TP.D.Ses.Scan.ScanInd{1}.Ind ...
                                        ) =...
        PixlCol2; 

    % LayerAbsRaw is now a matrix with pixels aligned in the image order    
     TP.D.Vol.Frame{1} = [...
        FrameRaw(...
            end-TP.D.Ses.Image.NumPixlPerEdge+1:end,	end-TP.D.Ses.Image.NumPixlPerEdge+1:end ),...
        FrameRaw(...
            end-TP.D.Ses.Image.NumPixlPerEdge+1:end,	1:end-TP.D.Ses.Image.NumPixlPerEdge );...
        FrameRaw(...
            1:end-TP.D.Ses.Image.NumPixlPerEdge,	end-TP.D.Ses.Image.NumPixlPerEdge+1:end ),...
        FrameRaw(...
        	1:end-TP.D.Ses.Image.NumPixlPerEdge,	1:end-TP.D.Ses.Image.NumPixlPerEdge )];


end