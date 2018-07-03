function [ StreamlinesProximity2D, StreamlinesProximity3D, ...
    StreamlinesProximity2DNorm, StreamlinesProximity3DNorm, ...
    Proximity2DMin, Proximity2DMean, Proximity2DMax, Proximity2DStd, ...
    Proximity3DMin, Proximity3DMean, Proximity3DMax, Proximity3DStd] ...
    = computeStreamlines2D3DProximity( image3D, StreamlinesXYZ )
%computeStreamlines2D3DProximity extract proximity to the nearest solid
%
%   Input Arguments
%   - image3D         : a (nx*ny*nz) uint8 matrix, 3-D binary image of
%                       pore space (0 = pore, 1 = grain)
%                           ---- or ----
%                       a cell array containing matrix as specified above
%
%   - StreamlinesXYZ  : a cell array (nStreamline*1), x, y, z locations of
%                       each streamline (output from computeStreamlines)
%                           ---- or ----
%                       a cell array containing cell array as specified above
%
%   Output Arguments
%   - StreamlinesProximity2D : a cell array (nStreamline*1) containing
%                              vector (nx*1) of nearest distance to solid
%                              in 2-D slice.
%   - StreamlinesProximity3D : a cell array (nStreamline*1) containing
%                              vector (nx*1) of nearest distance to solid
%                              in 3-D slice.
%   - StreamlinesProximity2DNorm : a cell array (nStreamline*1) containing
%                              vector (nx*1) of nearest distance to solid
%                              in 2-D slice normalized with the maximum.
%   - StreamlinesProximity3DNorm : a cell array (nStreamline*1) containing
%                              vector (nx*1) of nearest distance to solid
%                              in 3-D slice normalized with the maximum.
%   - Proximity2DMin  : a vector (nStreamlines*1) containing a minimum value
%                       of 2D proximity along each streamline
%   - Proximity2DMean : a vector (nStreamlines*1) containing a mean value
%                       of 2D proximity along each streamline
%   - Proximity2DMax  : a vector (nStreamlines*1) containing a maximum value
%                       of 2D proximity along each streamline
%   - Proximity2DStd  : a vector (nStreamlines*1) containing a std value
%                       of 2D proximity along each streamline
%   - Proximity3DMin  : a vector (nStreamlines*1) containing a minimum value
%                       of 3D proximity along each streamline
%   - Proximity3DMean : a vector (nStreamlines*1) containing a mean value
%                       of 3D proximity along each streamline
%   - Proximity3DMax  : a vector (nStreamlines*1) containing a maximum value
%                       of 3D proximity along each streamline
%   - Proximity3DStd  : a vector (nStreamlines*1) containing a std value
%                       of 3D proximity along each streamline

%   Revision 1: April    2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Program

if iscell(image3D)
    % Initialization
    nImage              = length(image3D);
    for iImage = 1:nImage
        
        disp(['Current image: (',num2str(iImage),'/',num2str(nImage),')'])
        
        try
            [ StreamlinesProximity2D{iImage}, StreamlinesProximity3D{iImage}, ...
                StreamlinesProximity2DNorm{iImage}, StreamlinesProximity3DNorm{iImage},...
                Proximity2DMin{iImage}, Proximity2DMean{iImage}, ...
                Proximity2DMax{iImage}, Proximity2DStd{iImage}, ...
                Proximity3DMin{iImage}, Proximity3DMean{iImage}, ...
                Proximity3DMax{iImage}, Proximity3DStd{iImage}] ...
                = computeSTL2D3DProximity( image3D{iImage}, StreamlinesXYZ{iImage});
        end
    end
    
else
    [ StreamlinesProximity2D, StreamlinesProximity3D, ...
        StreamlinesProximity2DNorm, StreamlinesProximity3DNorm, ...
        Proximity2DMin, Proximity2DMean, Proximity2DMax, Proximity2DStd, ...
        Proximity3DMin, Proximity3DMean, Proximity3DMax, Proximity3DStd] ...
        = computeSTL2D3DProximity( image3D, StreamlinesXYZ );
end


end



function [ StreamlinesProximity2D, StreamlinesProximity3D, ...
    StreamlinesProximity2DNorm, StreamlinesProximity3DNorm, ...
    Proximity2DMin, Proximity2DMean, Proximity2DMax, Proximity2DStd, ...
    Proximity3DMin, Proximity3DMean, Proximity3DMax, Proximity3DStd] ...
    = computeSTL2D3DProximity( image3D, StreamlinesXYZ )

% Rotate matrix into the the flow along x direction
[nx, ny, nz] = size(image3D);
for iSlice = 1:nx
    image3DRot(:,:,iSlice) = reshape(image3D(iSlice,1:ny,1:nz),ny,nz);
end

% Find the distance matrix in 2D, 3D
Proximity3D = bwdist(image3DRot,'euclidean');
Proximity2D = zeros(ny, nz, nx);

for iSlice = 1:nx
    image2D = image3DRot(:,:,iSlice);
    Proximity2D(:,:,iSlice) = bwdist(image2D,'euclidean');
end

% Find the distance from the flow path
nStreamline = length(StreamlinesXYZ);

for iStreamline = 1:nStreamline
    % Initialization
    x = StreamlinesXYZ{iStreamline}(:,1);
    y = StreamlinesXYZ{iStreamline}(:,2);
    z = StreamlinesXYZ{iStreamline}(:,3);
    
    for iSlice = 1:nx
        StreamlinesProximity2D{iStreamline}(iSlice) ...
            = Proximity2D(round(y(iSlice)),round(z(iSlice)),round(x(iSlice)));
        StreamlinesProximity3D{iStreamline}(iSlice) ...
            = Proximity3D(round(y(iSlice)),round(z(iSlice)),round(x(iSlice)));
    end
    
    % Analyze the statistics of proximity
    Proximity2DMin(iStreamline)     = min(StreamlinesProximity2D{iStreamline});
    Proximity2DMean(iStreamline)    = mean(StreamlinesProximity2D{iStreamline});
    Proximity2DMax(iStreamline)     = max(StreamlinesProximity2D{iStreamline});
    Proximity2DStd(iStreamline)     = std(StreamlinesProximity2D{iStreamline});
    StreamlinesProximity2DNorm{iStreamline} ...
        = StreamlinesProximity2D{iStreamline}./Proximity2DMax(iStreamline);
    
    Proximity3DMin(iStreamline)     = min(StreamlinesProximity3D{iStreamline});
    Proximity3DMean(iStreamline)    = mean(StreamlinesProximity3D{iStreamline});
    Proximity3DMax(iStreamline)     = max(StreamlinesProximity3D{iStreamline});
    Proximity3DStd(iStreamline)     = std(StreamlinesProximity3D{iStreamline});
    StreamlinesProximity3DNorm{iStreamline} ...
        = StreamlinesProximity3D{iStreamline}./Proximity3DMax(iStreamline);
    
end


end








