function [ output_args ] = SoftCodeHandler( odorPair )
%DELIVER_ODOR Summary of this function goes here
%   Detailed explanation goes here
global BpodSystem

firstbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorA_bank)];
secbank = ['Bank' num2str(BpodSystem.Data.Custom.OdorB_bank)];

if odorPair < 32
    if ~BpodSystem.EmulatorMode
        CommandValve = Valves2EthernetString(firstbank, odorPair, secbank, odorPair); % odorPair := desired valve number
        TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValve);
    end
elseif odorPair == 32
    nextTrial = max(BpodSystem.Data.Custom.TrialNumber) + 1;
    OdorContrast = BpodSystem.Data.Custom.OdorContrast(nextTrial);
    OdorID = BpodSystem.Data.Custom.OdorID(nextTrial);
    switch OdorID 
        case 1
            OdorA_flow = 100*(.5 + OdorContrast/2);
            OdorB_flow = 100*(.5 - OdorContrast/2);
        case 2
            OdorA_flow = 100*(.5 - OdorContrast/2);
            OdorB_flow = 100*(.5 + OdorContrast/2);
        otherwise
            error('Undefined odorID')
    end
    BpodSystem.Data.Custom.OdorFracA(nextTrial) = OdorA_flow;
    if ~BpodSystem.EmulatorMode
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorA_bank, OdorA_flow)
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorB_bank, OdorB_flow)
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
