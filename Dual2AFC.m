function Dual2AFC
% 2-AFC olfactory and auditory discrimination task implented for Bpod fork https://github.com/KepecsLab/bpod
% This project is available on https://github.com/KepecsLab/BpodProtocols_Olf2AFC/

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
    TaskParameters.GUI.TimeOutEarlyWithdrawal = 0; % (s)
    TaskParameters.GUI.TimeOutSkippedFeedback = 0; % (s)
    TaskParameters.GUI.PercentAuditory = 1;
    TaskParameters.GUI.StartEasyTrials = 0;
    TaskParameters.GUI.Percent50Fifty = 0;
    TaskParameters.GUI.PercentCatch = 0;
    TaskParameters.GUI.CatchError = false;
    TaskParameters.GUIMeta.CatchError.Style = 'checkbox';
    TaskParameters.GUI.Ports_LMR = 123;
    TaskParameters.GUIPanels.General = {'ITI','RewardAmount','ChoiceDeadLine','TimeOutIncorrectChoice','TimeOutBrokeFixation','TimeOutEarlyWithdrawal','TimeOutSkippedFeedback','PercentAuditory','StartEasyTrials','Percent50Fifty','PercentCatch','CatchError','Ports_LMR'};    
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
    TaskParameters.GUI.OdorStimulusTimeMin = 0;
%     TaskParameters.GUIMeta.OdorSettings.Style = 'pushbutton';
%     TaskParameters.GUIMeta.OdorSettings.String = 'Odor settings';
%     TaskParameters.GUIMeta.OdorSettings.Callback = @GUIOdorSettings;
    TaskParameters.GUIPanels.Olfactometer = {'OdorA_bank', 'OdorB_bank'};
    TaskParameters.GUIPanels.OlfStimuli = {'OdorTable','OdorStimulusTimeMin'};
    %% Auditory Params
    TaskParameters.GUI.AuditoryAlpha = 1;
    TaskParameters.GUI.LeftBiasAud = 0.5;
    TaskParameters.GUIMeta.LeftBiasAud.Style = 'text';
    TaskParameters.GUI.SumRates = 100;
    TaskParameters.GUI.AuditoryStimulusTime = 3;
    %min auditory stimulus
    TaskParameters.GUI.MinSampleAudMin = 0.05;
    TaskParameters.GUI.MinSampleAudMax = 0.5;
    TaskParameters.GUI.MinSampleAudAutoincrement = true;
    TaskParameters.GUIMeta.MinSampleAudAutoincrement.Style = 'checkbox';
    TaskParameters.GUI.MinSampleAudIncr = 0.05;
    TaskParameters.GUI.MinSampleAudDecr = 0.02;
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleAudMin;
    TaskParameters.GUIMeta.MinSampleAud.Style = 'text';
    TaskParameters.GUI.JackpotAuditory = true;
    TaskParameters.GUIMeta.JackpotAuditory.Style = 'checkbox';
    TaskParameters.GUI.JackpotAuditoryTime = 2;
    TaskParameters.GUIMeta.JackpotAuditoryTime.Style = 'text';
    TaskParameters.GUIPanels.AudGeneral = {'AuditoryAlpha','LeftBiasAud','SumRates','AuditoryStimulusTime'};
    TaskParameters.GUIPanels.AudMinSample = {'MinSampleAudMin','MinSampleAudMax','MinSampleAudAutoincrement','MinSampleAudIncr','MinSampleAudDecr','MinSampleAud'};
    TaskParameters.GUIPanels.AudJackpot = {'JackpotAuditory','JackpotAuditoryTime'};
    %% Block structure
    TaskParameters.GUI.BlockTable.BlockNumber = [1, 2, 3, 4]';
    TaskParameters.GUI.BlockTable.BlockLen = ones(4,1)*150;
    TaskParameters.GUI.BlockTable.RewL = [1 randsample([1 .6],2) 1]';
    TaskParameters.GUI.BlockTable.RewR = flipud(TaskParameters.GUI.BlockTable.RewL);
    TaskParameters.GUIMeta.BlockTable.Style = 'table';
    TaskParameters.GUIMeta.BlockTable.String = 'Block structure';
    TaskParameters.GUIMeta.BlockTable.ColumnLabel = {'Block#','Block Length','Rew L', 'Rew R'};
    TaskParameters.GUIPanels.BlockStructure = {'BlockTable'};
    %% Plots
    %Show Plots
    TaskParameters.GUI.ShowPsycOlf = 1;
    TaskParameters.GUIMeta.ShowPsycOlf.Style = 'checkbox';
    TaskParameters.GUI.ShowPsycAud = 1;
    TaskParameters.GUIMeta.ShowPsycAud.Style = 'checkbox';
    TaskParameters.GUI.ShowVevaiometric = 1;
    TaskParameters.GUIMeta.ShowVevaiometric.Style = 'checkbox';
    TaskParameters.GUI.ShowTrialRate = 1;
    TaskParameters.GUIMeta.ShowTrialRate.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowFeedback = 1;
    TaskParameters.GUIMeta.ShowFeedback.Style = 'checkbox';
    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycOlf','ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback'};
    %Vevaiometric
    TaskParameters.GUI.VevaiometricMinWT = 2;
    TaskParameters.GUI.VevaiometricNBin = 8;
    TaskParameters.GUI.VevaiometricShowPoints = 1;
    TaskParameters.GUIMeta.VevaiometricShowPoints.Style = 'checkbox';
    TaskParameters.GUIPanels.Vevaiometric = {'VevaiometricMinWT','VevaiometricNBin','VevaiometricShowPoints'};
    %%
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    %% Tabs
    TaskParameters.GUITabs.General = {'StimDelay','BiasControl','General','FeedbackDelay','BlockStructure'};
    TaskParameters.GUITabs.Odor = {'Olfactometer','OlfStimuli'};
    TaskParameters.GUITabs.Auditory = {'AudGeneral','AudMinSample','AudJackpot'};
    TaskParameters.GUITabs.Plots = {'ShowPlots','Vevaiometric'};
    %%Non-GUI Parameters (but saved)
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
    TaskParameters.Figures.ParameterGUI.Position =  [9, 454, 1474, 562];
    
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
BpodSystem.Data.Custom.EarlyWithdrawal = false(0);
BpodSystem.Data.Custom.FixDur = [];
BpodSystem.Data.Custom.MT = [];
BpodSystem.Data.Custom.CatchTrial = false;
BpodSystem.Data.Custom.OdorFracA = randsample([min(TaskParameters.GUI.OdorTable.OdorFracA) max(TaskParameters.GUI.OdorTable.OdorFracA)],2)';
BpodSystem.Data.Custom.OdorID = 2 - double(BpodSystem.Data.Custom.OdorFracA > 50);
BpodSystem.Data.Custom.OdorPair = ones(1,2)*2;
BpodSystem.Data.Custom.ST = [];
BpodSystem.Data.Custom.Rewarded = false(0);
BpodSystem.Data.Custom.RewardMagnitude = TaskParameters.GUI.RewardAmount*[TaskParameters.GUI.BlockTable.RewL(1), TaskParameters.GUI.BlockTable.RewR(1)];
BpodSystem.Data.Custom.TrialNumber = [];
BpodSystem.Data.Custom.AuditoryTrial = rand(1,2) < TaskParameters.GUI.PercentAuditory;
BpodSystem.Data.Custom.OlfactometerStartup = false;

