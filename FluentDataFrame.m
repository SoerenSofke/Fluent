classdef FluentDataFrame < dynamicprops
    properties (Access = private)
        table_
        groupIdx_
        group_        
    end
    
    methods
        function obj = read_csv(obj, filename, varargin)
            %%% conditionally dowmnload the file
            if (contains(filename, 'http://') || contains(filename, 'https://'))
                url = filename;
                filename = tempname;
                websave(filename, url);
            end
            
            %%% convert file to table
            obj.table_ = readtable(filename, varargin{:});
            
            %%% add variable (column) names dynamically
            thisVariableNames = obj.table_.Properties.VariableNames;
            for idx = 1:numel(thisVariableNames)
                variableName = thisVariableNames{idx};            
                prop = obj.addprop(variableName);
                prop.GetMethod = @(obj)getSubTable(obj,variableName);
            end
        end
        
        function obj = getSubTable(obj, variableName)
            obj.table_ = obj.table_(:, variableName);
        end
        
        function obj = head(obj, varargin)
            disp(head(obj.table_, varargin{:}));
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

