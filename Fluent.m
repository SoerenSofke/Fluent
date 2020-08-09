classdef Fluent % dynamicprops
    properties (Access = private)
        table_
        groupIdx_
        group_
    end
    
    methods (Access = private)
        function obj = addRowIdx(obj)
            obj.table_.Row = strsplit(num2str(1:height(obj.table_)))';
        end
        
        function addVariablesAsProperties
        end
    
    end    

    
    methods (Access = public)
        function obj = Fluent(varargin)
            
            %%% data is given, try to convert it to a table
            if nargin > 0
                if isequal('table', class(varargin{1}))
                    obj.table_ = data;
                    
                elseif isequal('struct', class(varargin{1}))
                    %%% T = struct2table(S)
                    %%% T = struct2table(S,Name,Value)
                    obj.table_ = struct2table(varargin);
                    
                elseif isequal('cell', class(varargin{1}))
                    %%% T = cell2table(C)
                    %%% T = cell2table(C,Name,Value)
                    obj.table_ = cell2table(varargin);
                    
                elseif isequal('char', class(varargin{1}))
                    %%% read from file
                    obj = obj.read_csv(varargin{1}, varargin{2:end});
                    
                elseif isnumeric(varargin{1})
                    %%% T = array2table(A)
                    %%% T = array2table(A,Name,Value)
                    obj.table_ = array2table(varargin);
                    
                else
                    %%% data might be the definition of a table
                    obj.table_ = table(varargin);
                end
                
                %%% add row names
                obj = obj.addRowIdx;
            end
        end
        
        function disp(obj)
            if height(obj.table_) <= 8
                thisDisplay = obj.table_;
                
            else                
                hisHead = head(obj.table_, 6);
                thisTail = tail(obj.table_, 2);
                
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
        
        function obj = read_csv(obj, filename, varargin)
            %%% conditionally dowmnload the file
            if (contains(filename, 'http://') || contains(filename, 'https://'))
                url = filename;
                filename = tempname;
                websave(filename, url);
            end
            
            %%% convert file to table
            obj.table_ = readtable(filename, varargin{:});
            
%             %%% add variable (column) names dynamically
%             thisVariableNames = obj.table_.Properties.VariableNames;
%             for idx = 1:numel(thisVariableNames)
%                 variableName = thisVariableNames{idx};
%                 prop = obj.addprop(variableName);
%                 prop.GetMethod = @(obj)getSubTable(obj,variableName);
%             end
        end
        
        function obj = getSubTable(obj, variableName)
            obj.table_ = obj.table_(:, variableName);
        end
        
        function obj = head(obj, varargin)
            obj.table_ = head(obj.table_, varargin{:});
        end
        
        function obj = tail(obj, varargin)
            obj.table_ = tail(obj.table_, varargin{:});
        end
        
        function obj = groupby(obj, variableName)
            [obj.groupIdx_, obj.group_] = findgroups(obj.table_(:, variableName));
        end
        
        function obj = mean(obj)
            obj.agg('mean');
        end
        
        function obj = agg(obj, varargin)
            aggregations = varargin;
            
            for idx = 1:numel(aggregations)
                thisAaggregation = aggregations{idx};
                
                obj.group_.(lower(thisAaggregation)) = eval(['splitapply(@' thisAaggregation ', obj.table_, obj.groupIdx_)']);
            end
            
            disp(obj.group_);
        end
        
        %         function obj = mean(obj)
        %             thisVariableNames = obj.table_.Properties.VariableNames;
        %
        %             thisMeans = [];
        %             for idx = 1:numel(thisVariableNames)
        %                 data = obj.table_.(thisVariableNames{idx});
        %
        %                 if isnumeric(data)
        %                     thisMeans(idx) = mean(data);
        %                 else
        %                     thisMeans(idx) = nan;
        %                 end
        %             end
        %
        %             obj.table_ = table(thisMeans', 'VariableNames', {'Mean'}, 'RowNames', thisVariableNames);
        %             disp(obj.table_)
        %         end
        
        function obj = copy_to(obj, variableName)
            assignin('caller', variableName, obj.table_);
        end
    end
end

