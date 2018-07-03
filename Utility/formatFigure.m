function [] = formatFigure(figureHandle, fontSize)
%formatFigure format the figure 
%   Input Arguments
%   - figureHandle : a figure handle, (i.e. 'gca' for current figure)
%   - fontSize     : a integer, size of the font (Matlab Default is 10)
%   Example: formatFigure(gca, 24)

%   Revision
%   24 April 2018 Nattavadee Srisutthiyakorn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
% Font Type 
% fontType  = 'Times New Roman';
fontType  = 'Helvetica (Headings)';

% Font Size
if ~exist('fontSize', 'var')
    fontSize = 24;
end

% Color
figureHandle.Color = [1 1 1]; % White Background
textColor = [0 0 0];


%% Get handles
hAxes    = findall(figureHandle, 'Type', 'Axes');
nAxes    = length(hAxes);

hText    = findall(figureHandle, 'Type', 'text');
nText    = length(hText);

hLegend  = findall(figureHandle, 'Type', 'Legend');
hTextBox = findall(figureHandle, 'Type', 'textbox');



%% Set grid, box
% set(hAxes, 'xgrid', 'on' , 'ygrid', 'on');
set(hAxes, 'box', 'on');


%% Set legend
set(hLegend, 'TextColor', [0 0 0]);
set(hLegend, 'EdgeColor', textColor);
set(hLegend, 'FontName',  fontType);



%% Set textbox
set(hTextBox, 'Color', textColor);
set(hTextBox, 'FontName', fontType);
set(hTextBox, 'FontWeight', 'normal');



%% Set text
for iText = 1:nText
    set(hText,'FontName', fontType);
    set(hText(iText),'FontSize', fontSize - 6);  
end



%% Set font elements in axes
for iAxes = 1:nAxes
    set(hAxes(iAxes), 'XColor', textColor);
    set(hAxes(iAxes), 'YColor', textColor);
    set(hAxes(iAxes), 'FontName', fontType);
    
    set(hAxes(iAxes).Title, 'Color', textColor);
    set(hAxes(iAxes).Title, 'FontName', fontType);
    
    set(hAxes(iAxes),'FontSize', fontSize);
    set(hLegend,'FontSize', fontSize - 6);
    set(hAxes(iAxes).Title,'FontSize', fontSize);
    set(hAxes(iAxes).YLabel,'FontSize', fontSize);
    set(hAxes(iAxes).XLabel,'FontSize', fontSize);
            
end


