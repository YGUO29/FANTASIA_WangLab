%% test image registration
global TP
FixedImgNum = 100;
[optimizer, metric] = imregconfig('monomodal');
figure;
pause;


for i = 10:TP.EX.D.CurFileVlmeMax

    subplot(1,3,1);
    imshowpair(TP.EX.D.ImgSeqLayerAbs{i},       TP.EX.D.ImgSeqLayerAbs{FixedImgNum});
    title(['Unregistered, frame:#', num2str(i)]);

    subplot(1,3,2);    
    tic
    TP.EX.D.ImgSeqLayerAbsRegT{i} = imregister(...
        TP.EX.D.ImgSeqLayerAbs{i},  TP.EX.D.ImgSeqLayerAbs{FixedImgNum},...
        'translation',  optimizer, metric);
    t = toc;
    imshowpair(TP.EX.D.ImgSeqLayerAbsRegT{i},   TP.EX.D.ImgSeqLayerAbs{FixedImgNum});
    title(['Registered(Translation),, frame processed in:', num2str(t),' sec']);

	subplot(1,3,3);    
    tic
    TP.EX.D.ImgSeqLayerAbsRegA{i} = imregister(...
        TP.EX.D.ImgSeqLayerAbs{i},  TP.EX.D.ImgSeqLayerAbs{FixedImgNum},...
        'affine',  optimizer, metric);
    t = toc;
    imshowpair(TP.EX.D.ImgSeqLayerAbsRegA{i},   TP.EX.D.ImgSeqLayerAbs{FixedImgNum});
    title(['Registered(Affine), frame processed in:', num2str(t),' sec']);

    pause(0.1);
    
    TP.EX.D.CurImgStackReg = TP.EX.D.CurImgStackReg + double(TP.EX.D.ImgSeqLayerAbsRegT{i});
end;


TP.EX.D.ImgStackRegT = TP.EX.D.ImgSeqLayerAbs{100}*0;
TP.EX.D.ImgStackRegA = TP.EX.D.ImgSeqLayerAbs{100}*0;
for i = 10:TP.EX.D.CurFileVlmeMax
    TP.EX.D.ImgStackRegT = TP.EX.D.ImgStackRegT + TP.EX.D.ImgSeqLayerAbsRegT{i};
    TP.EX.D.ImgStackRegA = TP.EX.D.ImgStackRegA + TP.EX.D.ImgSeqLayerAbsRegA{i};
end

figure;
subplot(1,2,1);
TP.EX.D.ImgStackRegDispT = zeros(size(TP.EX.D.ImgStackRegT,1), size(TP.EX.D.ImgStackRegT,2),3);
% TP.EX.D.ImgStackRegDispT(:,:,2) = TP.EX.D.ImgStackRegT/max(max(TP.EX.D.ImgStackRegT))476f;
image(TP.EX.D.ImgStackRegDispT);

subplot(1,2,2);
TP.EX.D.ImgStackRegDispA = zeros(size(TP.EX.D.ImgStackRegA,1), size(TP.EX.D.ImgStackRegA,2),3);
TP.EX.D.ImgStackRegDispA(:,:,2) = TP.EX.D.ImgStackRegA/max(max(TP.EX.D.ImgStackRegA));
image(TP.EX.D.ImgStackRegDispA);
