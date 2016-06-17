function Olf2AFC
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    TaskParameters.GUI.ITI = 0; % (s)
    TaskParameters.GUI.RewardAmount = 30;
    TaskParameters.GUI.StimDelayMin = .2;
    TaskParameters.GUI.StimDelayMax = .5;
    TaskParameters.GUIPanels.General = {'ITI','RewardAmount','StimDelayMin','StimDelayMax'};
    %TaskParameters.GUI.ChoiceDeadLine = 5;
    %TaskParameters.GUI.timeOut = 5; % (s)
    %TaskParameters.GUI.rwdDelay = 0; % (s)
    TaskParameters.GUI.OdorA_bank = 3;
    TaskParameters.GUI.OdorB_bank = 4;
    TaskParameters.GUIPanels.Olfactometer = {'OdorA_bank', 'OdorB_bank'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors

BpodSystem.Data.Custom.OutcomeRecord = nan;
BpodSystem.Data.Custom.TrialValid = true;
% BpodSystem.Data.Custom.BlockNumber = 1;
% BpodSystem.Data.Custom.BlockLen = drawBlockLen(TaskParameters);
BpodSystem.Data.Custom.ChoiceLeft = NaN;
BpodSystem.Data.Custom.Rewarded = NaN;
BpodSystem.Data.Custom.OdorID = randi(2,1,100);
BpodSystem.Data.Custom.OdorContrast = ones(1,100)*.9; % Future: control difficulties via GUI
BpodSystem.Data.Custom.OdorPair = ones(1,100); % DEBUG THIS. SHOULD BE: Valve1=MinOil. Future: Present more than one pair
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
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorA_bank, OdorA_flow)
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, BpodSystem.Data.Custom.OdorB_bank, OdorB_flow)
    clear Odor* flow*
else
    BpodSystem.Data.Custom.OlfIp = '198.162.0.0';
end
BpodSystem.SoftCodeHandlerFunction = 'Deliver_Odor';

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.SideOutcomePlot = axes('Position', [.075 .3 .89 .6]);
Olf2AFC_PlotSideOutcome(BpodSystem.GUIHandles.SideOutcomePlot,'init');
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
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    
    updateCustomDataFields(TaskParameters);
    Olf2AFC_PlotSideOutcome(BpodSystem.GUIHandles.SideOutcomePlot,'update',iTrial);
    iTrial = iTrial + 1;
    BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;    
end
end

function sma = stateMatrix(TaskParameters,iTrial)
global BpodSystem
ValveTimes  = GetValveTimes(TaskParameters.GUI.RewardAmount, [1 3]);
LeftValveTime = ValveTimes(1);
RightValveTime = ValveTimes(2);
clear ValveTimes

if BpodSystem.Data.Custom.OdorID(iTrial) == 1
    LeftPokeAction = 'rewarded_Lin';
    RightPokeAction = 'unrewarded_Rin';
elseif BpodSystem.Data.Custom.OdorID(iTrial) == 2
    LeftPokeAction = 'unrewarded_Lin';
    RightPokeAction = 'rewarded_Rin';
else
    error('Bpod:Olf2AFC:unknownOdorID','Undefined Odor ID')
end

sma = NewStateMatrix();
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {'Port2In', 'stay_Cin'},...
    'OutputActions', {'SoftCode',2,'PWM2',255});
sma = AddState(sma, 'Name', 'stay_Cin',...
    'Timer', BpodSystem.Data.Custom.StimDelay(end),...
    'StateChangeConditions', {'Port2Out','broke_fixation','Tup', 'odor_delivery'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'broke_fixation',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'odor_delivery',...
    'Timer', 0,... % SET MINIMUM TIME?
    'StateChangeConditions', {'Port2Out','wait_Sin'},...
    'OutputActions', {'SoftCode',BpodSystem.Data.Custom.OdorPair(iTrial)});
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer',0,...
    'StateChangeConditions', {'Port1In',LeftPokeAction,'Port3In',RightPokeAction},...
    'OutputActions',{'SoftCode',2,'PWM1',255,'PWM3',255});
sma = AddState(sma, 'Name', 'rewarded_Lin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','water_L'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'rewarded_Rin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','water_R'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Lin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'BNCState',1}); % SHOULD WRITE WAVEFORM TO PULSEPAL WITHIN THIS CODE
sma = AddState(sma, 'Name', 'unrewarded_Rin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'BNCState',1});% RATHER THAN PLAYING WHATEVER IS THERE
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', 1});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', 4});
sma = AddState(sma, 'Name', 'ITI',...
    'Timer',TaskParameters.GUI.ITI,...
    'StateChangeConditions',{'Tup','exit'},...
    'OutputActions',{'SoftCode',32}); % Sets flow rates for next trial
% sma = AddState(sma, 'Name', 'state_name',...
%     'Timer', 0,...
%     'StateChangeConditions', {},...
%     'OutputActions', {});
end

function updateCustomDataFields(TaskParameters)
global BpodSystem
%% OutcomeRecord
% Searches for state names and not number, so won't be affected by
% modifications on state matrix
stOI = find(strcmp('rewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('rewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end})); % States of interest
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
    end
    disp(BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.Custom.OutcomeRecord(end)))
end
BpodSystem.Data.Custom.OutcomeRecord(end+1) = nan;
BpodSystem.Data.Custom.ChoiceLeft(end+1) = NaN;
BpodSystem.Data.Custom.Rewarded(end+1) = NaN;
if numel(BpodSystem.Data.Custom.OutcomeRecord) > numel(BpodSystem.Data.Custom.OdorID) - 10
    BpodSystem.Data.Custom.OdorID = [BpodSystem.Data.Custom.OdorID, randi(2,1,100)];
    BpodSystem.Data.Custom.OdorContrast = [BpodSystem.Data.Custom.OdorContrast, ones(1,100)*.9];
    BpodSystem.Data.Custom.OdorPair = [BpodSystem.Data.Custom.OdorPair ones(1,100)];
    %BpodSystem.Data.Custom.OdorContrast = [BpodSystem.Data.Custom.OdorContrast, randsample([0 logspace(log10(.05),log10(.6), 3)],100,1)];
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