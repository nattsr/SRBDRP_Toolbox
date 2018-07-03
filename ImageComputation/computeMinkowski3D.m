function [ porosity, specificSurfaceArea, meanBreadth, eulerNumber ] ...
    = computeMinkowski3D( image3D, option )
%computeMinkowski3D porosity, specific surface area, mean breadth, eulerNo
%
%   Input Arguments
%   - image3D      : Two types of inputs are possible
%                    (1) a single digital rock
%                     a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                    pore space (0 = pore, 1 = grain)
%                           ---- or ----
%                    (2) a cell array of digital rocks
%                    a cell array containing matrix as specified above
%   - option       : an integer, 0 for nConnection (6)  and nDirection (3)
%                                1 for nConnection (26) and nDirection (13)
%
%   Output Arguments
%   - porosity            : a vector (nImage*1), porosity
%   - specificSurfaceArea : a vector (nImage*1), surface area/length^3
%   - meanBreadth         : a vector (nImage*1), mean breadth 
%   - eulerNumber         : a vector (nImage*1), Euler's number  
%
%   Example
%       [BereaFRS200_Results.Original.porosity, ...
%        BereaFRS200_Results.Original.specificSurfaceArea, ...
%        BereaFRS200_Results.Original.meanBreadth, ...
%        BereaFRS200_Results.Original.eulerNumber] ...
%        = computeMinkowski3D(BereaFRS200, 1)
%   Note
%       In order to run this code, imMinkowski files are needed.
%       "Computation of Minkowski measures on 2D and 3D binary images".
%       David Legland, Kien Kieu and Marie-Francoise Devaux (2007)
%       Image Analysis and Stereology, Vol 26(2), June 2007
%       web: http://www.ias-iss.org/ojs/IAS/article/view/811

%   Revision 3: April  2016 Nattavadee Srisutthiyakorn
%   Revision 2: August 2015 Nattavadee Srisutthiyakorn
%   Revision 1: June   2014 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% QC Inputs

if nargin < 2
    option = 1;
end



%% Check whether the input is a matrix or a cell array of matrices

if iscell(image3D)
    
    % Initialization
    nImage              = length(image3D);
    porosity            = zeros(nImage, 1);
    specificSurfaceArea = zeros(nImage, 1);
    meanBreadth         = zeros(nImage, 1);
    eulerNumber         = zeros(nImage, 1);
    
    for iImage = 1:nImage
        
        disp(['Current image: (',num2str(iImage),'/',num2str(nImage),')'])
        
        try
        [ porosity(iImage), specificSurfaceArea(iImage),...
            meanBreadth(iImage), eulerNumber(iImage) ] ...
            = computeMK3D( image3D{iImage}, option );
        end
        
        % Save every 50 iteration
        if nImage > 50 && floor(iImage/50) == iImage/50
            save('tempMinkowski','porosity','specificSurfaceArea',...
                'meanBreadth','eulerNumber');
        end
        
    end
    
else
    [ porosity, specificSurfaceArea, meanBreadth, eulerNumber ] ...
        = computeMK3D( image3D, option );
end

end



function [ porosity, specificSurfaceArea, meanBreadth, eulerNumber ] ...
    = computeMK3D( image3D, option )
%% QC Inputs
[~, ~, nZ] = size(image3D);

% Check inputs
if nZ < 2
    help(mfilename);
    error('Error: image3d input is required to be 3-D')
end



%% Create reverse image(s)
image3DInverse = abs(1-image3D);


%% Run Minkowski Functionals
switch option
    case 0
        nConnectivity = 6;
        nDirection    = 3;
    case 1
        nConnectivity = 26;
        nDirection = 13;
end

% Perform a check whether it's all solid or all pore space
checkOriginal = any(any(any(image3D,3)));
checkReverse  = any(any(any(image3DInverse,3)));

if and(checkOriginal, checkReverse)
    % Porosity
    try
        porosity = 1 - imVolumeDensity(image3D);
    catch
        porosity = NaN;
    end
    
    % Specific Surface Area (Surface Estimate/Length^3)
    try
        specificSurfaceArea = imSurfaceDensity(image3D, nDirection);
    catch
        specificSurfaceArea = NaN;
    end
    
    % Mean Breadth
    try
        meanBreadth = imMeanBreadth(image3D, nDirection);
    catch
        meanBreadth = NaN;
    end
    % Euler Number
    try
        eulerNumber = imEuler3d(image3D, nConnectivity);
    catch
        eulerNumber = NaN;
    end
    % Warning if number of element > 1
    if numel(porosity) > 1
        warning(['WARNING: imMinkowski yileds the number'...
            ' of element greater than 1'])
    end
    
end

end

