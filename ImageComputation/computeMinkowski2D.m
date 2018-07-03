function [ porosity2D, specificSurfaceArea2D, eulerNumber2D ] ...
    = computeMinkowski2D( image3D, option )
%computeMinkowski2D porosity, specific surface area, eulerNo from a slice
%or a single rock
%
%   Input Arguments 
%   - image2D      : Three types of input are possible
%                    (1) a single slice of digital rock
%                    a (nx*ny) uint8 matrix, 2-D binary image of a rock
%                    (0 = pore, 1 = grain)
%                           ---- or ----
%                    (2) a digital rock
%                     a (nx*ny*nz) uint8 matrix, 3-D binary image of a rock
%                    (0 = pore, 1 = grain) in case of running multiple 2D
%                    images from a rock
%                           ---- or ----
%                    (3) a cell array of digital rocks
%                    a cell array containing matrix as specified above
%   - option       : an integer, 0 for nConnection (6)  and nDirection (3)
%                                1 for nConnection (26) and nDirection (13)
%
%   Output Arguments
%   - porosity            : a vector (nImage2D*1), porosity
%   - specificSurfaceArea : a vector (nImage2D*1), surface area/length^3
%   - eulerNumber         : a vector (nImage2D*1), Euler's number  
%
%   Example
%       [BereaFRS200_Results.Original.porosity2D, ...
%        BereaFRS200_Results.Original.specificSurfaceArea2D, ...
%        BereaFRS200_Results.Original.eulerNumber2D] ...
%        = computeMinkowski2D(BereaFRS200{1}, 1)
%   Note
%       In order to run this code, imMinkowski files are needed.
%       "Computation of Minkowski measures on 2D and 3D binary images".
%       David Legland, Kien Kieu and Marie-Francoise Devaux (2007)
%       Image Analysis and Stereology, Vol 26(2), June 2007
%       web: http://www.ias-iss.org/ojs/IAS/article/view/811

%   Revision 2: Sept 2015 Nattavadee Srisutthiyakorn
%   Revision 1: June 2014 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% QC Inputs

if nargin < 2
    option = 1;
end



%% Check whether the input is a matrix or a cell array of matrices
[nX, nY, nZ] = size(image3D);



if iscell(image3D)
    
    % Initialization
    nImage                = length(image3D);
    porosity2D            = cell(nImage, 1);
    specificSurfaceArea2D = cell(nImage, 1);
    eulerNumber2D         = cell(nImage, 1);
    
    for iImage = 1:nImage
        
        disp(['Current image: (',num2str(iImage),'/',num2str(nImage),')'])
        
        [~, ~, nSlice] = size(image3D{iImage});
        try
            for iZ = 1:nSlice
                [ porosity2D{iImage}(iZ,1), specificSurfaceArea2D{iImage}(iZ,1),...
                  eulerNumber2D{iImage}(iZ,1) ] ...
                = computeMK2D( image3D{iImage}(:,:,iZ), option );
            end
        end
        
        % Save every 50 iteration
        if nImage > 50 && floor(iImage/50) == iImage/50
            save('porosity','specificSurfaceArea',...
                 'eulerNumber');
        end
        
    end
    
else
    if nZ == 1
        [ porosity2D, specificSurfaceArea2D, eulerNumber2D ] ...
        = computeMK2D( image3D, option );
    elseif nZ > 1
        for iZ = 1:nZ
        [ porosity2D(iZ,1), specificSurfaceArea2D(iZ,1), eulerNumber2D(iZ,1) ] ...
            = computeMK2D( image3D(:,:,iZ), option );
        end
    end
end

end



function [ porosity, specificSurfaceArea, eulerNumber ] ...
    = computeMK2D( image2D, option )
% For computing a single slice
%% QC Inputs
[nX, nY, nZ] = size(image2D);

% Check inputs
if nZ > 3
    help(mfilename);
    error('Error: image2D input is required to be 2-D matrix')
end


%% Create reverse image(s)
image2DInverse = abs(1-image2D);


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
checkOriginal = any(any(any(image2D,3)));
checkReverse  = any(any(any(image2DInverse,3)));

if and(checkOriginal, checkReverse)
    % Porosity
    try
        porosity = 1 - imAreaDensity(image2D);
    catch
        porosity = NaN;
    end
    
    % Specific Surface Area (Surface Estimate/Length^3)
    try
        specificSurfaceArea = imPerimeter(image2D, nDirection)./(nX.*nY);
    catch
        specificSurfaceArea = NaN;
    end
    
    % Euler Number
    try
        eulerNumber = imEuler2d(image2D, nConnectivity);
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

