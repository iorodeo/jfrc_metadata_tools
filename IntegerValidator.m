classdef IntegerValidator < NumericValidator
    % Used for creating validation functions for integer data types from 
    % range string arguments. Validation consists of checking that the values 
    % are within a given range which can be inclusive of exclusive of the 
    % end points. The end points are checked to insure that they are
    % integers and the value is trucated to an integer during the check.
    methods
        function self = IntegerValidator(rangeString)
            if nargin > 0
                self.setBounds(rangeString);
            end
        end
        function setBounds(self, rangeString)
            setBounds@NumericValidator(self,rangeString);
            % Insure that upper and lower bounds are integers if not throw
            % an error.
            if self.upperBound ~= Inf
                upperFrac = self.upperBound - floor(self.upperBound);
                
                if upperFrac ~= 0
                    error('upper bound of integer range in not an integer');
                end
            end
            if self.lowerBound ~= -Inf
                lowerFrac = self.lowerBound - floor(self.lowerBound);
                if lowerFrac ~= 0
                    error('lower bound of integer range in not an integer');
                end
            end
        end
        function [value,flag,msg] = validationFunc(self,value)
            % Truncate value to integer
            value = floor(value);
            [value,flag,msg] = validationFunc@NumericValidator(self,value);
        end
    end
end