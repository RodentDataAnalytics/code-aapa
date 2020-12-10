function [f,hStrings] = imagesc_adv(mymatrix, varargin)
%IMAGESC_ADV displays matrix as image with scaled colors and values in each
%box

%INPUT:
%mymatrix : double matrix, it can also be a vector.

%OUTPUT:
%f        : figure handle
%hStrings : text handle

%VARARGIN:
% - Default options:
%    colormap = inverse gray
%    numbers format = %0.2f
% - Custom options 
%   Except from the first the rest are Name-Value Pair Arguments
%    'DISPLAYOFF' : turns figure display off
%    'CMAP'       : colormap
%    'XTICKLABEL' : x-axis tick labels 
%    'YTICKLABEL' : y-axis tick labels 
%    'FORMAT'     : numbers format


% Author: Avgoustinos Vouros

% Thanks to: gnovice @stackoverflow.com
% https://bit.ly/2OOPwlx


    % Default values
    DISPLAYOFF = 0;
    XTick = 1:size(mymatrix,2);
    YTick = 1:size(mymatrix,1);
    XTickLabel_ = num2str(XTick');
    YTickLabel_ = num2str(YTick');
    RANGE = [nanmin(mymatrix,[],'all'),nanmax(mymatrix,[],'all')];
    format = '%0.2f';
    strX = '';
    strY = '';
    
    % Custom values
    for i = 1:length(varargin)
        if isequal(varargin{i},'CMAP')
            caxis(varargin{i+1});
        elseif isequal(varargin{i},'DISPLAYOFF')
            DISPLAYOFF = 1;
        elseif isequal(varargin{i},'XTICKLABEL')
            XTickLabel_ = varargin{i+1};
        elseif isequal(varargin{i},'YTICKLABEL')
            YTickLabel_ = varargin{i+1};
        elseif isequal(varargin{i},'FORMAT')
            format = varargin{i+1};
        elseif isequal(varargin{i},'XLABEL')
            strX = varargin{i+1}; 
        elseif isequal(varargin{i},'YLABEL')    
            strY = varargin{i+1};
        elseif isequal(varargin{i},'RANGE')
            if size(varargin{i+1},2) == 2
                RANGE = varargin{i+1};
            end
        end
    end
    
    % Generate the figure
    if DISPLAYOFF
        f = figure('Visible','off');
    else
        f = figure;
    end
    hold on
    faxis = findobj(f,'Type','axes');
    imagesc(mymatrix,RANGE); 
    colormap(flipud(gray));


    %% MAIN
    
    %Create strings from the matrix values
    textStrings = num2str(mymatrix(:),format);  
    %Remove any space padding
    textStrings = strtrim(cellstr(textStrings));  
    for i = 1:length(textStrings)
        if isequal(textStrings{i},'NaN')
            textStrings{i} = '-';
        end
    end
    %Create x and y coordinates for the strings
    [x,y] = meshgrid(1:length(XTick),1:length(YTick));   
    %Plot the strings
    hStrings = text(x(:),y(:),textStrings(:),'HorizontalAlignment','center');
    %Get the middle value of the color range
    midValue = mean(get(gca,'CLim'));
    %Choose white or black for the
    %text color of the strings so
    %they can be easily seen over
    %the background color
    textColors = repmat(mymatrix(:) > midValue,1,3); 
    %Change the text colors
    set(hStrings,{'Color'},num2cell(textColors,2));  
    %Change the axes tick marks and tick labels
    set(faxis,'XTick',XTick,'XTickLabel',XTickLabel_,... 
            'YTick',YTick,'YTickLabel',YTickLabel_,...
            'TickLength',[0 0]);
    if ~isempty(strX)
        xlabel(faxis,strX)
    end
    if ~isempty(strY)
        ylabel(faxis,strY)
    end
end

