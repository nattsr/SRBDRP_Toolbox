function [ image3DConnected ] = createConnectedPorespace( image3D )
%createConnectedPorespace creates a 3-D binary image of connected pore space
%
%   Input Arguments
%   - image3D           : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                         pore space (0 = pore, 1 = grain)
%
%   Output Arguments
%   - image3DConnected  : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                         effective (connected) pore space 
%                        (0 = pore, 1 = grain)

%   Revision 1: October  2015 Nattavadee Srisutthiyakorn                              
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Initialization
[nx, ny, nz]        = size(image3D);
image3DConnected    = ones(nx, ny, nz);


% Step 1: Labeling the pores
% Inverse grains <-> pores
image3DInverse      = abs(1 - image3D);
poreLabel           = bwconncomp(image3DInverse);
image3DInverseLabel = labelmatrix(poreLabel);


% Step 2: Find the label number that exist on both ends
tempFirstSlide  = image3DInverseLabel(:,:,1);
tempLastSlide   = image3DInverseLabel(:,:,end);

labelFirstSlide = unique(tempFirstSlide);
labelLastSlide  = unique(tempLastSlide);
labelEffective  = intersect(labelFirstSlide, labelLastSlide);


% Step 3: Create connected pore space
nLabel = length(labelEffective);
for iLabel = 1:nLabel
    label = labelEffective(iLabel);
    if label >= 1 % Pore = 1+ -> 0
        image3DConnected(image3DInverseLabel == label) = 0; 
    else % Grain = 0 -> 1
        image3DConnected(image3DInverseLabel == label) = 1; 
    end 
end



end