% Soeren Sofke, IBS
% 
% Refereence: https://en.wikipedia.org/wiki/Fluent_interface
% MATLAB-example taken from here: https://billbailey.io/2019/05/18/method-chaining-in-matlab/

classdef Calculator    
    properties
        Data
    end
    
    methods
        function obj = Calculator(input_value)
            obj.Data = input_value;
        end
        
        function obj = add(obj, value)
            obj.Data = obj.Data + value;
        end
        
        function obj = subtract(obj, value)
            obj.Data = obj.Data - value;
        end
        
        function obj = divide(obj, value)
            obj.Data = obj.Data / value;
        end
        
        function obj = multiply(obj, value)
            obj.Data = obj.Data * value;
        end
        
        function obj = exponent(obj, value)
            obj.Data = obj.Data^value;
        end
        
        function value = get(obj)
            value = obj.Data;
        end
    end
end