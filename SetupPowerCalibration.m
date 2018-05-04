function msg = SetupPowerCalibration
% This function calibrate the power passing throught the system.
% The power @ focal point can be characterized as
% Power@FP = 
%   Power@Laser * SystemPassiveTransmissionEfficiency
%   HWP function *
%   AOD function *
%   
% to the "Board" vs. HWP angle
% Before press, connect the S310C to the PM100A (PM100{2}) and put it after 
% the beam expander on the table, but before the periscope of the "Board".
% This function will rotate the HWP/PRM1Z8 in 2 degree steps, for 3 rounds 
% to calibrate the relationship between HWP angle & the input power to the "Board"

%% Prompts for Initiation Calibration
    disp('This function will calibration the laser excitation power throught the system, including:2 steps');
    disp('   1st: HWP (Half Wave Plate) Angle vs. Power');
    disp('   2nd: AOD Control Amplitude       vs. Power');
    disp('        After objective             vs. S121C sesnor Dichroic Ratio');
    disp('Please follow the opration instructions now');
    disp('   * DON''T connect S170c silde sensor now. Connectting it too early will damage the sensor');
    disp('   * It''s a good practice to point the imaging arm right down, and put some light absorptive medium to cover potential leaking excitation laser light');
    disp('   * Check all supporting electronics are turned ON.');
    disp('   * Now you can turn the laser on and open the shutter');
        pause;
        clc;
    
%% import handles and data
global TP
global Power

%% Initialize the parameters
Power.CaliHWP.AngleStep =	2;      % 2 degree step
Power.CaliHWP.AngleMax =  	88;     % Fitting is only necessary for 1 quanter turn
Power.CaliHWP.RepMax =    	10;   	% 10 reps for more accuracy
Power.CaliHWP.RepInterval =	0.1;    % 100ms interval
Power.CaliHWP.AngleSweep =  0:Power.CaliHWP.AngleStep:Power.CaliHWP.AngleMax;

Power.DataHWP.MotorRead =   zeros(length(Power.CaliHWP.AngleSweep),1);
Power.DataHWP.S121C =       zeros(length(Power.CaliHWP.AngleSweep),Power.CaliHWP.RepMax);
     
Power.CaliAOD.VoltStep =  	0.1;    % Move voltage every 0.1V
Power.CaliAOD.RepMax =   	30;   	% 30 reps for more accuracy
Power.CaliAOD.RepInterval =	0.1;    % 100ms interval
Power.CaliAOD.VoltSweep =   0:Power.CaliAOD.VoltStep:5;
Power.CaliAOD.AngleHWP =    NaN;

Power.DataAOD.MontAmpX =    zeros(length(Power.CaliAOD.VoltSweep),Power.CaliAOD.RepMax);
Power.DataAOD.MontAmpY =    zeros(length(Power.CaliAOD.VoltSweep),Power.CaliAOD.RepMax);
Power.DataAOD.S121C =       zeros(length(Power.CaliAOD.VoltSweep),Power.CaliAOD.RepMax);
Power.DataAOD.S170C =       zeros(length(Power.CaliAOD.VoltSweep),Power.CaliAOD.RepMax);

%% Stop The Real Time Power Monitoring
    
    % Raise the Calibration Flag
    TP.D.Mon.Power.CalibFlag = 1;
    
    % Release the Last Potential Power scan, leave a fresh starting point
    try TP.HW.Thorlabs.PM100{1}.h.fscanf;   catch;  end;

    % Pretend the task is triggered
    TP.D.Trl.StartTrigStop = 2;
    
    % Temporarily set Pmax to be big enough (800mW)
    tempPmaxCtxAllowed = TP.D.Mon.Power.PmaxCtxAllowed;
    TP.D.Mon.Power.PmaxCtxAllowed = 800;

