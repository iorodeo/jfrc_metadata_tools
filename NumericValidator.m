classdef NumericValidator < BaseValidator
    % Used for creating validation functions for numeric data (floats,integers) 
    % from range string arguments. Validation consists of checking that the
    % values are within a given range which can be inclusive of exclusive
    % of the end points.
    properties
        lowerBoundType; % inclusive, exclusive
        upperBoundType; % inclusive, exclusive
        lowerBound; 
        upperBound;
    end
    
    methods
        
        function self = NumericValidator(rangeString)
            % Class Constructor
            if nargin > 0       
                self.setBounds(rangeString);
            end
        end
        
        function setBounds(self, rangeString)
            % Set upper and lower bounds of integer validator based on the 
            % rangeString.
            rangeString = strtrim(rangeString);
            % Use first and last characters to determine if bounds are
            % inclusive or exclusive.
            firstChar = rangeString(1);
            switch firstChar
                case '['
                    self.lowerBoundType = 'inclusive';
                case '('
                    self.lowerBoundType = 'exclusive';
                otherwise
                    error('range string has illegal first character %s', firstChar);
            end
            lastChar = rangeString(end);
            switch lastChar
                case ']'
                    self.upperBoundType = 'inclusive';
                case ')'
                    self.upperBoundType = 'exclusive';
                otherwise
                    error('range string has illegal last character %s', lastChar);
            end
            % Find comma position and get lower and upper bound values.
            commaPos = findstr(rangeString,',');
            if isempty(commaPos)
                error('range string format unrecognized - no comma');
            end
            lowerValue = str2num(rangeString(2:commaPos-1));
            if isempty(lowerValue)
                error('unable to parse range string - lower bound is not a number');
            end
            upperValue = str2num(rangeString(commaPos+1:end-1));
            if isempty(upperValue)
                error('unable to parse range string - upper bound is not a number');
            end
            if lowerValue > upperValue
                error('lower bound is greater than upper bound');
            end
            self.lowerBound = lowerValue;
            self.upperBound = upperValue;
         
        end
        
        function [value,flag, msg] = validationFunc(self,value)
            % Apply validation function to given value.
            
            flag = true;
            msg = '';
            
            % Check upper bound.
            switch self.lowerBoundType
                case 'inclusive'
                    if value < self.lowerBound
                        flag = 'false';
                        msg = 'value less than lower bound';
                        return;
                    end
                case 'exclusive'
                    if value <= self.lowerBound
                        flag = false;
                        msg = 'value less than or equal to upper bound';
                        return;
                    end 
                otherwise
                    error('uknown lower bound type');
            end
                
            % Check lower bound.
            switch self.upperBoundType
                case 'inclusive'
                    if value > self.upperBound
                        flag = false;
                        msg = 'value greater than upper bound';
                        return;
                    end
                case 'exclusive'
                    if value >= self.upperBound
                        flag = false;
                        msg = 'value greater than or equal to upper bound';
                        return;
                    end
                otherwise
            end
             
        end
    end
    
end