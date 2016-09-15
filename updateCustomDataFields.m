function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

%% Standard values
BpodSystem.Data.Custom.ChoiceLeft(iTrial) = NaN;
BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = NaN;
BpodSystem.Data.Custom.Feedback(iTrial) = true;
BpodSystem.Data.Custom.FeedbackTime(iTrial) = NaN;
BpodSystem.Data.Custom.FixBroke(iTrial) = false;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = false;
BpodSystem.Data.Custom.FixDur(iTrial) = NaN;
BpodSystem.Data.Custom.MT(iTrial) = NaN;
BpodSystem.Data.Custom.ST(iTrial) = NaN;
BpodSystem.Data.Custom.Rewarded(iTrial) = false;
BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
if any(strcmp('stay_Cin',statesThisTrial))
    BpodSystem.Data.Custom.FixDur(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin);
end
if any(strcmp('stimulus_delivery_min',statesThisTrial))
    if any(strcmp('stimulus_delivery',statesThisTrial))
        BpodSystem.Data.Custom.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(1,2) - BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,1);
    else
        BpodSystem.Data.Custom.ST(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min);
    end
end
if any(strcmp('wait_Sin',statesThisTrial))
    BpodSystem.Data.Custom.MT(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin);
end
if any(strcmp('rewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin;
    BpodSystem.Data.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strcmp('rewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin;
    BpodSystem.Data.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strcmp('unrewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin;
    BpodSystem.Data.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strcmp('unrewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin;
    BpodSystem.Data.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strcmp('broke_fixation',statesThisTrial))
    BpodSystem.Data.Custom.FixBroke(iTrial) = true;
elseif any(strcmp('early_withdrawal',statesThisTrial))
    BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = true;
end
if any(strcmp('missed_choice',statesThisTrial))
    BpodSystem.Data.Custom.Feedback(iTrial) = false;
end
if any(strcmp('skipped_feedback',statesThisTrial))
    BpodSystem.Data.Custom.Feedback(iTrial) = false;
end
if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
end

%% State-independent fields
BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;
BpodSystem.Data.Custom.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

if BpodSystem.Data.Custom.BlockNumber(iTrial) < max(TaskParameters.GUI.BlockTable.BlockNumber) % Not final block
    if BpodSystem.Data.Custom.BlockTrial(iTrial) >= TaskParameters.GUI.BlockTable.BlockLen(TaskParameters.GUI.BlockTable.BlockNumber...
            ==BpodSystem.Data.Custom.BlockNumber(iTrial)) % Block transition
        BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial) + 1;
        BpodSystem.Data.Custom.BlockTrial(iTrial+1) = 1;
    else
        BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial);
        BpodSystem.Data.Custom.BlockTrial(iTrial+1) = BpodSystem.Data.Custom.BlockTrial(iTrial) + 1;
    end
else % Final block
    BpodSystem.Data.Custom.BlockTrial(iTrial+1) = BpodSystem.Data.Custom.BlockTrial(iTrial) + 1;
    BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial);
end

BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = TaskParameters.GUI.RewardAmount*...
    [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumber==BpodSystem.Data.Custom.BlockNumber(iTrial+1)),...
    TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumber==BpodSystem.Data.Custom.BlockNumber(iTrial+1))];

%% Updating Delays
%stimulus delay
if TaskParameters.GUI.StimDelayAutoincrement
    if BpodSystem.Data.Custom.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = max(TaskParameters.GUI.StimDelayMin,...
            min(TaskParameters.GUI.StimDelayMax,BpodSystem.Data.Custom.StimDelay(iTrial)-TaskParameters.GUI.StimDelayDecr));
    else
        TaskParameters.GUI.StimDelay = min(TaskParameters.GUI.StimDelayMax,...
            max(TaskParameters.GUI.StimDelayMin,BpodSystem.Data.Custom.StimDelay(iTrial)+TaskParameters.GUI.StimDelayIncr));
    end
