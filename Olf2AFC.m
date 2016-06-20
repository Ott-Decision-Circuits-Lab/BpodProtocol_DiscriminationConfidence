function Olf2AFC
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    TaskParameters.GUI.ITI = 2; % (s)
    TaskParameters.GUI.RewardAmount = 30;
    TaskParameters.GUI.StimDelayMin = 0;%.2;
    TaskParameters.GUI.StimDelayMax = 0;%.6;
    %TaskParameters.GUI.ChoiceDeadLine = 5;
    TaskParameters.GUI.RwdDelay = 0; % (s) % UNUSED
    TaskParameters.GUIPanels.General = {'ITI','RewardAmount','StimDelayMin','StimDelayMax','RwdDelay'};
    TaskParameters.GUI.TimeOut = 2; % (s)
    TaskParameters.GUI.TrialSelection = 3;
    TaskParameters.GUIMeta.TrialSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.TrialSelection.String = {'Flat','Manual','BiasCorrecting'};
    TaskParameters.GUIPanels.BiasControl = {'TimeOut','TrialSelection'};
    TaskParameters.GUI.OdorA_bank = 3;
    TaskParameters.GUI.OdorB_bank = 4;
    TaskParameters.GUIPanels.Olfactometer = {'OdorA_bank', 'OdorB_bank'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors

BpodSystem.Data.Custom.OutcomeRecord = nan;
BpodSystem.Data.Custom.TrialValid = true;
BpodSystem.Data.Custom.BrokeFix = false;
BpodSystem.Data.Custom.BrokeFixTime = NaN;
% BpodSystem.Data.Custom.BlockNumber = 1;
% BpodSystem.Data.Custom.BlockLen = drawBlockLen(TaskParameters);
BpodSystem.Data.Custom.ChoiceLeft = NaN;
BpodSystem.Data.Custom.Rewarded = NaN;
BpodSystem.Data.Custom.OdorID = randi(2,1,20);
BpodSystem.Data.Custom.OdorContrast = ones(1,20)*.9; % Future: control difficulties via GUI
BpodSystem.Data.Custom.OdorPair = ones(1,20); % DEBUG THIS. SHOULD BE: Valve1=MinOil. Future: Present more than one pair
BpodSystem.Data.Custom.OdorFracA = NaN;
BpodSystem.Data.Custom.OdorA_bank = TaskParameters.GUI.OdorA_bank;
BpodSystem.Data.Custom.OdorB_bank = TaskParameters.GUI.OdorB_bank;
BpodSystem.Data.Custom.StimDelay = random('unif',TaskParameters.GUI.StimDelayMin,TaskParameters.GUI.StimDelayMax);
BpodSystem.Data.Custom.TrialNumber = 1;
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%BpodSystem.Data.Custom.OdorContrast = randsample([0 logspace(log10(.05),log10(.6), 3)],100,1);

%% Olfactometer Madness

if ~BpodSystem.EmulatorMode
    BpodSystem.Data.Custom.OlfIp = FindOlfactometer;
    if isempty(BpodSystem.Data.Custom.OlfIp)
        error('Bpod:Olf2AFC:OlfComFail','Failed to connect to olfactometer')
    end
    %SetCarrierFlowRate()
    OdorContrast = BpodSystem.Data.Custom.OdorContrast(1);
    OdorID = BpodSystem.Data.Custom.OdorID(1);
    if OdorID == 1
        OdorA_flow = 100*(.5 + OdorContrast/2);
        OdorB_flow = 100*(.5 - OdorContrast/2);
    else
        OdorA_flow = 100*(.5 - OdorContrast/2);
        OdorB_flow = 100*(.5 + OdorContrast/2);
    end
    BpodSystem.Data.Custom.OdorFracA(1) = OdorA_flow;
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorA_bank, OdorA_flow)
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorB_bank, OdorB_flow)
    clear Odor* flow*
else
    BpodSystem.Data.Custom.OlfIp = '198.162.0.0';
end
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [200 200 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position', [.075 .15 .89 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsyc = axes('Position', [.075 .6 .12 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position', [2*.075+.12 .6 .12 .3]);
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix(TaskParameters,iTrial);
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.Data.TrialSettings(iTrial) = TaskParameters;
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    
    updateCustomDataFields(TaskParameters);
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    iTrial = iTrial + 1;
    BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;    
end
end