%% %%%%%%%%%%%%%%%%%%% HWP/PRM1Z8 CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HWP calibration (Setup Hardware)
    disp('OK, now let''s start calibrate the HWP angle vs. Power');    
    disp('We''ll motorize and rotate the HWP carrying stage PRM1Z8, and measure power through sensor S121C');
        pause;
        clc;

    % Setup PRM1Z8 mount to angle: 0
    disp('Moving the motor to angle: 0 now');
        hMotor = TP.HW.Thorlabs.hPRM1Z8;
        updatePowerRotMove(	hMotor,	0,  40);
        updatePowerRotCheck(hMotor,	0,  0.003);

    % Setup AOD Scanning Mode & ctrl amplitude = 5.0
	disp('Get the AOD to Control Amplitude 5.0V')
        feval(TP.D.Sys.Name, 'GUI_AO_6115', [0 5]); 
    disp('AOD Scanning is set to be Scan in the center');
        feval(TP.D.Sys.Name, 'GUI_PresetCfg', 1);
        scanStarted;        
    
    % Wait To Start
    disp('Start in 1 second');
        pause(1);
        clc; 

 %% HWP calibration (Roate the HWP and Collect Data)
    for i = 1:length(Power.CaliHWP.AngleSweep) 
        angle = Power.CaliHWP.AngleSweep(i);
        % Move Motor
        disp(['Moving the motor to the angle: ', num2str(angle), ' degree on PRM1Z8']);
            updatePowerRotMove( hMotor,	angle,  20);
            pause(Power.CaliHWP.RepInterval);
            finishangle = ...
                updatePowerRotCheck(hMotor,	angle,  0.003);
        disp(['The motor has been moved to  : ', num2str(finishangle), 'degree']);
            Power.DataHWP.MotorRead(i) =    finishangle; 

        % Measure Power from Mounted S121C (PM100{1})
        for j = 1:Power.CaliHWP.RepMax
            fprintf(TP.HW.Thorlabs.PM100{1}.h,'MEAS:POW?');
            power = ...
                str2double(TP.HW.Thorlabs.PM100{1}.h.fscanf);
      	disp(['PM100USB + S121C-SP4 reported ', num2str(power), ' Walt']);
                Power.DataHWP.S121C(i, j) =  power;
                pause(Power.CaliHWP.RepInterval);
        end;
        disp(' ');
    end;

%% HWP calibration (Fitting)
% HWP: S121C to HWP angle
    for j = 1:Power.CaliHWP.RepMax
        x = Power.DataHWP.MotorRead;
        y = Power.DataHWP.S121C(:, j);
        [fitresult, gof] = FitPowerHWP(x, y, 0);
        Power.Result.HWPa(j) = fitresult.a;
        Power.Result.HWPb(j) = fitresult.b;
        Power.Result.HWPc(j) = fitresult.c;
        disp(evalc('fitresult'));
        disp(evalc('gof'));
    end;
    Power.TP.HWP_pmin =      mean(Power.Result.HWPa);
    Power.TP.HWP_pmax =      mean(Power.Result.HWPb);
    Power.TP.HWP_pmaxAngle = mean(Power.Result.HWPc);
    [fitresult, gof] = FitPowerHWP(...
        Power.DataHWP.MotorRead, mean(Power.DataHWP.S121C,2), 0);
    x = 0:0.1:88;
    y1 =   fitresult.a+ (fitresult.b-fitresult.a)/2*(1+cos((x-fitresult.c)/45*pi));
    y2 =    Power.TP.HWP_pmin + ...
            (Power.TP.HWP_pmax - Power.TP.HWP_pmin)/2*...
                (1+cos((x-mean(Power.TP.HWP_pmaxAngle))/45*pi));
	figure('Name', 'Power Fitting Result');
    subplot(2,1,1); hold on;
        plot(x, y1, 'r');
        plot(x, y2, 'g');
        plot(Power.DataHWP.MotorRead, Power.DataHWP.S121C, 'b.');
        xlabel( 'HWP/PRM1Z8 angle (degree)' );
        ylabel( 'Power (W)' );
        grid on
        legend( 'Average then Fitting',...
                'Fitting then Average',...
                'Actual Measurements',...
                'Location',             'NorthEast' );
    subplot(2,3,4);	hold on;
        plot(Power.Result.HWPa); title('power(min)');   grid on;
    subplot(2,3,5); hold on;	
        plot(Power.Result.HWPb); title('power(max)');   grid on;
    subplot(2,3,6);	hold on;
        plot(Power.Result.HWPc); title('angle@p(max)'); grid on;
    
%% HWP calibration (Reset Hardware)
	disp('Get the AOD to Control Amplitude 0V')
        feval(TP.D.Sys.Name, 'GUI_AO_6115', [0 0]); 
    disp('AOD Scanning Stopping');
        scanStopping;        
    disp('Press Any Key to Continue');
        pause;    
        clc;
    