else
    if ~BpodSystem.Data.Custom.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = random('unif',TaskParameters.GUI.StimDelayMin,TaskParameters.GUI.StimDelayMax);
    else
        TaskParameters.GUI.StimDelay = BpodSystem.Data.Custom.StimDelay(iTrial);
    end
end

%min sampling time
if TaskParameters.GUI.MinSampleAudAutoincrement
    History = 5;
    Crit = 0.8;
    if sum(BpodSystem.Data.Custom.AuditoryTrial)<3
        ConsiderTrials = iTrial;
    else
        if isempty(idxStart)
            ConsiderTrials = 1:iTrial;
        else
            ConsiderTrials = iTrial-idxStart+1:iTrial;
        end
    end
    ConsiderTrials = ConsiderTrials((~isnan(BpodSystem.Data.Custom.ChoiceLeft(ConsiderTrials))...
                    |BpodSystem.Data.Custom.EarlyWithdrawal(ConsiderTrials))&BpodSystem.Data.Custom.AuditoryTrial(ConsiderTrials)); %choice + early withdrawal + auditory trials
    if ~isempty(ConsiderTrials) && BpodSystem.Data.Custom.AuditoryTrial(iTrial)
        if mean(BpodSystem.Data.Custom.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) > Crit
            TaskParameters.GUI.MinSampleAud = min(TaskParameters.GUI.MinSampleAudMax,...
                max(TaskParameters.GUI.MinSampleAudMin,BpodSystem.Data.Custom.MinSampleAud(iTrial) + TaskParameters.GUI.MinSampleAudIncr));
        else
            TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial) - TaskParameters.GUI.MinSampleAudDecr));
        end
    end
else
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleAudMin;
end

%feedback delay
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr'
        if ~BpodSystem.Data.Custom.Feedback(iTrial)
            TaskParameters.GUI.FeedbackDelay = max(TaskParameters.GUI.FeedbackDelayMin,...
                min(TaskParameters.GUI.FeedbackDelayMax,BpodSystem.Data.Custom.FeedbackDelay(iTrial)-TaskParameters.GUI.FeedbackDelayDecr));
        else
            TaskParameters.GUI.FeedbackDelay = min(TaskParameters.GUI.FeedbackDelayMax,...
                max(TaskParameters.GUI.FeedbackDelayMin,BpodSystem.Data.Custom.FeedbackDelay(iTrial)+TaskParameters.GUI.FeedbackDelayIncr));
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

