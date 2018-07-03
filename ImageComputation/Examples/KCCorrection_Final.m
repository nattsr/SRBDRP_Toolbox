% Investigate The Apparent Radius from 2D vs 3D and the effect on KC
% correction
clear all; close all; clc;

listImage3D = {'SinusoidalPipes', 'SCP','FCP','FinneyLX9','FontbFRS200','BitumenFRS200'};
listSym = {'ok', '+k', 'xk', 'vk', 'sk', 'hk'};
listSym = {'o', '+', 'x', 'v', 's', 'h'};

% listImage3D = {'SCP','FCP','FinneyLX9','FontbFRS200','BitumenFRS200','GrosmontFRS200','BereaFRS200'};
nList = length(listImage3D);

myColorMap = [
    0.6350    0.0780    0.1840 
    0         0.4470    0.7410
    0         0.4470    0.7410
    0.8500    0.3250    0.0980
    0.4940    0.1840    0.5560
    0.2000    0.6471    0.3569
    ];


%% Load Data
for iList = 1:nList
    % Load Data
    try
        load(['D:\Dropbox\Projects\SimulationsDB\Data\',listImage3D{iList},'.mat'])
        load(['D:\Dropbox\Projects\SimulationsDB\Data\',listImage3D{iList},'_Results.mat'])
        load(['D:\Dropbox\Projects\SimulationsDB\Data\',listImage3D{iList},'_Streamlines.mat'])
    end
    
    
    try
        load(['C:\Users\Natt\Dropbox\Projects\SimulationsDB\Data\',listImage3D{iList},'.mat'])
        load(['C:\Users\Natt\Dropbox\Projects\SimulationsDB\Data\',listImage3D{iList},'_Results.mat'])
        load(['D:\GoogleDrive\Project Database\SimulationDB_Streamlines\',listImage3D{iList},'_Streamlines.mat'])
    end
            load(['D:\GoogleDrive\Project Database\SimulationDB_Streamlines\',listImage3D{iList},'_Streamlines.mat'])
end



%% Final Run
for iList = 1:nList   
    % Load parameters
    eval(['tempImage3D      = ',listImage3D{iList},';']);
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    eval(['tempStreamlines  = ',listImage3D{iList},'_Streamlines;']);
    nImage = length(tempResults.Original.permeabilityKC2); % Because not every image can be read
    
    % Flip the images to the direction of the flow     
    for iImage = 1:nImage
        [ tempImage3D{iImage} ] = flipDRPImage( tempImage3D{iImage});    
    end
    
    % Find 2D porosity and specific perimeter 
    [tempResults.Original.porosity2D, tempResults.Original.specificSurfaceArea2D] ...
        = computeMinkowski2D(tempImage3D);
    
    % Calculate the apparent radius for 2D data set.
    for iImage = 1:nImage
        [nx, ny, nz] = size(tempImage3D{iImage});
        
        tempResults.Original.radiusHydraulicPx2D{iImage} ...
            = 2.*tempResults.Original.porosity2D{iImage}./tempResults.Original.specificSurfaceArea2D{iImage};
        
        tempResults.Original.radiusCircPx2D{iImage} ...
            = sqrt(tempResults.Original.porosity2D{iImage}.*(ny.*nz)./(pi));
        
        tempResults.Original.radiusApparentPx2D{iImage} ...
            = sqrt(tempResults.Original.radiusCircPx2D{iImage}.*tempResults.Original.radiusHydraulicPx2D{iImage});
        
        tempResults.Original.radiusCircPx2DMean(iImage,1) ...
            = mean(tempResults.Original.radiusCircPx2D{iImage});
        
        tempResults.Original.radiusApparentPx2DMean(iImage,1) ...
            = mean(tempResults.Original.radiusApparentPx2D{iImage});
        
    end  
    % True correction
    tempResults.Original.KCCor_True = tempResults.Original.permeability(1:nImage)./tempResults.Original.permeabilityKC2;
    
    % Go through the image for the correction
    clear tempStrKC 
    for iImage = 1:nImage
        totalFlux       = tempStreamlines.totalFlux{iImage};
        xyz             = tempStreamlines.XYZ{iImage};
        
        % Sort flux according to the total flux
        [totalFluxSorted, idxSorted] = sort(totalFlux(:),'descend');
        
        % Compute all the proximity
        proximity2D = tempStreamlines.Proximity2D{iImage}(idxSorted);
        
        % Find the correction
        for j = 1:length(proximity2D)
            tempStrKC.PSD2DUnsorted{iImage}{j} = proximity2D{j};
            tempStrKC.PSD2DSorted{iImage}{j}   = sort(proximity2D{j});
            tempStrKC.AppRadius2D(iImage) = ...
                tempResults.Original.radiusApparentPx2DMean(iImage)./tempResults.Original.radiusCircPx2DMean(iImage);
            tempStrKC.AppRadius3D(iImage) = ...
                tempResults.Original.radiusApparentPx(iImage)./tempResults.Original.radiusCircPx(iImage);

            
            [ tempStrKC.KCCorPSD2DAppRadius2DSorted{iImage}(j) ] = ...
                computeKCcorrection( tempStrKC.PSD2DSorted{iImage}{j} * tempStrKC.AppRadius2D(iImage));
            [ tempStrKC.KCCorPSD2DAppRadius2DUnsorted{iImage}(j) ] = ...
                computeKCcorrection( tempStrKC.PSD2DUnsorted{iImage}{j} * tempStrKC.AppRadius2D(iImage));   
            
            [ tempStrKC.KCCorPSD2DSorted{iImage}(j) ] = ...
                computeKCcorrection( tempStrKC.PSD2DSorted{iImage}{j});      
            
            [ tempStrKC.KCCorPSD2DAppRadius3DSorted{iImage}(j) ] = ...
                computeKCcorrection( tempStrKC.PSD2DSorted{iImage}{j} * tempStrKC.AppRadius3D(iImage));
            
            [ tempStrKC.KCCorPSD2DAppRadius3DUnsorted{iImage}(j) ] = ...
                computeKCcorrection( tempStrKC.PSD2DUnsorted{iImage}{j} * tempStrKC.AppRadius3D(iImage));            
                        
        end
        
        % Save the maximum correction with the results
        [tempResults.Original.KCCor_ProximityApp2D(iImage), idxMax2D]   = max(tempStrKC.KCCorPSD2DAppRadius2DSorted{iImage});
         tempResults.Original.KCCor_ProximityApp2DStreamlines{iImage}   = sort(proximity2D{idxMax2D});
         tempResults.Original.poreBody2poreThroat(iImage) = max(tempResults.Original.KCCor_ProximityApp2DStreamlines{iImage})/min(tempResults.Original.KCCor_ProximityApp2DStreamlines{iImage});
        
        [tempResults.Original.KCCor_ProximityApp2DNoApparentRadius(iImage)]   = max(tempStrKC.KCCorPSD2DSorted{iImage});
         
        
        [tempResults.Original.KCCor_ProximityApp2DMaxFlux(iImage)]      = tempStrKC.KCCorPSD2DAppRadius2DSorted{iImage}(1);
        tempResults.Original.KCCor_ProximityApp2DStreamlinesMaxFlux{iImage}    = sort(proximity2D{1});
         
        [tempResults.Original.KCCor_ProximityApp2DUnsorted(iImage), idxMax2D]    = max(tempStrKC.KCCorPSD2DAppRadius2DUnsorted{iImage});
        tempResults.Original.KCCor_ProximityApp2DStreamlinesUnsorted{iImage}      = (proximity2D{idxMax2D});
         
       [tempResults.Original.KCCor_ProximityApp3D(iImage), idxMax3D]  = max(tempStrKC.KCCorPSD2DAppRadius3DSorted{iImage});
       [tempResults.Original.KCCor_ProximityApp3DUnsorted(iImage), idxMax3D] = max(tempStrKC.KCCorPSD2DAppRadius3DUnsorted{iImage});
    end
    
	% Save the results
      eval([listImage3D{iList},'_Results = tempResults;']);
      save([listImage3D{iList},'_Results'],[listImage3D{iList},'_Results'])
      saveName = [listImage3D{iList},'_StreamlinesKCCorrection'];
      eval([saveName,'= tempStrKC;']);
      save(saveName, saveName)
      
end



%% Plot
markerSize  = 8;

specialName = 'Sorted';

figure
figureName = ['KCCorrectionBeforeAfter'];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    
    subplot(1,2,1)
    loglog(tempResults.Original.permeabilityKC2,...
        tempResults.Original.permeability(1:nImage), listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Original KC Permeability (md)'); ylabel('LB Permeability');
    title('Original KC Permeability')
    
    hold on
    
    subplot(1,2,2)
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2D(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Revised KC Permeability (md)'); ylabel('LB Permeability');
    title('Revised KC Permeability')
    hold on    
    
end
subplot(1,2,1);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

subplot(1,2,2);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

legend(listImage3D,'Location','Best')
print(strrep(figureName,' ',''),'-dtiff','-r300')



figure
figureName = ['KCCorrectionSorting'];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    
    subplot(1,2,2)
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2D(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Revised KC Permeability (md)'); ylabel('LB Permeability');
    title('Sorted Pore Size Distribution')
    
    hold on
    
    subplot(1,2,1)
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2DUnsorted(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Revised KC Permeability (md)'); ylabel('LB Permeability');
    title('Unsorted Pore Size Distribution')
    hold on    
    
end
subplot(1,2,1);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

subplot(1,2,2);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

legend(listImage3D,'Location','Best')
print(strrep(figureName,' ',''),'-dtiff','-r300')



figure
figureName = ['KCCorrectionMaxFlux'];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    
    subplot(1,2,1)
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2D(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Revised KC Permeability (md)'); ylabel('LB Permeability');
    title('Max Correction of All Streamlines')
    hold on
    
    subplot(1,2,2)
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2DMaxFlux(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('Revised KC Permeability (md)'); ylabel('LB Permeability');
    title('Max Total Flux Streamlines')
    hold on    
    
end
subplot(1,2,1);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

subplot(1,2,2);
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
grid on; box on;

legend(listImage3D,'Location','Best')
print(strrep(figureName,' ',''),'-dtiff','-r300')



%% Old Plots
figure
figureName = ['KCCorrectionBeforeColor',specialName];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    loglog(tempResults.Original.permeabilityKC2,...
        tempResults.Original.permeability(1:nImage), listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('KC Permeability'); ylabel('LB Permeability');
    hold on
end
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
legend(listImage3D,'Location','Best')
grid on; box on;
print(strrep(figureName,' ',''),'-dtiff','-r300')



figure
figureName = ['KCCorrectionProximity2DColor',specialName];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp2D(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('The Revised KC Permeability (2D Proximity)'); ylabel('LB Permeability');
    hold on
end
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
legend(listImage3D,'Location','Best')
grid on; box on;
print(strrep(figureName,' ',''),'-dtiff','-r300')



figure
figureName = ['KCCorrectionProximity3DColor',specialName];
for iList = 1:nList   
    % Assigning parameters
    eval(['tempResults      = ',listImage3D{iList},'_Results;']);
    nImage = length(tempResults.Original.permeabilityKC2);
    loglog(tempResults.Original.permeabilityKC2 .* tempResults.Original.KCCor_ProximityApp3D(1:nImage)',...
        tempResults.Original.permeability(1:nImage),...
        listSym{iList},'MarkerSize', markerSize,...
        'MarkerEdgeColor', myColorMap(iList,:)) 
    xlabel('The Revised KC Permeability (3D Proximity)'); ylabel('LB Permeability'); 
    hold on
end
xlim([10 1e7]);ylim([10 1e7]);
hline = refline([1 0]);
hline.Color = 'k';
legend(listImage3D,'Location','Best')
grid on; box on;
print(strrep(figureName,' ',''),'-dtiff','-r300')



%% 