function updateCustomDataFields(TaskParameters)
global BpodSystem
%% OutcomeRecord
% Searches for state names and not number, so won't be affected by
% modifications in state matrix
stOI = find(strcmp('rewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('rewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('broke_fixation',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end})); % States of interest
if any(ismember(stOI,BpodSystem.Data.RawData.OriginalStateData{end}))
    BpodSystem.Data.Custom.OutcomeRecord(end) = stOI(ismember(stOI,BpodSystem.Data.RawData.OriginalStateData{end}));
    if strcmp('rewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
        BpodSystem.Data.Custom.ChoiceLeft(end) = 1;
        BpodSystem.Data.Custom.Rewarded(end) = 1;
    elseif strcmp('rewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
        BpodSystem.Data.Custom.ChoiceLeft(end) = 0;
        BpodSystem.Data.Custom.Rewarded(end) = 1;
    elseif strcmp('unrewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
        BpodSystem.Data.Custom.ChoiceLeft(end) = 1;
        BpodSystem.Data.Custom.Rewarded(end) = 0;
    elseif strcmp('unrewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
        BpodSystem.Data.Custom.ChoiceLeft(end) = 0;
        BpodSystem.Data.Custom.Rewarded(end) = 0;
    elseif strcmp('broke_fixation',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
        BpodSystem.Data.Custom.BrokeFix(end) = true;
        BpodSystem.Data.Custom.BrokeFixTime(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin);
        BpodSystem.Data.Custom.TrialValid(end) = false;
    end
end
BpodSystem.Data.Custom.OutcomeRecord(end+1) = nan;
BpodSystem.Data.Custom.ChoiceLeft(end+1) = NaN;
BpodSystem.Data.Custom.Rewarded(end+1) = NaN;
BpodSystem.Data.Custom.BrokeFix(end+1) = false;
BpodSystem.Data.Custom.BrokeFixTime(end+1) = NaN;
BpodSystem.Data.Custom.TrialValid(end+1) = true;
if numel(BpodSystem.Data.Custom.OutcomeRecord) > numel(BpodSystem.Data.Custom.OdorID) - 10
    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Flat'
            newOdorID = randi(2,1,10);
            newOdorContrast = ones(1,10)*.9;
            newOdorPair = ones(1,10);
        case 'Manual'
            %newOdorContrast = randsample([0 logspace(log10(.05),log10(.6), 3)],10,1);
            error('Bpod:Olf2AFC:UndConst_ManualTrialSelection','Option under construction. Use ''Flat'' or ''BiasCorrecting'' instead.')
        case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
            newOdorContrast = ones(1,10)*.9;
            newOdorPair = ones(1,10);
            ndxCorrect = BpodSystem.Data.Custom.Rewarded(1:end-1) == 1;
            oldOdorID = BpodSystem.Data.Custom.OdorID(1:numel(ndxCorrect));
            newOdorID = randsample(2,10,1,1-[sum(oldOdorID==1 & ndxCorrect)/sum(ndxCorrect), ...
                sum(oldOdorID==2 & ndxCorrect)/sum(ndxCorrect)])';
    end
    BpodSystem.Data.Custom.OdorID = [BpodSystem.Data.Custom.OdorID, newOdorID];
    BpodSystem.Data.Custom.OdorContrast = [BpodSystem.Data.Custom.OdorContrast, newOdorContrast];
    BpodSystem.Data.Custom.OdorPair = [BpodSystem.Data.Custom.OdorPair newOdorPair];
    clear newOdor* oldOdorID
end
%% Olfactometer banks
BpodSystem.Data.Custom.OdorA_bank = TaskParameters.GUI.OdorA_bank;
BpodSystem.Data.Custom.OdorB_bank = TaskParameters.GUI.OdorB_bank;
%% Delays
BpodSystem.Data.Custom.StimDelay(end+1) = random('unif',TaskParameters.GUI.StimDelayMin,TaskParameters.GUI.StimDelayMax);
%% Block count
% nTrialsThisBlock = sum(BpodSystem.Data.Custom.BlockNumber == BpodSystem.Data.Custom.BlockNumber(end));
% if nTrialsThisBlock >= TaskParameters.GUI.blockLenMax
%     % If current block len exceeds new max block size, will transition
%     BpodSystem.Data.Custom.BlockLen(end) = nTrialsThisBlock;
% end
% if nTrialsThisBlock >= BpodSystem.Data.Custom.BlockLen(end)
%     BpodSystem.Data.Custom.BlockNumber(end+1) = BpodSystem.Data.Custom.BlockNumber(end)+1;
%     BpodSystem.Data.Custom.BlockLen(end+1) = drawBlockLen(TaskParameters);
%     BpodSystem.Data.Custom.LeftHi(end+1) = ~BpodSystem.Data.Custom.LeftHi(end);
% else
%     BpodSystem.Data.Custom.BlockNumber(end+1) = BpodSystem.Data.Custom.BlockNumber(end);
%     BpodSystem.Data.Custom.LeftHi(end+1) = BpodSystem.Data.Custom.LeftHi(end);
% end
%display(BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.RawData.OriginalStateData{end}))

end

% function BlockLen = drawBlockLen(TaskParameters)
% BlockLen = 0;
% while BlockLen < TaskParameters.GUI.blockLenMin || BlockLen > TaskParameters.GUI.blockLenMax
%     BlockLen = ceil(exprnd(sqrt(TaskParameters.GUI.blockLenMin*TaskParameters.GUI.blockLenMax)));
% end
% end