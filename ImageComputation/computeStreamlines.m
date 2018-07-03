function [ StreamlinesXYZ, StreamlinesAbsFlux, totalDistance, totalTime, ...
    totalFlux, tortuosity, tortuosityMin, tortuosityMean, tortuosityMax, ...
    tortuosityFluxWeighted, tortuosityStd ] ...
    = computeStreamlines( localFlux )
%computeStreamlines compute streamlines from a local flux matrix
%
%   Input Arguments
%   - localFlux    : a (nx*ny*nz*3) matrix, local flux in x, y, z direction.
%                  This is an output from latticeBoltzmannFP3D.m
%                           ---- or ----
%                  a cell array containing matrix as specified above
%
%   Output Arguments
%   for a single localFlux matrix,
%   - StreamlinesXYZ  : a cell array (nStreamline*1), x, y, z locations of
%                       each streamline
%   - StreamlinesAbsFlux : a cell array (nStreamline*1),
%                          flux along streamline
%   - totalDistance   : a vector (nStreamline,1), distance
%   - totalTime       : a vector (nStreamline,1), distance/velocity
%   - totalFlux       : a vector (nStreamline,1), total flux of each flow path
%   - tortuosity      : a vector (nStreamline,1), distance/nz of each flow path
%   - tortuosityMin   : a double, minimum tortuosity of all streamlines
%   - tortuosityMean  : a double, mean tortuosity of all streamlines
%   - tortuosityMax   : a double, maximum tortuosity of all streamlines
%   - tortuosityFluxWeighted : a double, flux weighted mean tortuosity of
%                              all streamlines
%   - tortuosityStd   : a double, standard deviation tortuosity of all
%                       streamlines

%   Revision 5: April    2016 Nattavadee Srisutthiyakorn
%   Revision 4: February 2016 Nattavadee Srisutthiyakorn
%   Revision 3: December 2015 Nattavadee Srisutthiyakorn
%   Revision 2: August   2015 Nattavadee Srisutthiyakorn
%   Revision 1: February 2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Program
% Internal Option
cleanPath = 1;

% Check whether the input is a matrix or a cell array of matrices

if iscell(localFlux)
    
    % Initialize
    nFlux              = size(localFlux, 2);
    
    for iFlux = 1:nFlux
        
        disp(['Current flux: (',num2str(iFlux),'/',num2str(nFlux),')'])
        
        try
            [ StreamlinesXYZ{iFlux}, StreamlinesAbsFlux{iFlux}, ...
                totalDistance{iFlux}, totalTime{iFlux}, ...
                totalFlux{iFlux}, tortuosity{iFlux}, ...
                tortuosityMin(iFlux,:), tortuosityMean(iFlux,:), ...
                tortuosityMax(iFlux,:), tortuosityFluxWeighted(iFlux,:), ...
                tortuosityStd(iFlux,:) ] ...
                = computeIndividalStreamlines( localFlux{iFlux}, cleanPath );
             
            % Save every 50 iteration
            if nFlux > 50 && floor(iFlux/50) == iFlux/50
                save('tempFlowPath', 'StreamlinesXYZ', 'tortuosity', ...
                    'totalTime', 'Stats');
            end
        end
    end
    
    
else
    [ StreamlinesXYZ, StreamlinesAbsFlux, totalDistance, totalTime, ...
        totalFlux, tortuosity, tortuosityMin, tortuosityMean, tortuosityMax, ...
        tortuosityFluxWeighted, tortuosityStd ] ...
        = computeIndividalStreamlines( localFlux, cleanPath );
end

end



function [ StreamlinesXYZ, StreamlinesAbsFlux, totalDistance, totalTime, ...
    totalFlux, tortuosity, tortuosityMin, tortuosityMean, tortuosityMax, ...
    tortuosityFluxWeighted, tortuosityStd ] ...
    = computeIndividalStreamlines( localFlux, cleanPath )
%% QC Inputs
[~, ~, ~, type] = size(localFlux);
if type < 2
    help(mfilename)
    error('Incorrect Flux Type')
end



