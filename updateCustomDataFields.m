function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

%% Standard values
BpodSystem.Data.Custom.ChoiceLeft(iTrial) = NaN;
BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = NaN;
BpodSystem.Data.Custom.Feedback(iTrial) = true;
BpodSystem.Data.Custom.FeedbackTimeL(iTrial) = NaN;
BpodSystem.Data.Custom.FeedbackTimeR(iTrial) = NaN;
BpodSystem.Data.Custom.FixBroke(iTrial) = false;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = false;
BpodSystem.Data.Custom.FixDur(iTrial) = NaN;
BpodSystem.Data.Custom.MT(iTrial) = NaN;
BpodSystem.Data.Custom.ST(iTrial) = NaN;
BpodSystem.Data.Custom.ResolutionTime(iTrial) = NaN;
BpodSystem.Data.Custom.Rewarded(iTrial) = false;
BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;
BpodSystem.Data.Custom.InvestmentRatio(iTrial)=NaN;
BpodSystem.Data.Custom.FeedbackTimeTotal(iTrial)=NaN;

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
if any(strcmp('stay_Cin',statesThisTrial))
    try
    BpodSystem.Data.Custom.FixDur(iTrial) = BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin(end)-BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin(1);
    catch
    end
end
if any(strcmp('stimulus_delivery_min',statesThisTrial))
    try
    if any(strcmp('stimulus_delivery',statesThisTrial))
        BpodSystem.Data.Custom.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(1,2) - BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,1);
    else
        BpodSystem.Data.Custom.ST(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min);
    end
    catch
    end
end
if any(strcmp('wait_Sin',statesThisTrial))
    BpodSystem.Data.Custom.MT(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin);
end
FeedbackTimeL=0;
FeedbackTimeR=0;
FeedbackTimeL_unRe=0;
FeedbackTimeR_unRe=0;

if any(strcmp('rewarded_Lin',statesThisTrial))
    %BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    %BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimesL = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin;
    FeedbackTimeL = sum(FeedbackPortTimesL(:,2)-FeedbackPortTimesL(:,1));
    %BpodSystem.Data.Custom.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end)
end
if any(strcmp('rewarded_Rin',statesThisTrial))
    %BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    %BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    FeedbackPortTimesR = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin;
    FeedbackTimeR = sum(FeedbackPortTimesR(:,2)-FeedbackPortTimesR(:,1));
    %BpodSystem.Data.Custom.FeedbackTimeR(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
    %BpodSystem.Data.Custom.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
end
if any(strcmp('unrewarded_Lin',statesThisTrial))
    %BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    %BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimesL = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin;
    FeedbackTimeL_unRe = sum(FeedbackPortTimesL(:,2)-FeedbackPortTimesL(:,1));
    %BpodSystem.Data.Custom.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
end
if any(strcmp('unrewarded_Rin',statesThisTrial))
    %BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    %BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    FeedbackPortTimesR = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin;
    FeedbackTimeR_unRe = sum(FeedbackPortTimesR(:,2)-FeedbackPortTimesR(:,1));
    %BpodSystem.Data.Custom.ResolutionTime(iTrial)  = FeedbackPortTimes(end,end);
end

if any(strcmp('broke_fixation',statesThisTrial)) % if broke fixation, add a trial to the block
    BpodSystem.Data.Custom.FixBroke(iTrial) = true;
    
%     TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) + 1;
%     TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial))+ 1;
elseif any(strcmp('early_withdrawal',statesThisTrial)) %if early withdawal, add a trial to the block
    BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = true;
    
%     TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial))+ 1;
%     TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) + 1;
end


