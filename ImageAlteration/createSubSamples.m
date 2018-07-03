function [ image3DSubsamples ] = createSubSamples( image3D, sizeSubsample, gap )
%createSubSamples creates subsamples of specified size
%
%   Input Arguments
%   - image3D           : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                         pore space (0 = pore, 1 = grain)
%   - sizeSubsample     : an integer, pixel size of subsamples
%   - gap               : an integer, the gap between each subsample
%                         if gap > sizeSubsample there is a gap between 
%                         each subsample
%   Output Arguments
%   - image3DSubsamples : a cell array (nSubsample*1) containing a
%                         (nx*ny*nz) uint8 matrix, 3-D binary image of a
%                         rock (0 = pore, 1 = grain)
%
%   Example
%   [ BereaFRS200 ] = createSubSamples( BereaFR , 200, 200 )
%
%   Note
%       In order to run this code, npermutek.m file is needed. The file
%       can be downloaded from
%       http://www.mathworks.com/matlabcentral/fileexchange/...
%       40546-n-permute-k/content/npermutek.m
%
%   Revision 2: August    2015 Nattavadee Srisutthiyakorn
%   Revision 1: September 2014 Nattavadee Srisutthiyakorn (as SubsamplingEdge.m)
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% QC Inputs

if nargin < 2
    help(mfilename);
    error('Error: please specify subsampling size and gap')
end

[nx, ny, nz] = size(image3D);
if nz < 2
    help(mfilename);
    error('Error: the image is not 3D')
end

% Refer to the subfunction as shown below
[ edge ] = findSubsampleEdge( nz, sizeSubsample, gap);
nImage   = size(edge,1);


image3DSubsamples = cell(1,nImage);
% Assign each subsample into a cell array
for iImage = 1:nImage
    image3DSubsamples{iImage} = image3D([edge(iImage,1):edge(iImage,2)], ...
                                        [edge(iImage,3):edge(iImage,4)], ...
                                        [edge(iImage,5):edge(iImage,6)]);
end



end