%% %%%%%%%%%%%%%%%%%%% AOD CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AOD Calibration (Connect the S170C)
	disp('OK. That''s the end of HWP calibration');
    disp('Mountt the S170C under the objective, and get it immersed');
    disp('Press any key when ready');
        pause;
        clc;
    
%% AOD Calibration (Prepare HWP angle to make sure S170C will not be saturated)
    % Assuming Dichroic Ratio is 31
    mpower = mean(Power.DataHWP.S121C,2);
    Power.CaliAOD.AngleHWP = ...
        Power.CaliHWP.AngleSweep(...
            mpower == max(mpower( mpower<(0.1/31) )) );
    disp('Rotate the HWP to make sure S170C will not be saturated');
        updatePowerRotMove( hMotor, Power.CaliAOD.AngleHWP,  40);
        updatePowerRotCheck(hMotor, Power.CaliAOD.AngleHWP,  0.003);
    disp('Start in 1 second');
        pause(1);
        clc; 

%% AOD Calibration (Measure Dichroic Ratio & AOD Ctrl Amp)
        scanStarted;  
        for i = 1:length(Power.CaliAOD.VoltSweep)
            volt = Power.CaliAOD.VoltSweep(i);
            % Setup AOD CtrlAmpValue
            feval(TP.D.Sys.Name, 'GUI_AO_6115', [0 volt]);        
   	disp(['The AOD CtrlAmpValue is set as: ', num2str(volt), ' Volt']);

            % Measurement Repeatations
            for j = 1:Power.CaliAOD.RepMax
               
                % Wait for an interval
                pause(Power.CaliAOD.RepInterval);
                
                % Check AOD Amp X & Y
                Power.DataAOD.MontAmpX(i,j) = TP.D.Mon.Power.AOD_MontAmpValue(1);
                Power.DataAOD.MontAmpY(i,j) = TP.D.Mon.Power.AOD_MontAmpValue(2);

                % Measure Power on S121C
            	fprintf(TP.HW.Thorlabs.PM100{1}.h,'MEAS:POW?');
                power = str2double(TP.HW.Thorlabs.PM100{1}.h.fscanf);
	disp(['PM100USB + S121C-SP4 reported ', num2str(power), ' Walt']);
                Power.DataAOD.S121C(i,j) = power;
                
                % Measure Power on S170C
            	fprintf(TP.HW.Thorlabs.PM100{2}.h,'MEAS:POW?');
                power = str2double(TP.HW.Thorlabs.PM100{2}.h.fscanf);
	disp(['PM100A + S170C reported ', num2str(power), ' Walt']);
                Power.DataAOD.S170C(i,j) = power;                   

            end;    
            disp(' ');
        end;
        scanStopping; 

%% Fitting:
% ARM: S170C to S121C
    [xData, yData] = prepareCurveData( ...
        reshape(Power.DataAOD.S121C,1, []), ...
        reshape(Power.DataAOD.S170C,1, []));
    ft = fittype( 'poly1' );
    [fitresult, gof] = fit( xData, yData, ft );
  	disp(evalc('fitresult'));
  	disp(evalc('gof'));
    figure( 'Name', 'S121C to S170C Power Fitting' );
        h = plot( fitresult, xData, yData );
        legend( h, 'Actual Measurements', 'Poly1 Fitting', 'Location', 'SouthEast' );
        xlabel( 'S121C Power' );
        ylabel( 'S170C Power' );
        title(['S170C Power = ', num2str(fitresult.p1), ' * S121CPower + ',...
             num2str(fitresult.p2), ' (W)']);
        grid on
    Power.TP.ARM_p1 = fitresult.p1;
    Power.TP.ARM_p2 = fitresult.p2;
    