if any(strcmp('water_L',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
elseif any(strcmp('water_R',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
elseif any(strcmp('timeOut_IncorrectChoiceL',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
elseif any(strcmp('timeOut_IncorrectChoiceR',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
end 

BpodSystem.Data.Custom.FeedbackTimeR(iTrial)=FeedbackTimeR+FeedbackTimeR_unRe;
BpodSystem.Data.Custom.FeedbackTimeL(iTrial)=FeedbackTimeL+FeedbackTimeL_unRe;
BpodSystem.Data.Custom.FeedbackTimeTotal(iTrial)=FeedbackTimeR+FeedbackTimeR_unRe+FeedbackTimeL+FeedbackTimeL_unRe;



if any(strcmp('missed_choice',statesThisTrial)) % if missed choice, add a trial to the block
    BpodSystem.Data.Custom.Feedback(iTrial) = false;
    
%      TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
%             ==BpodSystem.Data.Custom.BlockNumberL(iTrial))+ 1;
%     TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) =  TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
%             ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) + 1;
end
if any(strcmp('skipped_feedback',statesThisTrial))
    BpodSystem.Data.Custom.Feedback(iTrial) = false;
end
if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
    if BpodSystem.Data.Custom.ChoiceLeft(iTrial) == 1
        BpodSystem.Data.Custom.InvestmentRatio(iTrial) = (FeedbackTimeL+FeedbackTimeL_unRe)/(FeedbackTimeR+FeedbackTimeR_unRe+FeedbackTimeL+FeedbackTimeL_unRe);
    elseif BpodSystem.Data.Custom.ChoiceLeft(iTrial) == 0
        BpodSystem.Data.Custom.InvestmentRatio(iTrial) = (FeedbackTimeR+FeedbackTimeR_unRe)/(FeedbackTimeR+FeedbackTimeR_unRe+FeedbackTimeL+FeedbackTimeL_unRe);
    end
        
end

%debug --> GUI only updates every other isnan(ChoiceLeft)? Checks for nans
%every other trial and adds to block
if rem(iTrial,2)==0
    addTrials=sum(isnan(BpodSystem.Data.Custom.ChoiceLeft(iTrial-1:iTrial)));
    TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
                        ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) =  (TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
                        ==BpodSystem.Data.Custom.BlockNumberR(iTrial))) + addTrials;
    TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
                        ==BpodSystem.Data.Custom.BlockNumberL(iTrial)) =  (TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
                        ==BpodSystem.Data.Custom.BlockNumberL(iTrial)))+ addTrials;
end

 
    



%% State-independent fields
BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;
BpodSystem.Data.Custom.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

%left block tracking
if BpodSystem.Data.Custom.BlockNumberL(iTrial) < max(TaskParameters.GUI.BlockTable.BlockNumberL) % If not final block

    %if it is the last trial in a block 
    if BpodSystem.Data.Custom.BlockTrialL(iTrial) >= TaskParameters.GUI.BlockTable.BlockLenL(TaskParameters.GUI.BlockTable.BlockNumberL...
            ==BpodSystem.Data.Custom.BlockNumberL(iTrial)) 
       
        BpodSystem.Data.Custom.BlockNumberL(iTrial+1) = BpodSystem.Data.Custom.BlockNumberL(iTrial) + 1; %update block number
        BpodSystem.Data.Custom.BlockTrialL(iTrial+1) = 1; %reset block trial

    else
        BpodSystem.Data.Custom.BlockNumberL(iTrial+1) = BpodSystem.Data.Custom.BlockNumberL(iTrial); %update what block
        BpodSystem.Data.Custom.BlockTrialL(iTrial+1) = BpodSystem.Data.Custom.BlockTrialL(iTrial) + 1; %update trial within block
    end
else % Final block
    
    BpodSystem.Data.Custom.BlockTrialL(iTrial+1) = BpodSystem.Data.Custom.BlockTrialL(iTrial) + 1;
    BpodSystem.Data.Custom.BlockNumberL(iTrial+1) = BpodSystem.Data.Custom.BlockNumberL(iTrial);
end

% right block tracking
if BpodSystem.Data.Custom.BlockNumberR(iTrial) < max(TaskParameters.GUI.BlockTable.BlockNumberR) % Not final block
    

    if BpodSystem.Data.Custom.BlockTrialR(iTrial) >= TaskParameters.GUI.BlockTable.BlockLenR(TaskParameters.GUI.BlockTable.BlockNumberR...
            ==BpodSystem.Data.Custom.BlockNumberR(iTrial)) % Block transition
        BpodSystem.Data.Custom.BlockNumberR(iTrial+1) = BpodSystem.Data.Custom.BlockNumberR(iTrial) + 1;
        BpodSystem.Data.Custom.BlockTrialR(iTrial+1) = 1;
    else
        BpodSystem.Data.Custom.BlockNumberR(iTrial+1) = BpodSystem.Data.Custom.BlockNumberR(iTrial);
        BpodSystem.Data.Custom.BlockTrialR(iTrial+1) = BpodSystem.Data.Custom.BlockTrialR(iTrial) + 1;
    end
else % Final block
    
    BpodSystem.Data.Custom.BlockTrialR(iTrial+1) = BpodSystem.Data.Custom.BlockTrialR(iTrial) + 1;
    BpodSystem.Data.Custom.BlockNumberR(iTrial+1) = BpodSystem.Data.Custom.BlockNumberR(iTrial);
end

%house keeping, tracks base reward
BpodSystem.Data.Custom.RewardBase(iTrial+1,:)=round(TaskParameters.GUI.RewardAmount*...
        [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1)),...
        TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumberR==BpodSystem.Data.Custom.BlockNumberR(iTrial+1))]);

