function FinishAngle = updatePowerRotCheck(h, TargetAngle, ErrorRange)
% Check the APT rotatory motor angle
global TP
FinishAngle = h.GetPosition_Position(0);
if abs(FinishAngle - TargetAngle) > ErrorRange && ...
    abs(FinishAngle - TargetAngle) - 360 > ErrorRange
        warndlg('The rotatory motor is not in the tolerable position range');
        pause;
else
    a = TP.D.Sys.Power.C.HWP_pmin;
    b = TP.D.Sys.Power.C.HWP_pmax;
    c = TP.D.Sys.Power.C.HWP_pmaxAngle;
    pS121C = 1000*( a+ (b-a)/2*(1+cos((FinishAngle-c)/45*pi)) );
    TP.D.Mon.Power.PmaxAtCurAngle = ...
        TP.D.Sys.Power.C.ARM_p1 * pS121C + TP.D.Sys.Power.C.ARM_p2;
    set( TP.UI.H.hMon.Power_PmaxAtCurAngle_Edit, 'string', ...
        sprintf('%5.1f',TP.D.Mon.Power.PmaxAtCurAngle) );
end;