% make auditory stimuli for first trials
for a = 1:2
    if BpodSystem.Data.Custom.AuditoryTrial(a)
        BpodSystem.Data.Custom.AuditoryOmega(a) = betarnd(TaskParameters.GUI.AuditoryAlpha/4,TaskParameters.GUI.AuditoryAlpha/4,1,1);
        BpodSystem.Data.Custom.LeftClickRate(a) = round(BpodSystem.Data.Custom.AuditoryOmega(a)*TaskParameters.GUI.SumRates);
        BpodSystem.Data.Custom.RightClickRate(a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(a))*TaskParameters.GUI.SumRates);
        BpodSystem.Data.Custom.LeftClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
        BpodSystem.Data.Custom.RightClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
        %correct left/right click train
        if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
            BpodSystem.Data.Custom.LeftClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
            BpodSystem.Data.Custom.RightClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
        elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
            BpodSystem.Data.Custom.LeftClickTrain{a}(1) = BpodSystem.Data.Custom.RightClickTrain{a}(1);
        elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{1}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{a})
            BpodSystem.Data.Custom.RightClickTrain{a}(1) = BpodSystem.Data.Custom.LeftClickTrain{a}(1);
        else
            BpodSystem.Data.Custom.LeftClickTrain{a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
            BpodSystem.Data.Custom.RightClickTrain{a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
        end
        if length(BpodSystem.Data.Custom.LeftClickTrain{a}) > length(BpodSystem.Data.Custom.RightClickTrain{a})
            BpodSystem.Data.Custom.MoreLeftClicks(a) = double(1);
        elseif length(BpodSystem.Data.Custom.LeftClickTrain{1}) < length(BpodSystem.Data.Custom.RightClickTrain{a})
            BpodSystem.Data.Custom.MoreLeftClicks(a) = double(0);
        else
            BpodSystem.Data.Custom.MoreLeftClicks(a) = NaN;
        end
    else
        BpodSystem.Data.Custom.AuditoryOmega(a) = NaN;
        BpodSystem.Data.Custom.LeftClickRate(a) = NaN;
        BpodSystem.Data.Custom.RightClickRate(a) = NaN;
        BpodSystem.Data.Custom.LeftClickTrain{a} = [];
        BpodSystem.Data.Custom.RightClickTrain{a} = [];
    end
    
    if BpodSystem.Data.Custom.AuditoryTrial(a)
        BpodSystem.Data.Custom.DV(a) = (length(BpodSystem.Data.Custom.LeftClickTrain{a}) - length(BpodSystem.Data.Custom.RightClickTrain{a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{a}) + length(BpodSystem.Data.Custom.RightClickTrain{a}));
        BpodSystem.Data.Custom.OdorFracA(a) = NaN;
        BpodSystem.Data.Custom.OdorID(a) = NaN;
        BpodSystem.Data.Custom.OdorPair(a) = NaN;
    else
        BpodSystem.Data.Custom.DV(a) = (2*BpodSystem.Data.Custom.OdorFracA(a)-100)/100;
    end
end%for a+1:2

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%server data
BpodSystem.Data.Custom.Rig = getenv('computername');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

%% Configuring PulsePal
load PulsePalParamStimulus.mat
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
if ~BpodSystem.EmulatorMode
    if BpodSystem.Data.Custom.AuditoryTrial(1)
        ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
        SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
        SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
    end
end

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055          .15 .91 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf = axes('Position',    [1*.05          .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;
%BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    InitiateOlfactometer(iTrial);
    
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