function [fitresult, gof] = FitPowerAOD(x, y, figureon)
%  Create a fit.
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%  See also FIT, CFIT, SFIT.

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype(       'p1*x^4 + p2*x^3 + p3*x^2 + p4*x',...
                    'independent',              'x',...
                    'dependent',                'y' );
opts = fitoptions(  'Method',                	'NonlinearLeastSquares' );
opts.Robust =       'Bisquare';
opts.Algorithm =    'Trust-Region';
opts.Display =      'Off';
opts.StartPoint =   [0 0 0 0];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

if figureon
    % Plot fit with data.
    figure( 'Name', 'FitPowerAOD' );
    h = plot( fitresult, xData, yData );
    legend( h, 'Actual Measurement', 'Fitting', 'Location', 'SouthEast' );
    % Label axes
    xlabel( 'AOD AmpCtrl X Mont * AOD AmpCtrl Y Mont (V^2) ' );
    ylabel( 'Monitored Power (W)' );
    grid on
end