classdef HS2000D_interface < handle
    % Very basic interface to the precon HS-2000D RH & temparature sensor.
    
    properties(Hidden=true)
        Sensor
    end
    
    methods
        function obj = HS2000D_interface(Port)
            obj.Sensor = serial(Port,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','hardware','Terminator','CR');
        end
        function [T,H] = read_values(obj)
            fopen(obj.Sensor);
            obj.Sensor.DataTerminalReady = 'on';
            Readout = fgetl(obj.Sensor);
            fclose(obj.Sensor);
            Readout
            H = []; %Readout(3:6);
            T = []; %Readout(10:13);
        end
    end
end