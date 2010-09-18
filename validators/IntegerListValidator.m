classdef IntegerListValidator < BaseValidator
    % Used for validating lists of integer data. The range is set
    % using a range string argument. 
    % 
    % Note, this function isn't
    
    methods
        function self = IntegerListValidator(rangeString)
            % Class Constructor
            if nargin > 0
                self.setRange(rangeString);
            end
        end
        
        function setRange(self,rangeString)
            % Set the range of the validator using the range sting.
            rangeString = strtrim(rangeString);
        end
        
        function [value,flag,msg] = validationFunc(self,value)
            % Applies validation to the given value.
            flag = true;
            msg = '';
        end
        
        function value = getValidValue(self)
            % Returns a valid value
            value = '1,2,3';
        end
    end
    
end

function listStringToArray(listString)
end

function arrayToListString(array)
end