classdef DateTimeValidator < NumericValidator
    % Used for validating datetime data. Range is set using a range string 
    % argument. Validation consists of checking that the time values are 
    % within a given range which can be inclusive of exclusive of the end points. 
    % The end points are checked to insure that they are integers and the 
    % value is trucated to an integer during the check.
    
    properties (Constant)
        format = 'yyyy-mm-ddTHH:MM:SS';
    end
    
    properties (Dependent)
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
            % Set the lower and upper bounds based on the range sting. 
           setRange@NumericValidator(self,rangeString); 
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
                self.lowerBound = lowerValue;
                self.upperBound = upperValue;   
            end
        end
        
        function [value,flag,msg] = validationFunc(self,value)
            % Apply validation to given value
            try
                floatString = dateStringToFloatString(value,self.format);
            catch ME
                flag = false;
                msg = ME.message;
                return;
            end
            [floatString,flag,msg] = validationFunc@NumericValidator(self,floatString);
            value = floatStringToDateString(floatString,self.format);
        end
        
        function value = getValidValue(self)
            % Returns a valid value.    
            floatString = getValidValue@NumericValidator(self);
            value = floatStringToDateString(floatString,self.format);
        end
        
        function lowerBoundString = get.lowerBoundString(self)
            % Get dependent property lowerBoundString which gives the
            % lowerBound as a datetime string.
            if self.lowerBound == -Inf
                lowerBoundString = '-Inf';
            else
                lowerBoundString = dateNumberToDateString(self.lowerBound,self.format);
            end     
        end
        
        function upperBoundString = get.upperBoundString(self)
            % Get the dependent property upperBoundStirng which gives the
            % upperBound as a datetime string.
            if self.upperBound == Inf
                upperBoundString = 'Inf';
            else
                upperBoundString = dateNumberToDateString(self.upperBound,self.format);
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
%dateString = datestr(dateNumber,'yyyy-mm-ddTHH:MM:SS');
dateString = datestr(dateNumber,format);
end

function dateNumber = dateStringToDateNumber(dateString,format)
% Converts a date string to a date number.
try
    %dateNumber = datenum(dateString,'yyyy-mm-ddTHH:MM:SS');
    dateNumber = datenum(dateString,format);
catch ME
    error( ...
        'unable to convert date string to date number: %s, required format: %s', ...
        ME.message, ...
        format ...
        );
end
end