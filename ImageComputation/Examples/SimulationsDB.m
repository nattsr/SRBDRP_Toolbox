%% Simulations for Database
% Initialization
listImage3D = {'RoundPipes_Baffle'};


nList = length(listImage3D);

% Run the program (set to 1)
loadData                    = 0;
runGeomOriginal             = 1;

runGeomInverse              = 1;
runGeomEffective            = 0;

runLBSimulationOriginal     = 1;
runLBSimulationEffective    = 0;

runStreamlinesOriginal      = 1;
runStreamlinesEffective     = 0;

runGeomFactorOriginal       = 1;
runGeomFactorEffective      = 0;

runProximity                = 1;
secondTimeRunning           = 0;


for iList = 1:nList
    clear temp*
    
    % Name Parameters
    nameImage3D         = listImage3D{iList};
    nameResults         = [nameImage3D,'_Results'];
    nameFlux            = [nameImage3D,'_Flux'];
    nameFluxEff         = [nameImage3D,'_FluxEffective'];
    nameStreamlines             = [nameImage3D,'_Streamlines'];
    nameStreamlinesEff          = [nameImage3D,'_StreamlinesEffective'];
    
    nameImage3DFile     = [nameImage3D,'.mat'];
    nameResultsFile     = [nameImage3D,'_Results.mat'];
    nameFluxFile        = [nameImage3D,'_Flux.mat'];
    nameStreamlinesFile = [nameImage3D,'_Streamlines.mat'];
    
    % Load parameter
    if loadData
        load(nameImage3DFile)
    end
    
    % Assigning parameters
    dx = eval([nameImage3D,'_dx']);
    if secondTimeRunning
        eval(['tempResults = ',nameResults,';'])
    end
    % Create images
    tempImage3D.Original          = eval(nameImage3D);
    
    if iscell( tempImage3D.Original )
        nImage = length( tempImage3D.Original );
        
        for iImage = 1:nImage
            if runGeomInverse
                tempImage3D.Inverse{iImage}   = abs(1 - tempImage3D.Original{iImage});
            end
            if or(runGeomEffective,runLBSimulationEffective)
                tempImage3D.Effective{iImage} ...
                    = createEffectivePorespace( tempImage3D.Original{iImage} );
            end
        end
        
    else
        tempImage3D.Inverse   = abs(1 - tempImage3D.Original );
        tempImage3D.Effective = createEffectivePorespace( tempImage3D.Original  );
    end
    
    
    % Geometrical Parameters
    if runGeomOriginal
        [ tempResults.Original.porosity, tempResults.Original.specificSurfaceArea, ...
            tempResults.Original.meanBreadth, tempResults.Original.eulerNumber ] ...
            = computeMinkowski3D( tempImage3D.Original , 1 );
    end
    
    if runGeomInverse
        [ tempResults.Inverse.porosity, tempResults.Inverse.specificSurfaceArea, ...
            tempResults.Inverse.meanBreadth, tempResults.Inverse.eulerNumber ] ...
            = computeMinkowski3D( tempImage3D.Inverse, 1 );
    end
    
    if runGeomEffective
        [ tempResults.Effective.porosity, tempResults.Effective.specificSurfaceArea, ...
            tempResults.Effective.meanBreadth, tempResults.Effective.eulerNumber ] ...
            = computeMinkowski3D( tempImage3D.Effective, 1 );
    end
    
    % Save Data
    eval([nameResults , '= tempResults'])
    save(nameResults,nameResults)
    
    % Lattice Boltzmann Simulation - Original
    if runLBSimulationOriginal
        [ tempResults.Original.permeability, tempFlux ] ...
            = latticeBoltzmannFP3D( tempImage3D.Original, dx );
        % Save Data
        eval([nameResults , '= tempResults'])
        save(nameResults,nameResults)
        eval([nameFlux , '= tempFlux'])
        save(nameFlux,nameFlux)
    end
    
    % Lattice Boltzmann Simulation - Effective
    if runLBSimulationEffective
        [ tempResults.Effective.permeability, tempFlux ] ...
            = latticeBoltzmannFP3D( tempImage3D.Effective, dx );
        % Save Data
        eval([nameResults , '= tempResults'])
        save(nameResults,nameResults)
        eval([nameFluxEff , '= tempFlux'])
        save(nameFluxEff,nameFluxEff)
    end
    
    % Streamlines - Original
    if runStreamlinesOriginal
        [ tempStreamlines.XYZ, tempStreamlines.AbsFlux, tempStreamlines.totalDistance, ...
            tempStreamlines.totalTime, tempStreamlines.totalFlux, tempStreamlines.tortuosity, ...
            tempResults.Original.tortuosityMin, tempResults.Original.tortuosityMean,...
            tempResults.Original.tortuosityMax, ...
            tempResults.Original.tortuosityFluxWeighted, ...
            tempResults.Original.tortuosityStd ] = computeStreamlines( tempFlux );
        
        % Save Data
        eval([nameStreamlines , '= tempStreamlines'])
        save(nameStreamlines,nameStreamlines)
        
    end

    % Streamlines - Effective
    if runStreamlinesEffective
        [ tempStreamlines.XYZ, tempStreamlines.AbsFlux, tempStreamlines.totalDistance, ...
            tempStreamlines.totalTime, tempStreamlines.totalFlux, tempStreamlines.tortuosity, ...
            tempResults.Effective.tortuosityMin, tempResults.Effective.tortuosityMean,...
            tempResults.Effective.tortuosityMax, ...
            tempResults.Effective.tortuosityFluxWeighted, ...
            tempResults.Effective.tortuosityStd ] = computeStreamlines( tempFlux );
        
        % Save Data
        eval([nameStreamlinesEff , '= tempStreamlines'])
        save(nameStreamlinesEff,nameStreamlinesEff)

    end
    
    % Geometrical Factor - Original
    dl = dx.*0.001;
    if runGeomFactorOriginal
        dataEnd = length(tempResults.Original.tortuosityFluxWeighted);
        [ tempResults.Original.geometricFactor ] ...
            = kozenyCarmanGeomFactor( tempResults.Original.permeability(1:dataEnd), ...
            tempResults.Original.porosity(1:dataEnd), ...
            tempResults.Original.specificSurfaceArea(1:dataEnd), ...
            tempResults.Original.tortuosityFluxWeighted, dl );
    end
 
    % Geometrical Factor - Effective
    dl = dx.*0.001;
    if runGeomFactorEffective
        dataEnd = length(tempResults.Effective.tortuosityFluxWeighted);
        [ tempResults.Effective.geometricFactor ] ...
            = kozenyCarmanGeomFactor( tempResults.Effective.permeability(1:dataEnd), ...
            tempResults.Effective.porosity(1:dataEnd), ...
            tempResults.Effective.specificSurfaceArea(1:dataEnd), ...
            tempResults.Effective.tortuosityFluxWeighted, dl );
    end
    
    % Save Data
    eval([nameResults , '= tempResults'])
    save(nameResults,nameResults)
    
    % Proximity
    if runProximity
    [ tempStreamlines.Proximity2D, tempStreamlines.Proximity3D, ...
    tempStreamlines.Proximity2DNorm, tempStreamlines.Proximity3DNorm, ...
    tempStreamlines.Proximity2DMin, tempStreamlines.Proximity2DMean, ...
    tempStreamlines.Proximity2DMax, tempStreamlines.Proximity2DStd, ...
    tempStreamlines.Proximity3DMin, tempStreamlines.Proximity3DMean, ...
    tempStreamlines.Proximity3DMax, tempStreamlines.Proximity3DStd] ...
    = computeStreamlines2D3DProximity( tempImage3D.Original, tempStreamlines.XYZ );

        % Save Data
        eval([nameStreamlines , '= tempStreamlines'])
        save(nameStreamlines,nameStreamlines)
    end
    
    
    
    
    
end