%% Drawing future trials
if iTrial > numel(BpodSystem.Data.Custom.DV) - 5
    
    lastidx = numel(BpodSystem.Data.Custom.DV);
    newAuditoryTrial = rand(1,5) < TaskParameters.GUI.PercentAuditory;
    BpodSystem.Data.Custom.AuditoryTrial = [BpodSystem.Data.Custom.AuditoryTrial,newAuditoryTrial];
    
    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Flat'
            TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorProb));
        case 'Manual'
            
        case 'Competitive'
            ndxValid = ~isnan(BpodSystem.Data.Custom.ChoiceLeft); ndxValid = ndxValid(:);
            for iStim = reshape(TaskParameters.GUI.OdorTable.OdorFracA,1,[])
                ndxOdor = BpodSystem.Data.Custom.OdorFracA(1:iTrial) == iStim; ndxOdor = ndxOdor(:);
                if sum(ndxOdor&ndxValid) >= 8 % P(odor) = fraction of completed but unrewarded trials.
                    TaskParameters.GUI.OdorTable.OdorProb(iStim == TaskParameters.GUI.OdorTable.OdorFracA) = ...
                        sum(BpodSystem.Data.Custom.Rewarded(ndxOdor&ndxValid)==0)/sum(ndxOdor&ndxValid);
                else % If too few trials of this type, P(odor) is arbitrary non-zero.
                    TaskParameters.GUI.OdorTable.OdorProb(iStim == TaskParameters.GUI.OdorTable.OdorFracA) = 0.5;
                end
            end
            if any(TaskParameters.GUI.OdorTable.OdorProb==0)
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorProb==0) = ...
                    min(TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorProb>0))/2;
            end
        case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
            ndxRewd = BpodSystem.Data.Custom.Rewarded(1:iTrial) == 1; ndxRewd = ndxRewd(:);
            oldOdorID = BpodSystem.Data.Custom.OdorID(1:numel(ndxRewd)); oldOdorID = oldOdorID(:);
            if any(ndxRewd) % To prevent division by zero
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA<50) = 1-sum(oldOdorID==2 & ndxRewd)/sum(ndxRewd);
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA>50) = 1-sum(oldOdorID==1 & ndxRewd)/sum(ndxRewd);
            else
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA<50) = .5;
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA>50) = .5;
            end
    end
    if sum(TaskParameters.GUI.OdorTable.OdorProb) == 0
        TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorProb));
    end
    TaskParameters.GUI.OdorTable.OdorProb = TaskParameters.GUI.OdorTable.OdorProb/sum(TaskParameters.GUI.OdorTable.OdorProb);
    
    % make future olfactory trials
    newFracA = randsample(TaskParameters.GUI.OdorTable.OdorFracA,5,1,TaskParameters.GUI.OdorTable.OdorProb);
    newOdorID =  2 - double(newFracA > 50);
    if any(abs(newFracA-50)<(10*eps))
        ndxZeroInf = abs(newFracA-50)<(10*eps);
        newOdorID(ndxZeroInf) = randsample(2,sum(ndxZeroInf),1);
    end
    newOdorPair = ones(1,5);
    newFracA(newAuditoryTrial) = nan(sum(newAuditoryTrial),1);
    newOdorID(newAuditoryTrial) = nan(sum(newAuditoryTrial),1);
    newOdorPair(newAuditoryTrial) = nan(1,sum(newAuditoryTrial));
    BpodSystem.Data.Custom.OdorFracA = [BpodSystem.Data.Custom.OdorFracA; newFracA];
    BpodSystem.Data.Custom.OdorID = [BpodSystem.Data.Custom.OdorID; newOdorID];
    BpodSystem.Data.Custom.OdorPair = [BpodSystem.Data.Custom.OdorPair, newOdorPair];
    
    % make future auditory trials
    for a = 1:5
        if BpodSystem.Data.Custom.AuditoryTrial(lastidx+a)
            BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = betarnd(TaskParameters.GUI.AuditoryAlpha,TaskParameters.GUI.AuditoryAlpha,1,1);
            BpodSystem.Data.Custom.LeftClickRate(lastidx+a) = round(BpodSystem.Data.Custom.AuditoryOmega(lastidx+a).*TaskParameters.GUI.SumRates);
            BpodSystem.Data.Custom.RightClickRate(lastidx+a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(lastidx+a)).*TaskParameters.GUI.SumRates);
            BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
            BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
            %correct left/right click train
            if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1),BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1));
                BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1),BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1));
            elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1) = BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1);
            elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1) = BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1);
            else
                BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
                BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
            end
            if length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) > length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = 1;
            elseif length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) < length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = 0;
            else
                BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = NaN;
            end
        else
            BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = NaN;
            BpodSystem.Data.Custom.LeftClickRate(lastidx+a) = NaN;
            BpodSystem.Data.Custom.RightClickRate(lastidx+a) = NaN;
            BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = [];
            BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = [];
        end%if auditory
    end%for a=1:5
    
    % cross-modality difficulty for plotting
    for a = 1 : 5
        if BpodSystem.Data.Custom.AuditoryTrial(lastidx+a)
            BpodSystem.Data.Custom.DV(lastidx+a) = (length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) - length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) + length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}));
        else
            BpodSystem.Data.Custom.DV(lastidx+a) = (2*BpodSystem.Data.Custom.OdorFracA(lastidx+a)-100)/100;
        end
    end
    
end%if trial > - 5

% send auditory stimuli to PulsePal for next trial
if ~BpodSystem.EmulatorMode
    if BpodSystem.Data.Custom.AuditoryTrial(iTrial+1)
        SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
        SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
    end
end

end