%% Extracting flow paths
uXRaw = localFlux(:,:,:,1);
uYRaw = localFlux(:,:,:,2);
uZRaw = localFlux(:,:,:,3);
[nx, ny, nz] = size(uXRaw);

% %% Rearrange x axis to z axis for interpolation
% % Initialization

uX        = zeros(ny,nz,nx);
uY        = zeros(ny,nz,nx);
uZ        = zeros(ny,nz,nx);

for iSlice = 1:nx
    uX(:,:,iSlice) = reshape(uXRaw(iSlice,1:ny,1:nz),ny,nz);
    uY(:,:,iSlice) = reshape(uYRaw(iSlice,1:ny,1:nz),ny,nz);
    uZ(:,:,iSlice) = reshape(uZRaw(iSlice,1:ny,1:nz),ny,nz);
end

% % QC Plots
% figure
% subplot(1,3,1)
% imagesc(uX(:,:,1))
% subplot(1,3,2)
% imagesc(uY(:,:,1))
% subplot(1,3,3)
% imagesc(uZ(:,:,1))



%% Interpolation to find location and flux of each streamline
% as of now each streamline is stored in grid (for matrix calculation)

% Initialization
streamlinesLocY = zeros(ny,nz,nx);
streamlinesLocZ = zeros(ny,nz,nx);
streamlinesuX   = zeros(ny,nz,nx);
streamlinesuY   = zeros(ny,nz,nx);
streamlinesuZ   = zeros(ny,nz,nx);

% Z axis -> X axis when plotted (start from top left)
[Z,Y] = meshgrid(1:nz,1:ny);


for jSlice = 1:nx
    tempuX = uX(:,:,jSlice);
    tempuY = uY(:,:,jSlice);
    tempuZ = uZ(:,:,jSlice);
    
    if jSlice == 1
        
        % Find new location (Beware of NaN)
        diffX = 1;
        diffY = (tempuY./tempuX);
        
        streamlinesLocY(:,:,1) = diffY + Y;
        streamlinesLocZ(:,:,1) = (tempuZ) ./ (sqrt(tempuX.^2 + tempuY.^2)) ...
            .* (sqrt(diffX.^2 + diffY.^2)) + Z;
        
    else
        % Find new location (Beware of NaN)
        tempvX = streamlinesuX(:,:,jSlice - 1);
        tempvY = streamlinesuY(:,:,jSlice - 1);
        tempvZ = streamlinesuZ(:,:,jSlice - 1);
        
        diffX = 1;
        diffY = (tempvY ./ tempvX);
        streamlinesLocY(:,:,jSlice) = diffY + streamlinesLocY(:,:,jSlice-1);
        streamlinesLocZ(:,:,jSlice) = (tempvZ) ./ (sqrt(tempvX.^2 + tempvY.^2)) ...
            .* (sqrt(diffX.^2+diffY.^2)) ...
            + streamlinesLocZ(:,:,jSlice - 1);
    end
    
    % Interpolation to create velocity vector
    streamlinesuX(:,:,jSlice) = interp2(Z, Y, tempuX, streamlinesLocZ(:,:,jSlice), ...
        streamlinesLocY(:,:,jSlice), 'linear');
    streamlinesuY(:,:,jSlice) = interp2(Z, Y, tempuY, streamlinesLocZ(:,:,jSlice), ...
        streamlinesLocY(:,:,jSlice), 'linear');
    streamlinesuZ(:,:,jSlice) = interp2(Z, Y, tempuZ, streamlinesLocZ(:,:,jSlice), ...
        streamlinesLocY(:,:,jSlice), 'linear');
end

% % QC Plots
% figure
% subplot(1,3,1)
% imagesc(streamlinesuX(:,:,1))
% subplot(1,3,2)
% imagesc(streamlinesuY(:,:,1))
% subplot(1,3,3)
% imagesc(streamlinesuZ(:,:,1))
%
% figure
% subplot(1,2,1)
% imagesc(streamlinesLocY(:,:,1))
% subplot(1,2,2)
% imagesc(streamlinesLocZ(:,:,1))

disp('Step 1: Interpolation')

%% Transform data into individual path
%Initialization
tempStreamlinesXYZ  = cell(ny*nz,1);
tempStreamlinesFlux = cell(ny*nz,1);
count = 1;

