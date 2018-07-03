function [ image3DLowerResolution ] ...
    = createLowerResolutionImage( image3D, averageWindow, threshold )
%createLowerResolutionImage creates lower resolution image
%
%   Input Arguments
%   - image3D           : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                         pore space (0 = pore, 1 = grain)
%   - averageWindow     : an integer, pixel length for averaging window
%   - threshold         : a ratio, threshold to clarify whether the new
%                         pixel is grain space or pore space
%
%   Output Arguments
%   - image3DLowerResolution : a (nx'*ny'*nz') uint8 matrix, 3-D binary
%                              image of a rock (0 = pore, 1 = grain)
%
%   Note
%       In order to run this code, npermutek.m file is needed. The file
%       can be downloaded from
%       http://www.mathworks.com/matlabcentral/fileexchange/...
%       40546-n-permute-k/content/npermutek.m
%
%   Revision 2.0 August  2015 Nattavadee Srisutthiyakorn
%   Revision 1.0 Febuary 2014 Nattavadee Srisutthiyakorn
%
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% QC Inputs
if nargin < 3
    threshold = 0.5;
end



%% Program
[nx, ny, nz] = size(image3D); 

[ edge ] = findSubsampleEdge(nz, averageWindow, averageWindow);
newnz = round(size(edge,1)^(1/3));

image3DLowerResolution = zeros(newnz, newnz, newnz);
k = 1;
for l = 1:newnz
    for m = 1:newnz
        for n = 1:newnz
            
            temp = image3D([edge(k,1):edge(k,2)], ...
                           [edge(k,3):edge(k,4)], ...
                           [edge(k,5):edge(k,6)]);
            tempsolid = mean2(temp);
            if tempsolid < threshold
                image3DLowerResolution(l,m,n) = 0;
            else
                image3DLowerResolution(l,m,n) = 1;
            end
            
            k = k + 1;
        end
    end
end



end



