function updatePowerRotMove(h, TargetAngle, TimeOut)
% Move the APT rotatory motor angle

h.SetAbsMovePos(0,TargetAngle);
h.MoveAbsolute(0,0);
StartTime = clock;
while(etime(clock,StartTime)<TimeOut) 
    % wait while the motor is active; timeout to avoid dead loop
    MotorStatus = h.GetStatusBits_Bits(0);
    pause(0.2);     % wait
    if bitget(abs(MotorStatus),5)&&bitget(abs(MotorStatus),6)== 1
        
        % Xindong's note: here the bit definition seems totally opposite in the
        % thorlbas matlab manual and examples.
        
        % Read StatusBits returned by GetStatusBits_Bits method and determine if
        % the motor shaft is moving; Return 1 if moving, return 0 if stationary
        break;
    end
end