for j = 1:ny
    for k = 1:nz
        
        tempStreamlinesXYZ{count}(:,1) = [1:nx]';
        tempStreamlinesXYZ{count}(:,2) = streamlinesLocY(j,k,:);
        tempStreamlinesXYZ{count}(:,3) = streamlinesLocZ(j,k,:);
        
        tempStreamlinesFlux{count}(:,1)    = streamlinesuX(j,k,:);
        tempStreamlinesFlux{count}(:,2)    = streamlinesuY(j,k,:);
        tempStreamlinesFlux{count}(:,3)    = streamlinesuZ(j,k,:);
        
        count = count + 1;
    end
end

disp('Step 2: Extract individual paths')

%% Clean any path that contains NaN -> outside the boundary
if cleanPath
    nPath = numel(tempStreamlinesXYZ);
    count = 1;
    
    for i = 1:nPath
        if any(any(isnan(tempStreamlinesXYZ{i}))) == 0
            
            StreamlinesXYZ{count}  = tempStreamlinesXYZ{i};
            StreamlinesFlux{count} = tempStreamlinesFlux{i};
            StreamlinesAbsFlux{count} = sqrt(tempStreamlinesFlux{i}(:,1).^2 ...
                + tempStreamlinesFlux{i}(:,2).^2 ...
                + tempStreamlinesFlux{i}(:,3).^2);
            count                  = count + 1;
            
        end
    end
else
    StreamlinesXYZ     = tempStreamlinesXYZ;
    StreamlinesFlux    = tempStreamlinesFlux;
end

disp('Step 3: Clean paths with NaN')

%% Find Tortuosity
% Initialization
nFlowPathClean = numel(StreamlinesXYZ);
totalDistance  = zeros(1, nFlowPathClean);
totalTime      = zeros(1, nFlowPathClean);
totalFlux      = zeros(1, nFlowPathClean);

for i = 1:numel(StreamlinesXYZ)
    
    pathX = StreamlinesXYZ{i}(:,1);
    pathY = StreamlinesXYZ{i}(:,2);
    pathZ = StreamlinesXYZ{i}(:,3);
    
    velocityX = StreamlinesFlux{i}(:,1);
    velocityY = StreamlinesFlux{i}(:,2);
    velocityZ = StreamlinesFlux{i}(:,3);
    
    % Initialization
    flowDistance    = zeros(size(pathX,1)-1, 1);
    flowAvgVelocity = zeros(size(pathX,1)-1, 1);
    flowTime        = zeros(size(pathX,1)-1, 1);
    
    for j = 1:size(pathX,1) - 1
        if and(any(StreamlinesXYZ{i}(j,:))   ~= 0, ...
                any(StreamlinesXYZ{i}(j+1,:)) ~= 0)
            
            flowDistance(j)  = sqrt( (pathX(j+1)-pathX(j)).^2 + ...
                (pathY(j+1)-pathY(j)).^2 + ...
                (pathZ(j+1)-pathZ(j)).^2 );
            
            flowAvgVelocity(j) ...
                = (sqrt(velocityX(j+1).^2 + velocityY(j+1).^2 + ...
                velocityZ(j+1).^2) + ...
                sqrt(velocityX(j).^2   + velocityY(j).^2   + ...
                velocityZ(j).^2))./2;
            
            flowTime(j)    = flowDistance(j)./flowAvgVelocity(j);
            
        end
    end
    
    % For each path
    totalDistance(1,i)  = sum(flowDistance);
    totalTime(1,i)      = sum(flowTime);
    totalFlux(1,i)      = sum(flowAvgVelocity);
end

tortuosity  = (totalDistance./(nx));

% Find the major statistics
tortuosityMin   = nanmin(tortuosity);
tortuosityMean  = nanmean(tortuosity);
tortuosityMax   = nanmax(tortuosity);
tortuosityFluxWeighted = nansum(totalDistance.*totalFlux)./nansum(totalFlux)./nx;
tortuosityStd   = nanstd(tortuosity);

disp('Step 4: Calculate tortuosity')


end




