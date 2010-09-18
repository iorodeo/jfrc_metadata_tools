classdef NumericValidator < BaseValidator
    % Used for validating numeric data (floats,integers). The range is set 
    % using a range string argument. Validation consists of checking that 
    % the values are within a given range which can be inclusive of 
    % exclusive of the end points.
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
            self.setBoundTypes(rangeString);
            [lowerString, upperString] = self.getBoundStrings(rangeString);
            lowerValue = str2num(lowerString);
            if isempty(lowerValue)
                error('unable to parse range string - lower bound is not a number');
            end
            upperValue = str2num(upperString);
            if isempty(upperValue)
                error('unable to parse range string - upper bound is not a number');
            end
            if lowerValue > upperValue
                error('lower bound is greater than upper bound');
            end
            self.lowerBound = lowerValue;
            self.upperBound = upperValue;
            
        end
        
        function setBoundTypes(self,rangeString)
            % Get type of upper and lower bounds.
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
        end
        
        function [lowerString, upperString] = getBoundStrings(self, rangeString)
            rangeString = strtrim(rangeString);
            % Find comma position and get lower and upper bound values.
            commaPos = findstr(rangeString,',');
            if isempty(commaPos)
                error('range string format unrecognized - no comma');
            end
            if length(commaPos) > 1
                error('range string format unrecognized - too many commas');
            end
            lowerString = rangeString(2:commaPos-1);
            if isempty(lowerString)
                error('unable to parse range string - lower bound string empty');
            end
            upperString = rangeString(commaPos+1:end-1);
             if isempty(upperString)
                error('unable to parse range string - upper bound string empty');
            end
            
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
        
        function value = getValidValue(self)
            % Return a valid value. Currently this is a bit of a kludge,
            % as I'm not really picking the values intelligently.
            if (self.lowerBound == -Inf) && (self.upperBound == Inf)
                value = 0.0;
            elseif self.lowerBound == -Inf
                % Lower bound is -Inf, but upper bound is not Inf
                value = self.upperBound - 1.0;
            elseif self.upperBound == Inf
                % Upper bound is Inf, but lower bound is not -Inf
                value = self.lowerBound + 1.0;
            else
                % neither bound is Inf - pick middle. 
                value = 0.5*(self.lowerBound + self.upperBound);
            end
            
        end
        
    end
    
end