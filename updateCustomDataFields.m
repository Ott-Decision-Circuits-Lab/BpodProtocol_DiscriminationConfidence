function updateCustomDataFields(TaskParameters)
global BpodSystem
%% OutcomeRecord
% Searches for state names and not number, so won't be affected by
% modifications in state matrix
ndxOutcome = find(strcmp('rewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('rewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('unrewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}) |...
    strcmp('broke_fixation',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end})); % States of interest
if any(ismember(ndxOutcome,BpodSystem.Data.RawData.OriginalStateData{end}))
    BpodSystem.Data.Custom.OutcomeRecord(end) = ndxOutcome(ismember(ndxOutcome,BpodSystem.Data.RawData.OriginalStateData{end}));
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
    if any(strcmp('skipped_feedback',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.RawData.OriginalStateData{end})))
        BpodSystem.Data.Custom.TrialValid(end) = false;
        BpodSystem.Data.Custom.Feedback(end) = false;
        BpodSystem.Data.Custom.FeedbackTime(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.(BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}{BpodSystem.Data.Custom.OutcomeRecord(end)}));
    end
end
BpodSystem.Data.Custom.GotFeedback = 1;
BpodSystem.Data.Custom.OutcomeRecord(end+1) = nan;
BpodSystem.Data.Custom.ChoiceLeft(end+1) = NaN;
BpodSystem.Data.Custom.Rewarded(end+1) = NaN;
BpodSystem.Data.Custom.BrokeFix(end+1) = false;
BpodSystem.Data.Custom.BrokeFixTime(end+1) = NaN;
BpodSystem.Data.Custom.TrialValid(end+1) = true;
BpodSystem.Data.Custom.Feedback(end+1) = true;
BpodSystem.Data.Custom.FeedbackTime(end+1) = NaN;

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