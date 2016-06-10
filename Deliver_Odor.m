function [ output_args ] = Deliver_Odor( odorID )
%DELIVER_ODOR Summary of this function goes here
%   Detailed explanation goes here
global BpodSystem

firstbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorAbank)];
secbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorBbank)];

switch odorID
    case 0
        ValveOpenCommand = Valves2EthernetString(firstbank, 0, secbank, 0); % Simultaneously sets banks 1 and 2 to valve 0 (exhaust)
        TCPWrite(IPString, 3336, ValveOpenCommand);
    case 1
        ValveOpenCommand = Valves2EthernetString(firstbank, 1, secbank, 1); % From RechiaOlfactometer plugin. Simultaneously sets banks 1 and 2 to valve 1
        TCPWrite(IPString, 3336, ValveOpenCommand);
    case 2
        ValveCloseCommand = Valves2EthernetString(firstbank, 0, secbank, 0);
        TCPWrite(IPString, 3336, ValveCloseCommand);
end