BpodSystem.Data.Custom.NoiseHiLeft(iTrial+1,:)= max(TaskParameters.GUI.BlockTable.NoiseL) == TaskParameters.GUI.BlockTable.NoiseL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1));


if TaskParameters.GUI.RewardDrift == false
    BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = TaskParameters.GUI.RewardAmount*...
        [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1)),...
        TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumberR==BpodSystem.Data.Custom.BlockNumberR(iTrial+1))];
    
elseif TaskParameters.GUI.RewardDrift == true
    RewardMagnitude=round(TaskParameters.GUI.RewardAmount*...
        [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1)),...
        TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumberR==BpodSystem.Data.Custom.BlockNumberR(iTrial+1))]);
    
    RewardMag=round(RewardMagnitude+ [normrnd(0, TaskParameters.GUI.BlockTable.NoiseL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1))), normrnd(0,TaskParameters.GUI.BlockTable.NoiseR(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1)))]);
    
    try
        while (sum (RewardMag < TaskParameters.GUI.RewardMin) > 0) || (sum(RewardMag > TaskParameters.GUI.RewardMax ) > 0)
             RewardMag=round(RewardMagnitude+ [normrnd(0, TaskParameters.GUI.BlockTable.NoiseL(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1))), normrnd(0,TaskParameters.GUI.BlockTable.NoiseR(TaskParameters.GUI.BlockTable.BlockNumberL==BpodSystem.Data.Custom.BlockNumberL(iTrial+1)))]);
        end
        catch
            RewardMag = RewardMagnitude;
            disp('failed re-roll for reward size. no noise in reward')
    end
    
    BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = RewardMag;
    BpodSystem.Data.Custom.RichLeft(iTrial+1)=RewardMag(1) > RewardMag(2);
    BpodSystem.Data.Custom.RichRight(iTrial+1) = RewardMag(2) > RewardMag(1);
    BpodSystem.Data.Custom.RichEqual(iTrial+1)= RewardMag(1) == RewardMag(2); 
    
%     if sum(RewardMag < TaskParameters.GUI.RewardMin)>0 || sum(RewardMag > TaskParameters.GUI.RewardMax)>0
%         RewardMag(RewardMag<TaskParameters.GUI.RewardMin) = TaskParameters.GUI.RewardMin;
%         RewardMag(RewardMag>TaskParameters.GUI.RewardMax) = TaskParameters.GUI.RewardMax;
%     end
    clearvars RewardMagnitude RewardMag
end

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

%min sampling time auditory
if TaskParameters.GUI.MinSampleAudAutoincrement
    History = 50;
    Crit = 0.8;
    if sum(BpodSystem.Data.Custom.AuditoryTrial)<10
        ConsiderTrials = iTrial;
    else
        idxStart = find(cumsum(BpodSystem.Data.Custom.AuditoryTrial(iTrial:-1:1))>=History,1,'first');
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
            if ~BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = min(TaskParameters.GUI.MinSampleAudMax,...
                    max(TaskParameters.GUI.MinSampleAudMin,BpodSystem.Data.Custom.MinSampleAud(iTrial) + TaskParameters.GUI.MinSampleAudIncr));
            end
        elseif mean(BpodSystem.Data.Custom.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) < Crit/2
            if BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                    min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial) - TaskParameters.GUI.MinSampleAudDecr));
            end
        else
            TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial)));
        end
    else
        TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
            min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial)));
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

%determine if catch trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.PercentCatch;
else
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
end

%determine if laser trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.LaserTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.LaserTrials;
else
    BpodSystem.Data.Custom.LaserTrial(iTrial+1) = false;
end

%determine laser stimulus delay
BpodSystem.Data.Custom.LaserTrialTrainStart(iTrial+1) = NaN;
if BpodSystem.Data.Custom.LaserTrial(iTrial+1)
    if TaskParameters.GUI.LaserTrainRandStart
        BpodSystem.Data.Custom.LaserTrialTrainStart(iTrial+1) = rand(1,1)*(TaskParameters.GUI.LaserTrainStartMax_s-TaskParameters.GUI.LaserTrainStartMin_s) + TaskParameters.GUI.LaserTrainStartMin_s;
        BpodSystem.Data.Custom.LaserTrialTrainStart(iTrial+1)=round(BpodSystem.Data.Custom.LaserTrialTrainStart(iTrial+1)*10000)/10000;
    else
        BpodSystem.Data.Custom.LaserTrialTrainStart(iTrial+1) = TaskParameters.GUI.LaserTrainStartMin_s;
    end
