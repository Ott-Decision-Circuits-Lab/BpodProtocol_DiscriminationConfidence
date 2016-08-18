function Olf2AFC
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
%% Task parameters
global TaskParameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %% General
    TaskParameters.GUI.ITI = 0; % (s)
    TaskParameters.GUI.RewardAmount = 25;    
    TaskParameters.GUI.ChoiceDeadLine = 5;
    TaskParameters.GUI.TimeOutIncorrectChoice = 0; % (s)
    TaskParameters.GUI.TimeOutBrokeFixation = 0; % (s)
    TaskParameters.GUI.TimeOutSkippedFeedback = 0; % (s)
    TaskParameters.GUIPanels.General = {'ITI','RewardAmount','ChoiceDeadLine','TimeOutIncorrectChoice','TimeOutBrokeFixation','TimeOutSkippedFeedback'};    
    %% BiasControl
    TaskParameters.GUI.TrialSelection = 3;
    TaskParameters.GUIMeta.TrialSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.TrialSelection.String = {'Flat','Manual','BiasCorrecting','Competitive'};
    TaskParameters.GUIPanels.BiasControl = {'TrialSelection'};
    %% StimDelay
    TaskParameters.GUI.StimDelayAutoincrement = 1;
    TaskParameters.GUIMeta.StimDelayAutoincrement.Style = 'checkbox';
    TaskParameters.GUIMeta.StimDelayAutoincrement.String = 'Auto';
    TaskParameters.GUI.StimDelayMin = 0;
    TaskParameters.GUI.StimDelayMax = 0.6;
    TaskParameters.GUI.StimDelayIncr = 0.01;
    TaskParameters.GUI.StimDelayDecr = 0.01;
    TaskParameters.GUI.StimDelay = TaskParameters.GUI.StimDelayMin;
    TaskParameters.GUIMeta.StimDelay.Style = 'text';
    TaskParameters.GUIPanels.StimDelay = {'StimDelayAutoincrement','StimDelayMin','StimDelayMax','StimDelayIncr','StimDelayDecr','StimDelay'};
    %% FeedbackDelay
    TaskParameters.GUI.FeedbackDelaySelection = 2;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.FeedbackDelayMin = 0;
    TaskParameters.GUI.FeedbackDelayMax = 1;
    TaskParameters.GUI.FeedbackDelayIncr = 0.01;
    TaskParameters.GUI.FeedbackDelayDecr = 0.01;
    TaskParameters.GUI.FeedbackDelayTau = 0.05;
    TaskParameters.GUI.FeedbackDelayGrace = 0;
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau','FeedbackDelayGrace','FeedbackDelay'};
    %% OdorParams
    TaskParameters.GUI.OdorA_bank = 3;
    TaskParameters.GUI.OdorB_bank = 4;
%     TaskParameters.GUI.OdorSettings = 0;
%     TaskParameters.GUI.OdorTable.OdorFracA = 50+[-1; 1]*round(logspace(log10(6),log10(90),3)/2);
%     TaskParameters.GUI.OdorTable.OdorFracA = sort(TaskParameters.GUI.OdorTable.OdorFracA(:));
    TaskParameters.GUI.OdorTable.OdorFracA = [5, 30, 45, 55, 70, 95]';
    TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorFracA))/numel(TaskParameters.GUI.OdorTable.OdorFracA);
    TaskParameters.GUIMeta.OdorTable.Style = 'table';
    TaskParameters.GUIMeta.OdorTable.String = 'Odor probabilities';
    TaskParameters.GUIMeta.OdorTable.ColumnLabel = {'a = Frac Odor A','P(a)'};
%     TaskParameters.GUIMeta.OdorSettings.Style = 'pushbutton';
%     TaskParameters.GUIMeta.OdorSettings.String = 'Odor settings';
%     TaskParameters.GUIMeta.OdorSettings.Callback = @GUIOdorSettings;
    TaskParameters.GUIPanels.Olfactometer = {'OdorA_bank', 'OdorB_bank'};
    TaskParameters.GUIPanels.Stimuli = {'OdorTable'};
    %% Block structure
    TaskParameters.GUI.BlockTable.BlockNumber = [1, 2, 3, 4]';
    TaskParameters.GUI.BlockTable.BlockLen = ones(4,1)*150;
    TaskParameters.GUI.BlockTable.RewL = [1 randsample([1 .6],2) 1]';
    TaskParameters.GUI.BlockTable.RewR = flipud(TaskParameters.GUI.BlockTable.RewL);
    TaskParameters.GUIMeta.BlockTable.Style = 'table';
    TaskParameters.GUIMeta.BlockTable.String = 'Block structure';
    TaskParameters.GUIMeta.BlockTable.ColumnLabel = {'Block#','Block Length','Rew L', 'Rew R'};
    TaskParameters.GUIPanels.BlockStructure = {'BlockTable'};
    %%
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    %% Tabs
    TaskParameters.GUITabs.General = {'StimDelay','BiasControl','General','FeedbackDelay','BlockStructure'};
    TaskParameters.GUITabs.Odor = {'Olfactometer','Stimuli'};
    
end
BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors

BpodSystem.Data.Custom.BlockNumber = 1;
BpodSystem.Data.Custom.BlockTrial = 1;
BpodSystem.Data.Custom.ChoiceLeft = [];
BpodSystem.Data.Custom.ChoiceCorrect = [];
BpodSystem.Data.Custom.Feedback = false(0);
BpodSystem.Data.Custom.FeedbackTime = [];
BpodSystem.Data.Custom.FixBroke = false(0);
BpodSystem.Data.Custom.FixDur = [];
BpodSystem.Data.Custom.MT = [];
BpodSystem.Data.Custom.OdorFracA = randsample([min(TaskParameters.GUI.OdorTable.OdorFracA) max(TaskParameters.GUI.OdorTable.OdorFracA)],2)';
BpodSystem.Data.Custom.OdorID = 2 - double(BpodSystem.Data.Custom.OdorFracA > 50);
BpodSystem.Data.Custom.OdorPair = ones(1,2);
BpodSystem.Data.Custom.OST = [];
BpodSystem.Data.Custom.Rewarded = false(0);
BpodSystem.Data.Custom.RewardMagnitude = TaskParameters.GUI.RewardAmount*[TaskParameters.GUI.BlockTable.RewL(1), TaskParameters.GUI.BlockTable.RewR(1)];
BpodSystem.Data.Custom.TrialNumber = [];

%% Olfactometer Madness

if ~BpodSystem.EmulatorMode
    BpodSystem.Data.Custom.OlfIp = FindOlfactometer;
    if isempty(BpodSystem.Data.Custom.OlfIp)
        error('Bpod:Olf2AFC:OlfComFail','Failed to connect to olfactometer')
    end
    OdorA_flow = BpodSystem.Data.Custom.OdorFracA(1);
    OdorB_flow = 100 - OdorA_flow;
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorA_bank, OdorA_flow)
    SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorB_bank, OdorB_flow)
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
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position', [3*.075+2*.12 .6 .12 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleOST = axes('Position', [4*.075+3*.12 .6 .12 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position', [5*.075+4*.12 .6 .12 .3]);
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix(iTrial);
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
    
    updateCustomDataFields(iTrial);
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    iTrial = iTrial + 1;
end
end