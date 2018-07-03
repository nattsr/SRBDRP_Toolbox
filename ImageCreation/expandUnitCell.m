function [ image3D ] = expandUnitCell( image3DUnit, nEx )
%expandUnitCell expands unit cell of crystal lattice to larger size
%   
%   Input Arguments
%   - image3DUnit  : a (nx*ny*nz) uint8 matrix, 3-D binary image of a
%                    rock (0 = pore, 1 = grain) of unit lattice such as
%                    cubic close packing or hexagonal close packing
%   - nZ           : an integer, the expansion factor
%
%   Output Arguments
%   - image3D      : a ((nx*nEx)*(ny*nEx)*(nz*nEx)) uint8 matrix, 3-D 
%                    binary image of a rock (0 = pore, 1 = grain)
%
%   Revision 1: December 2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)
%% 
    image3D     = repmat(image3DUnit, nEx, nEx, nEx);
    
    
    
end