% AMP: X*Y monitored to AOD ctrl voltage
    [xData, yData] = prepareCurveData( ...
        (0:0.1:5)', ...
        mean(Power.DataAOD.MontAmpX(:, 6:end),2).*mean(Power.DataAOD.MontAmpY(:, 6:end),2));
    ft = fittype( 'poly2' );
    [fitresult, gof] = fit( xData, yData, ft );
  	disp(evalc('fitresult'));
  	disp(evalc('gof'));
    figure( 'Name', 'X*Y monitored to AOD ctrl voltage' );
        h = plot( fitresult, xData, yData );
        legend( h, 'Actual Measurements', 'Poly2 Fitting', 'Location', 'SouthEast' );
        xlabel( 'AOD Control Voltage: Input (V)' );
        ylabel( 'AOD Control Voltage: X*Y Monitored (V^2)' );
        title(['X*Y = ',...
            num2str(fitresult.p1), ' * A^2 + ',...
            num2str(fitresult.p2), ' * A + ',...
        	num2str(fitresult.p3), ' (V^2)']);
        grid on
        Power.TP.AMP_p1 = fitresult.p1;
        Power.TP.AMP_p2 = fitresult.p2;
        Power.TP.AMP_p3 = fitresult.p3;

% AOD: S121C to X*Y monitored
    S121CpmaxCaliAOD = Power.TP.HWP_pmin + ...
        (Power.TP.HWP_pmax - Power.TP.HWP_pmin)/2*...
            (1+cos((Power.CaliAOD.AngleHWP-mean(Power.TP.HWP_pmaxAngle))/45*pi));
  	S170CpmaxCaliAOD = Power.TP.ARM_p1 * S121CpmaxCaliAOD + Power.TP.ARM_p2;
 	x =  reshape(Power.DataAOD.MontAmpX(:,6:end).*Power.DataAOD.MontAmpY(:,6:end),1,[]);
	y1 = reshape(Power.DataAOD.S121C(:,6:end),1,[]);
   	y2 = reshape(Power.DataAOD.S170C(:,6:end),1,[]);            
    
    [fitresult, gof] = FitPowerAOD(x, y1, 1);
    disp(evalc('fitresult'));
    disp(evalc('gof'));      
    Power.TP.AOD_p1 = fitresult.p1/S121CpmaxCaliAOD;
    Power.TP.AOD_p2 = fitresult.p2/S121CpmaxCaliAOD;
    Power.TP.AOD_p3 = fitresult.p3/S121CpmaxCaliAOD;
    Power.TP.AOD_p4 = fitresult.p4/S121CpmaxCaliAOD;
  	title(['P = PmaxS121C* ',...
        num2str(Power.TP.AOD_p1), ' * A^4 + ',...
        num2str(Power.TP.AOD_p2), ' * A^3 + ',...
        num2str(Power.TP.AOD_p3), ' * A^2 + ',...
        num2str(Power.TP.AOD_p4), ' * A (W)']);

    [fitresult, gof] = FitPowerAOD(x, y2, 1);
    disp(evalc('fitresult'));
    disp(evalc('gof'));      
  	title(['P = PmaxS170C* ',...
        num2str(fitresult.p1/S170CpmaxCaliAOD), ' * A^4 + ',...
        num2str(fitresult.p2/S170CpmaxCaliAOD), ' * A^3 + ',...
        num2str(fitresult.p3/S170CpmaxCaliAOD), ' * A^2 + ',...
        num2str(fitresult.p4/S170CpmaxCaliAOD), ' * A (W)']);
    x = 0:0.1:26;
    y = S170CpmaxCaliAOD * (...
        x.^4 * Power.TP.AOD_p1 +    x.^3 * Power.TP.AOD_p2 + ...
        x.^2 * Power.TP.AOD_p3 +    x.^1 * Power.TP.AOD_p4); 
    hold on; plot(x, y, 'g');

%% %%%%%%%%%%%%%%%%%%% Update TP & GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Update TP & GUI

%% Save Data
save PowerCalibration.mat Power;

%% LOG MSG
msg = [datestr(now) '\tCalibPowerInput\r\n'];

%% Restart The Real Time Power Monitoring    	
    
    % Send a Power Measurement Request, Prepare for Next updateSysStatus
    fprintf(TP.HW.Thorlabs.PM100{1}.h,  'MEAS:POW?');
    
    % Set the scan flag back as the task is stopped
    TP.D.Trl.StartTrigStop =    0;
    
    % Lower the Calibration Flag
    TP.D.Mon.Power.CalibFlag =  0;
    
    % Reset Pmax allowed
    TP.D.Mon.Power.PmaxCtxAllowed = tempPmaxCtxAllowed;
