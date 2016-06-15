function [ output_args ] = Deliver_Odor( odorPair )
%DELIVER_ODOR Summary of this function goes here
%   Detailed explanation goes here
global BpodSystem

firstbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorAbank)];
secbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorBbank)];

if ~BpodSystem.EmulatorMode
    CommandValve = Valves2EthernetString(firstbank, odorPair, secbank, odorPair); % odorPair := desired valve number
    TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValve);
end

% switch odorID
%     case 0
%         CommandValveMinOil = Valves2EthernetString(firstbank, 2, secbank, 2);
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveMinOil);
%     case 1
%         CommandValveScent = Valves2EthernetString(firstbank, 1, secbank, 1); % From RechiaOlfactometer plugin. Simultaneously sets banks 1 and 2 to valve 1
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveScent);
end

