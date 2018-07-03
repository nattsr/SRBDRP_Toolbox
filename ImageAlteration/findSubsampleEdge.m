function [ edgeSubsample ] ...
    = findSubsampleEdge( sizeSample, sizeSubsample, gap)
%findSubsampleEdge finds edges of all possible subsamples
%
%   Input Arguments
%   - sizeSample      : an integer, pixel size of the original sample (the
%                       shortest length)
%   - sizeSubsample   : an integer, pixel size of subsamples
%   - gap             : an integer, the gap between each subsample
%                       if gap > sizeSubsample there is a gap between each
%                       subsample
%
%   Output Argument
%   - edgeSubsample   : a matrix (nSubsample*6) indicating the pixel
%                       location of the edge
%
%   Example
%   [ edge ] = findSubsampleEdge( nz, sizeSubsample, gap);
%
%   Note
%       In order to run this code, npermutek.m file is needed. The file
%       can be downloaded from
%       http://www.mathworks.com/matlabcentral/fileexchange/...
%       40546-n-permute-k/content/npermutek.m

%   Revision 2.0 August 2015    Nattavadee Srisutthiyakorn
%   Revision 1.0 September 2014 Nattavadee Srisutthiyakorn
%                               (as SubsamplingEdge.m)
%
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Find every possible edge 
nSlice =  floor((sizeSample - sizeSubsample) / gap + 1);

pxedge = zeros(nSlice,2);
for iSlice = 1:nSlice
    pxedge(iSlice,1) = 1 + ((iSlice - 1) * gap);
    pxedge(iSlice,2) = sizeSubsample + ((iSlice - 1) * gap);
end

nSubsample          = nSlice .^ 3;
edgeSubsample       = zeros(nSubsample,6);
orderCombination    = npermutek([1:nSlice],3);

for j = 1: nSubsample
    edgeSubsample(j,1) = pxedge(orderCombination(j,1),1);
    edgeSubsample(j,2) = pxedge(orderCombination(j,1),2);
    edgeSubsample(j,3) = pxedge(orderCombination(j,2),1);
    edgeSubsample(j,4) = pxedge(orderCombination(j,2),2);
    edgeSubsample(j,5) = pxedge(orderCombination(j,3),1);
    edgeSubsample(j,6) = pxedge(orderCombination(j,3),2);
end

end