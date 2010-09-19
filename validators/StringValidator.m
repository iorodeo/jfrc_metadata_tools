classdef StringValidator < BaseValidator
    % Used for validating input strings. The list of allowed strings is set
    % using the rangeString which can be a comma separated list of names or
    % a speccial symbol such ass %LDAP, %LINENAME, $EFFECTOR. 
    
    properties
        allowedStrings = '';
    end
    
    methods
        
        function self = StringValidator(rangeString)
            % Class constructor.
            if nargin > 0
                self.setRange(rangeString);
            end
        end
        
        function setRange(self,rangeString)
            % Parse range string to get cell array of allowed strings.
            rangeString = strtrim(rangeString);
            if isempty(rangeString)
                % Range String is empty - this means allow anything.
                self.allowedStrings = '';
            end
            % Based on first character of range string determine is this is
            % a list of stings or a special case
            firstChar = rangeString(1);
            switch firstChar
                case '$'
                    self.setRangeSpecialCase(rangeString);
                otherwise
                    self.setRangeSelectList(rangeString);
            end
        end
        
        function setRangeSelectList(self,rangeString)
            % Parse range string for assuming it is a list of strings 
            % speparated by commas.
            if isempty(rangeString)
                self.allowedStrings = '';
            end
            
            % Parse range string
            commaPos = findstr(rangeString,',');
            stringPos = [0, commaPos, length(rangeString)+1];
            self.allowedStrings = {};
            for i = 1:(length(stringPos)-1)
                n1 = stringPos(i) + 1;
                n2 = stringPos(i+1) - 1;
                if (n1 > n2) 
                    if (i==length(stringPos)-1)
                        % Allow trailing comma in list.
                        continue
                    else
                        error('unable to parse range string');
                    end
                end
                word = rangeString(n1:n2);
                word = strtrim(word);
                self.allowedStrings{i} = word;
            end
        end
        
        function setRangeSpecialCase(self,rangeString)
            % Parse range srting for special cases.
            switch upper(rangeString)
                case '$LDAP'
                    % DUMMY FUNCTION -------------------------
                    self.allowedStrings = dummyGetLDAP();
                case '$LINENAME'
                    % DUMMY FUNCTION -------------------------
                    self.allowedStrings = dummyGetLineNames();
                case '$EFFECTOR'
                    % DUMMY FUNCTION -------------------------
                    self.allowedStrings = dummyGetEffectors();
                otherwise
                    error('unknown special case range string');
            end
            
        end
        
        function [value, flag, msg] = validationFunc(self,value)
            % Apply validation function to given value.
            if isempty(self.allowedStrings)
                flag = true;
                msg = '';
                return;
            else
                flag = false; 
                msg = 'validation error: sting not found';
                for i = 1:length(self.allowedStrings)
                    if strcmp(value,self.allowedStrings{i})
                        flag = true;
                    end
                end
            end
        end
        
        function value = getValidValue(self)
            % Return a valid value. If allowedStrings is empty any string
            % is allowed so we just return the empty string. Otherwise the
            % first string in the list of allowed values is returned.
            if isempty(self.allowedStrings)
                value = '';
            else
                value = self.allowedStrings{1};
            end
        end
    end
end

% Dummy function for development ------------------------------------------
function names = dummyGetLDAP()
% Dummy function for getting LDAP names.
names = {};
N = 100;
for i = 1:N
    names{i} = sprintf('ldap_user_%d', i);
end
names{N+1} = 'bransonk';
names{N+2} = 'robiea';
names{N+3} = 'hirokawaj';
end

function names = dummyGetLineNames()
% Dummy function for getting line names
names = {};
N = 1000;
for i = 1:N
    names{i} = sprintf('line_%d', i);
end
names{N+1} = 'dummyline';
end

function names = dummyGetEffectors()
% Dummy function for getting line names
names = {};
N = 100;
for i = 1:N
    names{i} = sprintf('effector_%d', i);
end
names{N+1} = 'dummyeffector';
end
