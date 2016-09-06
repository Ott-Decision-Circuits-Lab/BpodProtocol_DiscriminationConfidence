function [ output_args ] = SoftCodeHandler( odorPair )
%DELIVER_ODOR Summary of this function goes here
%   Detailed explanation goes here
global BpodSystem
global TaskParameters

firstbank = ['Bank' num2str(TaskParameters.GUI.OdorA_bank)];
secbank = ['Bank' num2str(TaskParameters.GUI.OdorB_bank)];

if odorPair < 32
    if ~BpodSystem.EmulatorMode
        CommandValve = Valves2EthernetString(firstbank, odorPair, secbank, odorPair); % odorPair := desired valve number
        TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValve);
    end
elseif odorPair == 32
    nextTrial = numel(BpodSystem.Data.Custom.TrialNumber) + 2;
    OdorA_flow = BpodSystem.Data.Custom.OdorFracA(nextTrial);
    OdorB_flow = 100 - OdorA_flow;
    if ~BpodSystem.EmulatorMode
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorA_bank, OdorA_flow)
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorB_bank, OdorB_flow)
    end
end

% switch odorID
%     case 0
%         CommandValveMinOil = Valves2EthernetString(firstbank, 2, secbank, 2);
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveMinOil);
%     case 1
%         CommandValveScent = Valves2EthernetString(firstbank, 1, secbank, 1); % From RechiaOlfactometer plugin. Simultaneously sets banks 1 and 2 to valve 1
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveScent);
end

