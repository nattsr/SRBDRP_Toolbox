function [ permeability ] = kozenyCarman3( geomFactor, phi, d, ...
                                           tortuosity, dl )
%kozenyCarman3 computes permeability using form 3 of Kozeny-Carman equation
%   permeability = (geomFactor ./ 0.5) .* (1/72) .* d.^2 .* ...
%                   phi.^3 ./ ((1 - phi).^2 .* tortuosity.^2);
%
%   Input Arguments
%   - geomFactor   : a double, geometric factor (unitless)
%                    0.5   for pipe with circle or ellipse cross-section
%                    0.562 for pipe with square cross-section
%                    0.6   for pipe with equilateral triangle cross-section
%                    for any other shapes, 0.5 is typically assumed.
%   - phi          : a double, porosity (unitless)
%   - d            : a double, grain size diameter (unit: pixel length or 
%                    meter if dl = 1)
%   - tortuosity   : a double, length of flow path over length of frame
%                    (unitless)
%   - dl           : a double, the length of one pixel in meter
%                    (dx = 0.002 mm -> dl = 0.002.* 0.001 m). dl = 1 is
%                    there's no correction needed
%
%   Output Arguments
%   - permeability : a double, permeability in mD (millidarcy)
%

%   Revision 1: July   2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%%
% Convert unit m^2 to millidarcy
m2tomD = 1 ./ 0.986923 ./ 10.^-12 .* 1000;

% Change the scale
d = d .* dl;

% Calculate permeability
permeability = m2tomD .* (geomFactor ./ 0.5) .* (1/72) .* d.^2 .* ...
               phi.^3 ./ ((1 - phi).^2 .* tortuosity.^2);

           
           
end
