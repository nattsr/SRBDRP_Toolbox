%% Model the KC Correction

% Test the sensitivity of the KC Correction.

rBody_rThroat_Max   = 20;
nModel              = 5;

KCcorrection    = zeros(rBody_rThroat_Max, nModel);
phi_ssa         = zeros(rBody_rThroat_Max, nModel);

for yMax = 1:rBody_rThroat_Max

    [ PSD ] = modelPSD( 1000, 1, yMax);
    
    for iModel = 1:5
    [ KCcorrection(yMax, iModel), phi_ssa(yMax, iModel) ] = computeKCcorrection( PSD{iModel} );
    end
end


plot(KCcorrection, "LineWidth", 2)
xlim([1 20])
legend('Linear'