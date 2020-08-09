classdef Fluent % dynamicprops
    properties (Access = private)
        tab
        
        isGroup
        groupTab
        groupIdx
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
            remove = setdiff(thisColumns, varargin);
            obj.tab = removevars(obj.tab, remove);
        end
        
        %%% https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.loc.html
        function obj = row(obj, varargin)
            obj.tab = obj.tab([varargin{:}],:);
        end
        
        %% Group
        function obj = group(obj, varargin)
            %%% Form groups
            subTable = obj.col(varargin{:}).getTable();
            [obj.groupIdx, obj.groupTab] = findgroups(subTable);
            
            %%% Remove group items from table
            obj.tab = removevars(obj.tab, varargin);
            
            %%% Let Fluid know that the user has performed grouping
            obj.isGroup = true;
        end
        
        %% Aggregator -- Descriptive statistics, change size and names of table
        %%% TODO: Discuss if this is a reasonable strategy
        function obj = mean(obj)
            if obj.isGroup
                obj.groupTab.mean = splitapply(@mean, obj.tab, obj.groupIdx);
                obj.tab = obj.groupTab;
                obj = obj.addRowIdx;
                obj.isGroup = false;
            else
                thisVariableNames = obj.tab.Properties.VariableNames;
                thisMeans = nan(size(thisVariableNames));
                
                for idx = 1:numel(thisVariableNames)
                    data = obj.tab.(thisVariableNames{idx});
                    thisMeans(idx) = mean(data);
                end
                
                obj.tab = table(thisMeans', 'VariableNames', {'mean'}, 'RowNames', thisVariableNames);
            end
        end
        
        %% Operator -- Mathmatical operations that manipulates values without changing size and names of table
        function obj = round(obj)
            rNames = obj.tab.Row;
            obj.tab = varfun(@round, obj.tab);
            obj.tab.Row = rNames;
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
        
        function thisTable = getTable(obj)
            thisTable = obj.tab;
        end
    end
end