end

%create future trials
if iTrial > numel(BpodSystem.Data.Custom.DV) - 5
    
    lastidx = numel(BpodSystem.Data.Custom.DV);
    newAuditoryTrial = rand(1,5) < TaskParameters.GUI.PercentAuditory;
    BpodSystem.Data.Custom.AuditoryTrial = [BpodSystem.Data.Custom.AuditoryTrial,newAuditoryTrial];
    if TaskParameters.GUI.AuditoryStimulusType == 1 %click stimuli
        BpodSystem.Data.Custom.ClickTask = [BpodSystem.Data.Custom.ClickTask ,true(1,5)];
    elseif TaskParameters.GUI.AuditoryStimulusType == 2 %freq stimuli
        BpodSystem.Data.Custom.ClickTask = [BpodSystem.Data.Custom.ClickTask ,false(1,5)];
    end
    
    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Flat'
            TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorProb));
            TaskParameters.GUI.LeftBiasAud = 0.5;
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
            TaskParameters.GUI.LeftBiasAud = 0.5;%auditory not implemented
        case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
            %olfactory
            ndxRewd = BpodSystem.Data.Custom.Rewarded(1:iTrial) == 1 & ~BpodSystem.Data.Custom.AuditoryTrial(1:iTrial); ndxRewd = ndxRewd(:);
            oldOdorID = BpodSystem.Data.Custom.OdorID(1:numel(ndxRewd)); oldOdorID = oldOdorID(:);
            if any(ndxRewd) % To prevent division by zero
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA<50) = 1-sum(oldOdorID==2 & ndxRewd)/sum(ndxRewd);
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA>50) = 1-sum(oldOdorID==1 & ndxRewd)/sum(ndxRewd);
            else
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA<50) = .5;
                TaskParameters.GUI.OdorTable.OdorProb(TaskParameters.GUI.OdorTable.OdorFracA>50) = .5;
            end
            %auditory
            ndxRewd = BpodSystem.Data.Custom.Rewarded(1:iTrial) == 1 & BpodSystem.Data.Custom.AuditoryTrial(1:iTrial);
            if sum(ndxRewd)>10
                TaskParameters.GUI.LeftBiasAud = sum(BpodSystem.Data.Custom.LeftRewarded(1:iTrial)==1&ndxRewd)/sum(ndxRewd);
            else
                TaskParameters.GUI.LeftBiasAud = 0.5;
            end
            if sum(ndxRewd)>10
                TaskParameters.GUI.Aud_Levels.AudPFrac(TaskParameters.GUI.Aud_Levels.AudFracHigh<50) = TaskParameters.GUI.LeftBiasAud;
                TaskParameters.GUI.Aud_Levels.AudPFrac(TaskParameters.GUI.Aud_Levels.AudFracHigh>50) = 1 - TaskParameters.GUI.LeftBiasAud;
            end
    end
    if sum(TaskParameters.GUI.OdorTable.OdorProb) == 0
        TaskParameters.GUI.OdorTable.OdorProb = ones(size(TaskParameters.GUI.OdorTable.OdorProb));
    end
    TaskParameters.GUI.OdorTable.OdorProb = TaskParameters.GUI.OdorTable.OdorProb/sum(TaskParameters.GUI.OdorTable.OdorProb);
    
    % make future olfactory trials
    if iTrial > TaskParameters.GUI.StartEasyTrials
        newFracA = randsample(TaskParameters.GUI.OdorTable.OdorFracA,5,1,TaskParameters.GUI.OdorTable.OdorProb);
        %include Fifty50 Trials
        NewFifty50 = rand(5,1) < TaskParameters.GUI.Percent50Fifty;
        newFracA(NewFifty50) = 50;
    else
        EasyProb = zeros(numel(TaskParameters.GUI.OdorTable.OdorProb),1);
        EasyProb(1) = 0.5; EasyProb(end)=0.5;
        newFracA = randsample(TaskParameters.GUI.OdorTable.OdorFracA,5,1,EasyProb);
    end
    
    newOdorID =  2 - double(newFracA > 50);
    if any(abs(newFracA-50)<(10*eps))
        ndxZeroInf = abs(newFracA-50)<(10*eps);
        newOdorID(ndxZeroInf) = randsample(2,sum(ndxZeroInf),1);
    end
    newOdorPair = ones(1,5)*2;
    newFracA(newAuditoryTrial) = nan(sum(newAuditoryTrial),1);
    newOdorID(newAuditoryTrial) = nan(sum(newAuditoryTrial),1);
    newOdorPair(newAuditoryTrial) = nan(1,sum(newAuditoryTrial));
    BpodSystem.Data.Custom.OdorFracA = [BpodSystem.Data.Custom.OdorFracA; newFracA];
    BpodSystem.Data.Custom.OdorID = [BpodSystem.Data.Custom.OdorID; newOdorID];
    BpodSystem.Data.Custom.OdorPair = [BpodSystem.Data.Custom.OdorPair, newOdorPair];
    
    % make future auditory trials
    %bias correcting
    switch TaskParameters.GUI.AuditoryStimulusType
        case 1 %click stimuli
            
            if iTrial > TaskParameters.GUI.StartEasyTrials
                AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha;
            else
                AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha/4;
            end
            BetaRatio = (1 - min(0.9,max(0.1,TaskParameters.GUI.LeftBiasAud))) / min(0.9,max(0.1,TaskParameters.GUI.LeftBiasAud)); %use a = ratio*b to yield E[X] = LeftBiasAud using Beta(a,b) pdf
            %cut off between 0.1-0.9 to prevent extreme values (only one side) and div by zero
            BetaA =  (2*AuditoryAlpha*BetaRatio) / (1+BetaRatio); %make a,b symmetric around AuditoryAlpha to make B symmetric
            BetaB = (AuditoryAlpha-BetaA) + AuditoryAlpha;
            for a = 1:5
                if BpodSystem.Data.Custom.AuditoryTrial(lastidx+a)
                    if rand(1,1) < TaskParameters.GUI.Percent50Fifty && iTrial > TaskParameters.GUI.StartEasyTrials
                        BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = 0.5;
                        
                    elseif TaskParameters.GUI.AuditoryDiscretize == true && iTrial > TaskParameters.GUI.StartEasyTrials
                        BpodSystem.Data.Custom.AuditoryOmega(lastidx+a)=randsample([0.05 0.3 0.45 0.55 0.7 0.95],1); 
                        
                    else
                        BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = betarnd(max(0,BetaA),max(0,BetaB),1,1); %prevent negative parameters
                    end
                    BpodSystem.Data.Custom.LeftClickRate(lastidx+a) = round(BpodSystem.Data.Custom.AuditoryOmega(lastidx+a).*TaskParameters.GUI.SumRates);
                    BpodSystem.Data.Custom.RightClickRate(lastidx+a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(lastidx+a)).*TaskParameters.GUI.SumRates);
                    stim_ok=false;
                    while ~stim_ok %make sure 50/50 are true 50/50 trials
                        BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
                        BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
                        if BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) == 0.5
                            if length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) == length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                                stim_ok=true;
                            end
                        else
                            stim_ok=true;
                        end
                    end
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
                        BpodSystem.Data.Custom.LeftRewarded(lastidx+a) = 1;
                    elseif length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) < length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
                        BpodSystem.Data.Custom.LeftRewarded(lastidx+a) = 0;
                    else
                        BpodSystem.Data.Custom.LeftRewarded(lastidx+a) = rand<0.5;
                    end
                else
                    BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = NaN;
                    BpodSystem.Data.Custom.LeftClickRate(lastidx+a) = NaN;
                    BpodSystem.Data.Custom.RightClickRate(lastidx+a) = NaN;
                    BpodSystem.Data.Custom.LeftRewarded(lastidx+a) = NaN;
                    BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = [];
                    BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = [];
                end%if auditory
            end%for a=1:5
            
        case 2 %freq stimuli
            
            StimulusSettings.SamplingRate = TaskParameters.GUI.Aud_SamplingRate; % Sound card sampling rate;
            StimulusSettings.ramp = TaskParameters.GUI.Aud_Ramp;
            StimulusSettings.nFreq = TaskParameters.GUI.Aud_nFreq; % Number of different frequencies to sample from
            StimulusSettings.ToneOverlap = TaskParameters.GUI.Aud_ToneOverlap;
            StimulusSettings.ToneDuration = TaskParameters.GUI.Aud_ToneDuration;
            StimulusSettings.Noevidence=TaskParameters.GUI.Aud_NoEvidence;
            StimulusSettings.minFreq = TaskParameters.GUI.Aud_minFreq ;
            StimulusSettings.maxFreq = TaskParameters.GUI.Aud_maxFreq ;
            StimulusSettings.UseMiddleOctave=TaskParameters.GUI.Aud_UseMiddleOctave;
            StimulusSettings.Volume=TaskParameters.GUI.Aud_Volume;
            StimulusSettings.nTones = floor((TaskParameters.GUI.AuditoryStimulusTime-StimulusSettings.ToneDuration*StimulusSettings.ToneOverlap)/(StimulusSettings.ToneDuration*(1-StimulusSettings.ToneOverlap))); %number of tones
            if iTrial > TaskParameters.GUI.StartEasyTrials
                newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,5,1,TaskParameters.GUI.Aud_Levels.AudPFrac)';
                %include Fifty50 Trials
                NewFifty50 = rand(5,1) < TaskParameters.GUI.Percent50Fifty;
                newFracHigh(NewFifty50) = 50;
            else
                EasyProb = zeros(numel(TaskParameters.GUI.Aud_Levels.AudPFrac),1);
                EasyProb(1) = 0.5; EasyProb(end)=0.5;
                newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,5,1,EasyProb)';
            end
            
            newCloud = cell(1,5);
            newSound = cell(1,5);
            for a = 1:5
                if BpodSystem.Data.Custom.AuditoryTrial(lastidx+a)
                    [Sound, Cloud, ~] = GenerateToneCloudDual(newFracHigh(a)/100, StimulusSettings);
                    newCloud{a} = Cloud;
                    newSound{a} = Sound;
                end
            end
            
            LeftRewarded = newFracHigh>50;
            LeftRewarded (newFracHigh==050) = rand<0.5;
            newFracHigh(~newAuditoryTrial) = nan(sum(~newAuditoryTrial),1);
            BpodSystem.Data.Custom.AudFracHigh = [BpodSystem.Data.Custom.AudFracHigh, newFracHigh];
            BpodSystem.Data.Custom.AudCloud = [BpodSystem.Data.Custom.AudCloud, newCloud];
            BpodSystem.Data.Custom.AudSound = [BpodSystem.Data.Custom.AudSound, newSound];
            BpodSystem.Data.Custom.LeftRewarded = [BpodSystem.Data.Custom.LeftRewarded, LeftRewarded];
            
    end %switch/case auditory stimulus type
    
    % cross-modality difficulty for plotting
    for a = 1 : 5
        if BpodSystem.Data.Custom.AuditoryTrial(lastidx+a)
            if BpodSystem.Data.Custom.ClickTask(lastidx+a)
                BpodSystem.Data.Custom.DV(lastidx+a) = (length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) - length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) + length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}));
            else
                BpodSystem.Data.Custom.DV(lastidx+a) = (2*BpodSystem.Data.Custom.AudFracHigh(lastidx+a)-100)/100;
            end
        else
            BpodSystem.Data.Custom.DV(lastidx+a) = (2*BpodSystem.Data.Custom.OdorFracA(lastidx+a)-100)/100;
        end
    end
    
