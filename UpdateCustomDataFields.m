function UpdateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

%% Standard values
% BpodSystem.Data.Custom.ChoiceLeft(iTrial) = NaN;
% BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = NaN;
% BpodSystem.Data.Custom.Feedback(iTrial) = true;
% BpodSystem.Data.Custom.FeedbackTime(iTrial) = NaN;
% BpodSystem.Data.Custom.FixBroke(iTrial) = false;
% BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = false;
% BpodSystem.Data.Custom.FixDur(iTrial) = NaN;
% BpodSystem.Data.Custom.MT(iTrial) = NaN;
% BpodSystem.Data.Custom.ST(iTrial) = NaN;
% BpodSystem.Data.Custom.ResolutionTime(iTrial) = NaN;
% BpodSystem.Data.Custom.Rewarded(iTrial) = false;
% BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
if any(strcmp('stay_Cin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.FixDur(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin);
end
if any(strcmp('stimulus_delivery_min',statesThisTrial))
    if any(strcmp('stimulus_delivery',statesThisTrial))
        BpodSystem.Data.Custom.TrialData.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(1,2) - BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,1);
    else
        BpodSystem.Data.Custom.TrialData.ST(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min);
    end
end
if any(strcmp('wait_Sin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.MT(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin);
end
if any(strcmp('rewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.TrialData.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin;
    BpodSystem.Data.Custom.TrialData.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
    BpodSystem.Data.Custom.TrialData.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
elseif any(strcmp('rewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.TrialData.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin;
    BpodSystem.Data.Custom.TrialData.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
    BpodSystem.Data.Custom.TrialData.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
elseif any(strcmp('unrewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.TrialData.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin;
    BpodSystem.Data.Custom.TrialData.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
    BpodSystem.Data.Custom.TrialData.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
elseif any(strcmp('unrewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.TrialData.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin;
    BpodSystem.Data.Custom.TrialData.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
    BpodSystem.Data.Custom.TrialData.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
elseif any(strcmp('broke_fixation',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.FixBroke(iTrial) = true;
elseif any(strcmp('early_withdrawal',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial) = true;
end
if any(strcmp('missed_choice',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.Feedback(iTrial) = false;
end
if any(strcmp('skipped_feedback',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.Feedback(iTrial) = false;
end
if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.TrialData.Rewarded(iTrial) = true;
end

%% State-independent fields
% BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
% BpodSystem.Data.Custom.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;
% BpodSystem.Data.Custom.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;
% 
% if BpodSystem.Data.Custom.BlockNumber(iTrial) < max(TaskParameters.GUI.BlockTable.BlockNumber) % Not final block
%     if BpodSystem.Data.Custom.BlockTrial(iTrial) >= TaskParameters.GUI.BlockTable.BlockLen(TaskParameters.GUI.BlockTable.BlockNumber...
%             ==BpodSystem.Data.Custom.BlockNumber(iTrial)) % Block transition
%         BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial) + 1;
%         BpodSystem.Data.Custom.BlockTrial(iTrial+1) = 1;
%     else
%         BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial);
%         BpodSystem.Data.Custom.BlockTrial(iTrial+1) = BpodSystem.Data.Custom.BlockTrial(iTrial) + 1;
%     end
% else % Final block
%     BpodSystem.Data.Custom.BlockTrial(iTrial+1) = BpodSystem.Data.Custom.BlockTrial(iTrial) + 1;
%     BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial);
% end
% 
% BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = TaskParameters.GUI.RewardAmount*...
%     [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumber==BpodSystem.Data.Custom.BlockNumber(iTrial+1)),...
%     TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumber==BpodSystem.Data.Custom.BlockNumber(iTrial+1))];
% 
%% Updating Delays
%stimulus delay
if TaskParameters.GUI.StimDelayAutoincrement
    if BpodSystem.Data.Custom.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = max(TaskParameters.GUI.StimDelayMin,...
            min(TaskParameters.GUI.StimDelayMax,BpodSystem.Data.Custom.TrialData.StimDelay(iTrial)-TaskParameters.GUI.StimDelayDecr));
    else
        TaskParameters.GUI.StimDelay = min(TaskParameters.GUI.StimDelayMax,...
            max(TaskParameters.GUI.StimDelayMin,BpodSystem.Data.Custom.TrialData.StimDelay(iTrial)+TaskParameters.GUI.StimDelayIncr));
    end
else
    if ~BpodSystem.Data.Custom.TrialData.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = random('unif',TaskParameters.GUI.StimDelayMin,TaskParameters.GUI.StimDelayMax);
    else
        TaskParameters.GUI.StimDelay = BpodSystem.Data.Custom.TrialData.StimDelay(iTrial);
    end
end

%min sampling time auditory
if TaskParameters.GUI.MinSampleAudAutoincrement
    History = 50;
    Crit = 0.8;
    if sum(BpodSystem.Data.Custom.TrialData.AuditoryTrial)<10
        ConsiderTrials = iTrial;
    else
        idxStart = find(cumsum(BpodSystem.Data.Custom.TrialData.AuditoryTrial(iTrial:-1:1))>=History,1,'first');
        if isempty(idxStart)
            ConsiderTrials = 1:iTrial;
        else
            ConsiderTrials = iTrial-idxStart+1:iTrial;
        end
    end
    ConsiderTrials = ConsiderTrials((~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft(ConsiderTrials))...
        |BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(ConsiderTrials))&BpodSystem.Data.Custom.TrialData.AuditoryTrial(ConsiderTrials)); %choice + early withdrawal + auditory trials
    if ~isempty(ConsiderTrials) && BpodSystem.Data.Custom.TrialData.AuditoryTrial(iTrial)
        if mean(BpodSystem.Data.Custom.TrialData.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) > Crit
            if ~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = min(TaskParameters.GUI.MinSampleAudMax,...
                    max(TaskParameters.GUI.MinSampleAudMin,BpodSystem.Data.Custom.TrialData.MinSampleAud(iTrial) + TaskParameters.GUI.MinSampleAudIncr));
            end
        elseif mean(BpodSystem.Data.Custom.TrialData.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) < Crit/2
            if BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                    min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.TrialData.MinSampleAud(iTrial) - TaskParameters.GUI.MinSampleAudDecr));
            end
        else
            TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.TrialData.MinSampleAud(iTrial)));
        end
    else
        TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
            min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.TrialData.MinSampleAud(iTrial)));
    end
else
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleAudMin;
end

%feedback delay
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr'
        if ~BpodSystem.Data.Custom.TrialData.Feedback(iTrial)
            TaskParameters.GUI.FeedbackDelay = max(TaskParameters.GUI.FeedbackDelayMin,...
                min(TaskParameters.GUI.FeedbackDelayMax,BpodSystem.Data.Custom.TrialData.FeedbackDelay(iTrial)-TaskParameters.GUI.FeedbackDelayDecr));
        else
            TaskParameters.GUI.FeedbackDelay = min(TaskParameters.GUI.FeedbackDelayMax,...
                max(TaskParameters.GUI.FeedbackDelayMin,BpodSystem.Data.Custom.TrialData.FeedbackDelay(iTrial)+TaskParameters.GUI.FeedbackDelayIncr));
        end
    case 'TruncExp'
        TaskParameters.GUI.FeedbackDelay = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin,...
            TaskParameters.GUI.FeedbackDelayMax,TaskParameters.GUI.FeedbackDelayTau);
    case 'Fix'
        %     ATTEMPT TO GRAY OUT FIELDS
        %     if ~strcmp('edit',TaskParameters.GUIMeta.FeedbackDelay.Style)
        %         TaskParameters.GUIMeta.FeedbackDelay.Style = 'edit';
        %     end
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMax;
end

%%update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;


% send auditory stimuli to PulsePal for next trial
% if BpodSystem.Data.Custom.AuditoryTrial(iTrial+1)
%     if ~BpodSystem.EmulatorMode
%         if BpodSystem.Data.Custom.ClickTask(iTrial+1)
%             SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
%             SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
%         else
%             PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.AudSound{iTrial+1});
%             BpodSystem.Data.Custom.AudSound{iTrial+1} = {};
%         end
%     end
% end

%send bpod status to server
% try
%     script = 'receivebpodstatus.php';
%     %create a common "outcome" vector
%     outcome = BpodSystem.Data.Custom.ChoiceCorrect(1:iTrial); %1=correct, 0=wrong
%     outcome(BpodSystem.Data.Custom.EarlyWithdrawal(1:iTrial))=2; %early withdrawal=2
%     outcome(BpodSystem.Data.Custom.FixBroke(1:iTrial))=3;%jackpot=3
%     SendTrialStatusToServer(script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
% catch

end