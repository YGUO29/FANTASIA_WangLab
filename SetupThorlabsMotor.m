function msg = SetupThorlabsMotor
% This function setup Thorlabs Power Meter
% as defined in SetupD

%% import handles and data
global TP

%% Motorized Precision Rotation Mount, PRM1Z8
% https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=2875
% try
	TP.UI.H0.hFigPRM1Z8 = ...
        figure(     'Position',     [100 100 650 450],...
                    'Menu',         'None',...
                    'Name',         'PRM1Z8 APT GUI',...
                    'Visible',      'off');
    TP.HW.Thorlabs.hPRM1Z8 = ...
        actxcontrol('MGMOTOR.MGMotorCtrl.1',...
                    [20 20 600 400 ],...
                    TP.UI.H0.hFigPRM1Z8);
	set(TP.HW.Thorlabs.hPRM1Z8,...
                    'HWSerialNum',  TP.D.Sys.Power.HWProtatorID);

    
    TP.HW.Thorlabs.hPRM1Z8.StartCtrl;
%     updatePowerRotMove(	TP.HW.Thorlabs.hPRM1Z8, 0,  40);
%     updatePowerRotCheck(TP.HW.Thorlabs.hPRM1Z8, 0,  0.003);
    
% catch
%     warndlg('Can not setup Thorlabs Motor PRM1Z8');
%     feval('FANTASIA','GUI_CleanUp');
% end;

    % TP.HW.Thorlabs.hPRM1Z8.methods   
%     TP.HW.Thorlabs.hPRM1Z8.SetAbsMovePos(0,TP.HW.Thorlabs.hPRM1Z8.GetPosition_Position(0)+10);
%     TP.HW.Thorlabs.hPRM1Z8.MoveAbsolute(0,1==0);
%     pause(5);
%     TP.HW.Thorlabs.hPRM1Z8.GetPosition_Position(0);
    
%         %% Event Handling
%     h.registerevent({'MoveComplete' 'MoveCompleteHandler'});
% 
%     %% Sending Moving Commands
%     timeout = 10; % timeout for waiting the move to be completed
%     %h.MoveJog(0,1); % Jog
% 
%     % Move a absolute distance
%     h.SetAbsMovePos(0,7);
%     h.MoveAbsolute(0,1==0);
% 
%     t1 = clock; % current time
%     while(etime(clock,t1)<timeout) 
%     % wait while the motor is active; timeout to avoid dead loop
%         s = h.GetStatusBits_Bits(0);
%         if (IsMoving(s) == 0)
%           pause(2); % pause 2 seconds;
%           h.MoveHome(0,0);
%           disp('Home Started!');
%           break;
%         end
%     end
% 
%     function MoveCompleteHandler(varargin)
%      pause(0.5); %dummy program
%      disp('Move Completed!');
% 
%     function r = IsMoving(StatusBits)
%     % Read StatusBits returned by GetStatusBits_Bits method and determine if
%     % the motor shaft is moving; Return 1 if moving, return 0 if stationary
%     r = bitget(abs(StatusBits),5)||bitget(abs(StatusBits),6);

%% LOG MSG
msg = [datestr(now) '\tSetupThorlabsMotor\tNI-DAQmx tasks initialized\r\n'];

