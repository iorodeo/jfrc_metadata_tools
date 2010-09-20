classdef DateTimeValidator < NumericValidator
    % Used for validating datetime data. Range is set using a range string
    % argument. Validation consists of checking that the time values are
    % within a given range which can be inclusive of exclusive of the end points.
    % The end points are checked to insure that they are integers and the
    % value is trucated to an integer during the check.
     
    properties
        format;
    end
    
    properties (Constant, Hidden)
        fullFormatString = 'yyyy-mm-ddTHH:MM:SS';
        daysFormatString = 'yyyy-mm-ddT00:00:00';
        fullFormat = 0;
        daysFormat = 1;
    end
    
    properties (Dependent)
        formatString;
        lowerBoundString;  % Display lower bound in datetime string format
        upperBoundString;  % Display upper bound in datetime string format
    end
    
    methods
        function self = DateTimeValidator(rangeString)
            % Constructor
            if nargin > 0
                self.setRange(rangeString);
            end
        end
        
        function setRange(self,rangeString)
            % Are there any bounds ???
            if isempty(rangeString)
                self.hasBounds = false;
                self.format = self.fullFormat;
            end
            % Set options
            rangeString = self.setOptions(rangeString);          
            % Set the lower and upper bounds based on the range sting.
            setRange@NumericValidator(self,rangeString);
        end
        
        function rangeString = setOptions(self,rangeString)
            % Check to see if any options such as "days" has been set on
            % the range.
            rangeString = strtrim(rangeString);     
            % Check to see if any option has been set.
            commaPos = findstr(rangeString,',');
            if length(commaPos) > 2
                error('cannot parse range string - too many commas');
            end
            if length(commaPos) == 2
                optionString = rangeString(commaPos(2)+1:end);
                optionsString = strtrim(optionString);
                rangeString = rangeString(1:commaPos(2)-1);
                if strcmpi(optionsString,'days')
                    self.format = self.daysFormat;
                else
                    error('cannot parse range string - unknown option');
                end
            else
                self.format = self.fullFormat;
            end          
        end
        
        function setRangeValues(self,rangeString)
            % Get upper and lower bound values.
            rangeString = strtrim(rangeString);
            if isempty(rangeString)
                self.lowerBound = -Inf;
                self.upperBound = Inf;
            else
                [lowerString, upperString] = self.getRangeStrings(rangeString);
                try
                    lowerValue = eval(lowerString);
                catch ME
                    error('range string lower value format incorrent: %s', ME.message);
                end
                try
                    upperValue = eval(upperString);
                catch ME
                    error('range string upper value incorrect format: %s', ME.message);
                end
                if lowerValue > upperValue
                    error('lower bound is greater than upper bound');
                end
                
                % Pass values through format string to truncate if
                % required.
                if abs(lowerValue) ~= Inf
                    lowerString = dateNumberToDateString(lowerValue,self.formatString);
                    lowerValue = dateStringToDateNumber(lowerString, self.formatString);
                end
                if abs(upperValue) ~= Inf
                    upperString = dateNumberToDateString(upperValue,self.formatString);
                    upperValue = dateStringToDateNumber(upperString, self.formatString);  
                end
                self.lowerBound = lowerValue; 
                self.upperBound = upperValue;    
            end
        end
        
        function [value,flag,msg] = validationFunc(self,value)
            % Apply validation to given value
            
            if isempty(value)
                % Value is empty - return true. Only apply validatation if
                % the user actually sets a value.
                flag = true;
                msg = '';
                return;
            end
            
            try
                % Convert to date number string
                floatString = dateStringToFloatString(value,self.formatString);
            catch ME
                flag = false;
                msg = sprintf('unable to convert value to date number: %s',ME.message);
                return;
            end
            
            % Apply parent class validation
            [floatString,flag,msg] = validationFunc@NumericValidator(self,floatString);
            
            % Convert value back to date string
            value = floatStringToDateString(floatString,self.formatString);
        end
        
        function value = getValidValue(self)
            % Returns a valid value.
            floatString = getValidValue@NumericValidator(self);
            value = floatStringToDateString(floatString,self.formatString);
        end
        
        function test = isFiniteRange(self)
            % Test if range is finite
            test = false;
            if self.format == self.daysFormat
                if (self.lowerBound ~= -Inf) && (self.upperBound ~= Inf)
                    test = true;
                end
            end
        end
        
        function lowerBoundString = get.lowerBoundString(self)
            % Get dependent property lowerBoundString which gives the
            % lowerBound as a datetime string.
            if self.lowerBound == -Inf
                lowerBoundString = '-Inf';
            else
                lowerBoundString = dateNumberToDateString(self.lowerBound,self.formatString);
            end
        end
        
        function upperBoundString = get.upperBoundString(self)
            % Get the dependent property upperBoundStirng which gives the
            % upperBound as a datetime string.
            if self.upperBound == Inf
                upperBoundString = 'Inf';
            else
                upperBoundString = dateNumberToDateString(self.upperBound,self.formatString);
            end
        end
        
        function formatString = get.formatString(self)
            % Select format String based on format option
            switch self.format
                case self.fullFormat
                    formatString = self.fullFormatString;
                case self.daysFormat
                    formatString = self.daysFormatString;
                otherwise
                    error('unknown format string');
            end
        end  
    end
end

function dateString = floatStringToDateString(floatString,format)
% Converts a float string to a date string
dateNumber = str2num(floatString);
dateString = dateNumberToDateString(dateNumber,format);
end

function floatString = dateStringToFloatString(dateString,format)
% Converts a date string to a float string
dateNumber = dateStringToDateNumber(dateString,format);
floatString = num2str(dateNumber);
end

function dateString = dateNumberToDateString(dateNumber,format)
% Converts a date number to a date string.
dateString = datestr(dateNumber,format);
end

function dateNumber = dateStringToDateNumber(dateString,format)
% Converts a date string to a date number.
try
    dateNumber = datenum(dateString,format);
catch ME
    error( ...
        'unable to convert date string to date number: %s, required format: %s', ...
        ME.message, ...
        format ...
        );
end
end