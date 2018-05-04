function [fitresult, gof] = FitPowerHWP(x, y, figureon)
%  Create a fit.
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%  See also FIT, CFIT, SFIT.

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype(       'a+ (b-a)/2*(1+cos((x-c)/45*pi))', ...
                    'independent',          'x',...
                    'dependent',            'y' );
opts = fitoptions(  'Method',             	'NonlinearLeastSquares' );
opts.Display =      'Off';
opts.StartPoint =   [0 0.1 50];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

if figureon
    % Plot fit with data.
    figure(         'Name',                 'FitPowerHWP' );
    h = plot( fitresult, xData, yData );
    legend( h,      'Power vs. HWP angle',  'cos fitting',...
                    'Location',             'NorthEast' );
    % Label axes
    xlabel( 'HWP/PRM1Z8 angle (degree)' );
    ylabel( 'Monitored Power (W)' );
    grid on
end