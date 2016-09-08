function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

%% Standard values
BpodSystem.Data.Custom.ChoiceLeft(iTrial) = NaN;
BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = NaN;
BpodSystem.Data.Custom.Feedback(iTrial) = true;
BpodSystem.Data.Custom.FeedbackTime(iTrial) = NaN;
BpodSystem.Data.Custom.FixBroke(iTrial) = false;
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
if any(strcmp('stimulus_delivery',statesThisTrial))
    BpodSystem.Data.Custom.ST(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery);
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
BpodSystem.Data.Custom.AuditoryTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.PercentAuditory;
if BpodSystem.Data.Custom.AuditoryTrial(iTrial+1) 
    BpodSystem.Data.Custom.AuditoryOmega(iTrial+1) = betarnd(TaskParameters.GUI.AuditoryAlpha,TaskParameters.GUI.AuditoryAlpha,1,1);
    BpodSystem.Data.Custom.LeftClickRate(iTrial+1) = round(BpodSystem.Data.Custom.AuditoryOmega(iTrial+1)*TaskParameters.GUI.SumRates);
    BpodSystem.Data.Custom.RightClickRate(iTrial+1) = round((1-BpodSystem.Data.Custom.AuditoryOmega(iTrial+1))*TaskParameters.GUI.SumRates);
    BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(iTrial+1), TaskParameters.GUI.AuditoryStimulusTime);
    BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(iTrial+1), TaskParameters.GUI.AuditoryStimulusTime);
    %correct left/right click train
    if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+1})
        BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}(1),BpodSystem.Data.Custom.RightClickTrain{iTrial+1}(1));
        BpodSystem.Data.Custom.RightClickTrain{iTrial+1}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}(1),BpodSystem.Data.Custom.RightClickTrain{iTrial+1}(1));
    elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+1})
        BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}(1) = BpodSystem.Data.Custom.RightClickTrain{iTrial+1}(1);
    elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+1})
        BpodSystem.Data.Custom.RightClickTrain{iTrial+1}(1) = BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}(1);
    else
        BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
        BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
    end
    if length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) > length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1})
        BpodSystem.Data.Custom.MoreLeftClicks(iTrial+1) = 1;
    elseif length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) < length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1})
        BpodSystem.Data.Custom.MoreLeftClicks(iTrial+1) = 0;
    else
        BpodSystem.Data.Custom.MoreLeftClicks(iTrial+1) = NaN;
    end
else
    BpodSystem.Data.Custom.AuditoryOmega(iTrial+1) = NaN;
    BpodSystem.Data.Custom.LeftClickRate(iTrial+1) = NaN;
    BpodSystem.Data.Custom.RightClickRate(iTrial+1) = NaN;
    BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = [];
    BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = [];
end

BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;

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
if TaskParameters.GUI.StimDelayAutoincrement
    if BpodSystem.Data.Custom.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = max(TaskParameters.GUI.StimDelayMin,...
            BpodSystem.Data.Custom.StimDelay(iTrial)-TaskParameters.GUI.StimDelayDecr);
    else
        TaskParameters.GUI.StimDelay = min(TaskParameters.GUI.StimDelayMax,...
            BpodSystem.Data.Custom.StimDelay(iTrial)+TaskParameters.GUI.StimDelayIncr);
    end
else
    if ~BpodSystem.Data.Custom.FixBroke(iTrial)
        TaskParameters.GUI.StimDelay = random('unif',TaskParameters.GUI.StimDelayMin,TaskParameters.GUI.StimDelayMax);
    else
        TaskParameters.GUI.StimDelay = BpodSystem.Data.Custom.StimDelay(iTrial);
    end
end

switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr'
        if ~BpodSystem.Data.Custom.Feedback(iTrial)
            TaskParameters.GUI.FeedbackDelay = max(TaskParameters.GUI.FeedbackDelayMin,...
                BpodSystem.Data.Custom.FeedbackDelay(iTrial)-TaskParameters.GUI.FeedbackDelayDecr);
        else
            TaskParameters.GUI.FeedbackDelay = min(TaskParameters.GUI.FeedbackDelayMax,...
                BpodSystem.Data.Custom.FeedbackDelay(iTrial)+TaskParameters.GUI.FeedbackDelayIncr);
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
if iTrial > numel(BpodSystem.Data.Custom.OdorFracA) - 5
    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Flat'
            TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorProb));
        case 'Manual'
            
        case 'Competitive'
            ndxValid = ~isnan(BpodSystem.Data.Custom.ChoiceLeft);
            for iStim = reshape(TaskParameters.GUI.OdorTable.OdorFracA,1,[])
                ndxOdor = BpodSystem.Data.Custom.OdorFracA(1:iTrial) == iStim;
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
    newFracA = randsample(TaskParameters.GUI.OdorTable.OdorFracA,5,1,TaskParameters.GUI.OdorTable.OdorProb);
    newOdorID =  2 - double(newFracA > 50);
    if any(abs(newFracA-50)<(10*eps))
        ndxZeroInf = abs(newFracA-50)<(10*eps);
        newOdorID(ndxZeroInf) = randsample(2,sum(ndxZeroInf),1);
    end
    newOdorPair = ones(1,5);
    BpodSystem.Data.Custom.OdorFracA = [BpodSystem.Data.Custom.OdorFracA; newFracA];
    BpodSystem.Data.Custom.OdorID = [BpodSystem.Data.Custom.OdorID; newOdorID];
    BpodSystem.Data.Custom.OdorPair = [BpodSystem.Data.Custom.OdorPair, newOdorPair];
end

if BpodSystem.Data.Custom.AuditoryTrial(iTrial+1)
    BpodSystem.Data.Custom.DV(iTrial+1) = (length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) - length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))./(length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}) + length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}));
else
    BpodSystem.Data.Custom.DV(iTrial+1) = (BpodSystem.Data.Custom.OdorFracA(iTrial+1)-50)/100;
end

end
