classdef Fluent % dynamicprops
    properties (Access = private)
        tab
        groupItems = {}
        hFigure
    end
    
    methods (Access = public)
        %% Data source
        function obj = Fluent(varargin)
            
            %%% data is given, try to convert it to a table
            if nargin > 0
                if isequal('cell', class(varargin{1}))
                    %%% T = cell2table(<C>, [Name], [Value])
                    obj.tab = cell2table(varargin);
                    
                elseif isequal('char', class(varargin{1}))
                    %%% read from file
                    obj = obj.file2table(varargin{1}, varargin{2:end});
                    
                elseif isequal('struct', class(varargin{1}))
                    %%% T = struct2table(<S>, [Name], [Value])
                    obj.tab = struct2table(varargin);
                    
                elseif isequal('table', class(varargin{1}))
                    obj.tab = varargin{1};
                    
                elseif isnumeric(varargin{1})
                    %%% T = array2table(<A>, [Name], [Value])
                    obj.tab = array2table(varargin);
                else
                    
                    %%% data might be the definition of a table
                    obj.tab = table(varargin);
                end
                
                %%% conditionally, add row indexes
                if isempty(obj.tab.Row)
                    obj = obj.addRowIdx;
                end
            end
        end
        
        %% Transformation
        function obj = head(obj, varargin)
            obj.tab = head(obj.tab, varargin{:});
        end
        
        function obj = tail(obj, varargin)
            obj.tab = tail(obj.tab, varargin{:});
        end
        
        %%% https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.filter.html
        function obj = col(obj, varargin)
            thisColumns = obj.tab.Properties.VariableNames;
            remove = setdiff(thisColumns, [obj.groupItems(:)', varargin(:)']);
            obj.tab = removevars(obj.tab, remove);
        end
        
        %%% https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.loc.html
        function obj = row(obj, varargin)
            obj.tab = obj.tab([varargin{:}],:);
        end
        
        %% Group
        function obj = group(obj, varargin)
            obj.groupItems{end+1} = varargin{:};
        end
        
        %% Aggregator -- Descriptive statistics, change size and names of table
        function obj = min(obj)
            obj = obj.statistics(@min);
        end
        
        function obj = mean(obj)
            obj = obj.statistics(@mean);
        end
        
        function obj = max(obj)
            obj = obj.statistics(@max);
        end
        
        %% Operator -- Mathmatical operations that manipulates values without changing size and names of table
        function obj = floor(obj)
            obj = obj.mathematics(@floor);
        end
        
        function obj = round(obj)
            obj = obj.mathematics(@round);
        end
        
        function obj = ceil(obj)
            obj = obj.mathematics(@ceil);
        end
        
        %% Plotting
        function [obj, hFigure] = bar(obj, x, varargin)
            obj = obj.removeCol('GroupCount');
            defaultColNames = obj.tab.Properties.VariableNames;
            
            y = [];
            legendString = {};
            for idx = 1:numel(defaultColNames)
                thisColName = defaultColNames{idx};
                thisData = obj.tab.(thisColName);
                
                if isequal(thisColName, x)
                    xTickLabels = thisData;
                    continue
                end
                
                if isnumeric(thisData)
                    y = [y obj.tab.(thisColName)];
                    legendString{end+1} = thisColName;
                end
            end
            
            hFigure = figure();
            positionSize = hFigure.OuterPosition;
            goldenFactor = (1 + sqrt(5)) * 0.5;
            
            positionSize(3) = positionSize(4) * goldenFactor; %% make wider
            positionSize(2) = positionSize(2) / 2; %% move down
            hFigure.OuterPosition = positionSize;
            
            
            clf; hold on; box on; grid on;
            bar(y)
            legend(legendString, 'interpreter', 'none', 'location', 'northeastoutside');
            
            xticks(1:size(y, 1))
            xticklabels(xTickLabels)
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
        
        function obj = print(obj, filepath)
            fileFormat = filepath(end-2:end);
            print(obj.hFigure, filepath, sprintf('-d%s', fileFormat))
        end
        
        %% Utilitiy -- Overwrite default disp() to have a more appleaing view to Fluent Data Frames
        function disp(obj)
            if height(obj.tab) <= 8
                thisDisplay = obj.tab;
                
            else
                hisHead = head(obj.tab, 6);
                thisTail = tail(obj.tab, 2);
                
                thisDisplay = vertcat(hisHead, thisTail);
                rowIdxToModify = height(hisHead);
                
                thisDisplay.Row{rowIdxToModify} = '...';
                thisNames = thisDisplay.Properties.VariableNames;
                for idx = 1:numel(thisNames)
                    if isequal('cell', class(thisDisplay.(thisNames{idx})(rowIdxToModify)))
                        thisDisplay.(thisNames{idx})(rowIdxToModify) = {' '};
                    elseif isequal('double', class(thisDisplay.(thisNames{idx})(rowIdxToModify)))
                        thisDisplay.(thisNames{idx})(rowIdxToModify) = nan;
                    end%
                end
            end
            
            disp(thisDisplay)
        end
        
    end
    
    methods (Access = private)
        function obj = addRowIdx(obj)
            obj.tab.Row = strsplit(num2str(1:height(obj.tab)))';
        end
        
        function obj = file2table(obj, filename, varargin)
            filename = obj.getFile(filename);
            
            %%% convert file to table
            obj.tab = readtable(filename, varargin{:});
        end
        
        function filename = getFile(~, filename)
            %%% conditionally download the file
            if (contains(filename, 'http://') || contains(filename, 'https://'))
                url = filename;
                filename = tempname;
                websave(filename, url);
            end
        end
        
        function colKeep = colFilterMath(obj)
            obj = obj.removeCol('GroupCount');
            
            thisColumns = obj.tab.Properties.VariableNames;
            isValidColName = setdiff(thisColumns, obj.groupItems);
            
            thiIsNumeric = varfun(@isnumeric, obj.tab);
            thiIsNumeric = obj.removeColPrefix(thiIsNumeric);
            
            thiIsLogical = varfun(@islogical, obj.tab);
            thiIsLogical = obj.removeColPrefix(thiIsLogical);
            
            colKeep = {};
            for idx = 1:numel(isValidColName)
                if thiIsNumeric.(isValidColName{idx}) || thiIsLogical.(isValidColName{idx})
                    colKeep{end+1} = isValidColName{idx};
                end
            end
            
        end
        
        function tab = removeColPrefix(~, tab)
            defaultColNames = tab.Properties.VariableNames;
            idxDelimiter = strfind(defaultColNames, '_');
            
            strippedColNames = {};
            for idx = 1:numel(idxDelimiter)
                if isempty(idxDelimiter{idx})
                    strippedColNames{idx} = defaultColNames{idx};
                else
                    thisName = defaultColNames{idx};
                    strippedColNames{idx} = thisName(idxDelimiter{idx}(1)+1:end);
                end
            end
            
            tab.Properties.VariableNames = strippedColNames;
        end
        
        function obj = statistics(obj, fun)
            inputVariables = obj.colFilterMath;
            
            obj.tab = varfun(fun, obj.tab, 'InputVariables', inputVariables, 'GroupingVariables', obj.groupItems);
            obj.tab = obj.removeColPrefix(obj.tab);
            obj.groupItems = {};
            
            obj = obj.addRowIdx;
        end
        
        function obj = mathematics(obj, fun)
            rNames = obj.tab.Row;
            
            inputVariables = obj.colFilterMath;
            
            obj.tab = varfun(fun, obj.tab, 'InputVariables', inputVariables, 'GroupingVariables', obj.groupItems);
            obj.tab = obj.removeColPrefix(obj.tab);
            obj.tab.Row = rNames;
            
            obj = obj.removeCol('GroupCount');
        end
        
        function obj = removeCol(obj, varargin)
            defaulColNames = obj.tab.Properties.VariableNames;
            keep = setdiff(defaulColNames, varargin{:});
            remove = setdiff(defaulColNames, keep);
            obj.tab = removevars(obj.tab, remove);
        end
        
        function thisTable = getTable(obj)
            thisTable = obj.tab;
        end
    end
end