end%if trial > - 5


%%update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;

%update laser params
if ~TaskParameters.GUI.LaserSoftCode
    %laser via programm pulsepal (without custom train via softvode)
    BpodSystem.Data.Custom.PulsePalParamStimulus=configurePulsePalLaser(BpodSystem.Data.Custom.PulsePalParamStimulus);
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
end

% send auditory stimuli to PulsePal for next trial
if BpodSystem.Data.Custom.AuditoryTrial(iTrial+1)
    if ~BpodSystem.EmulatorMode
        if BpodSystem.Data.Custom.ClickTask(iTrial+1)
            SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
            SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
        else
            PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.AudSound{iTrial+1});
            BpodSystem.Data.Custom.AudSound{iTrial+1} = {};
        end
    end
end

%send bpod status to server
try
%     script = 'receivebpodstatus.php';
%     %create a common "outcome" vector
%     outcome = BpodSystem.Data.Custom.ChoiceCorrect(1:iTrial); %1=correct, 0=wrong
%     outcome(BpodSystem.Data.Custom.EarlyWithdrawal(1:iTrial))=2; %early withdrawal=2
%     outcome(BpodSystem.Data.Custom.FixBroke(1:iTrial))=3;%jackpot=3
%     SendTrialStatusToServer(script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
catch
end

end
