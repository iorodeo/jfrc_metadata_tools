classdef BaseValidator < handle
    % Base class for all validators. Has a dummy validation functions which
    % checks nothing and always returns true.
   methods
       function [value,flag,msg] = validationFunc(self,value)
           flag = true;
           msg = '';
       end
   end
end