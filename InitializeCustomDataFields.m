function InitializeCustomDataFields(iTrial)
%{ 
Initializing data (trial type) vectors and first values
%}

global BpodSystem
global TaskParameters

if iTrial == 1
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = NaN;
end

trial_data = BpodSystem.Data.Custom.TrialData;

%% Initializing data (trial type) vectors
trial_data.BlockNumber(iTrial) = 1;
trial_data.BlockTrial(iTrial) = 1;
trial_data.ChoiceLeft(iTrial) = NaN;
trial_data.ChoiceCorrect(iTrial) = NaN;
trial_data.Feedback(iTrial) = true;
trial_data.FeedbackTime(iTrial) = NaN;
trial_data.FixBroke(iTrial) = false;
trial_data.EarlyWithdrawal(iTrial) = false;
trial_data.FixDur(iTrial) = NaN;
trial_data.MT(iTrial) = NaN;
trial_data.CatchTrial(iTrial) = false;
trial_data.OdorFracA(iTrial) = NaN; %randsample([min(TaskParameters.GUI.OdorTable.OdorFracA) max(TaskParameters.GUI.OdorTable.OdorFracA)],2)';
trial_data.OdorID(iTrial) = NaN; %2 - double(trial_data.OdorFracA > 50);
trial_data.OdorPair(iTrial) = NaN; %ones(1,2)*2;
trial_data.ST(iTrial) = NaN;
trial_data.ResolutionTime(iTrial) = NaN;
trial_data.Rewarded(iTrial) = false;
trial_data.RewardMagnitude(:, iTrial) = TaskParameters.GUI.RewardAmount * [TaskParameters.GUI.BlockTable.RewL(1), TaskParameters.GUI.BlockTable.RewR(1)]';
trial_data.TrialNumber(iTrial) = iTrial;
trial_data.LaserTrial(iTrial) = false;
trial_data.LaserTrialTrainStart(iTrial) = NaN;
trial_data.AuditoryTrial(iTrial) = rand(1,1) < TaskParameters.GUI.PercentAuditory;
trial_data.ClickTask(iTrial) = TaskParameters.GUI.AuditoryStimulusType == 1;
trial_data.AuditoryOmega(iTrial) = NaN;
trial_data.LeftClickRate(iTrial) = NaN;
trial_data.RightClickRate(iTrial) = NaN;
% trial_data.LeftRewarded(iTrial) = NaN;
trial_data.LeftClickTrain{iTrial} = [];
trial_data.RightClickTrain{iTrial} = [];
trial_data.AudFracHigh(iTrial) = NaN;
trial_data.AudCloud{iTrial} = [];
trial_data.AudSound{iTrial} = [];
trial_data.DV = NaN;
trial_data.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
trial_data.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;
trial_data.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

BpodSystem.Data.Custom.SessionMeta.OlfactometerStartup = false;
BpodSystem.Data.Custom.SessionMeta.PsychtoolboxStartup = false;

%% State-independent fields
if iTrial > 1
    if trial_data.BlockNumber(iTrial-1) < max(TaskParameters.GUI.BlockTable.BlockNumber) % Not final block
        if trial_data.BlockTrial(iTrial-1) >= TaskParameters.GUI.BlockTable.BlockLen(TaskParameters.GUI.BlockTable.BlockNumber...
                ==trial_data.BlockNumber(iTrial-1)) % Block transition
            trial_data.BlockNumber(iTrial) = trial_data.BlockNumber(iTrial-1) + 1;
            trial_data.BlockTrial(iTrial) = 1;
        else
            trial_data.BlockNumber(iTrial) = trial_data.BlockNumber(iTrial-1);
            trial_data.BlockTrial(iTrial) = trial_data.BlockTrial(iTrial-1) + 1;
        end
    else % Final block
        trial_data.BlockTrial(iTrial) = trial_data.BlockTrial(iTrial-1) + 1;
        trial_data.BlockNumber(iTrial) = trial_data.BlockNumber(iTrial-1);
    end
end

trial_data.RewardMagnitude(:, iTrial) = TaskParameters.GUI.RewardAmount*...
    [TaskParameters.GUI.BlockTable.RewL(TaskParameters.GUI.BlockTable.BlockNumber==trial_data.BlockNumber(iTrial)),...
    TaskParameters.GUI.BlockTable.RewR(TaskParameters.GUI.BlockTable.BlockNumber==trial_data.BlockNumber(iTrial))]';

%% determine if catch trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    trial_data.CatchTrial(iTrial) = rand(1,1) < TaskParameters.GUI.PercentCatch;
else
    trial_data.CatchTrial(iTrial) = false;
end

%% determine if laser trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    trial_data.LaserTrial(iTrial) = rand(1,1) < TaskParameters.GUI.LaserTrials;
else
    trial_data.LaserTrial(iTrial) = false;
end

%determine laser stimulus delay
if trial_data.LaserTrial(iTrial)
    if TaskParameters.GUI.LaserTrainRandStart
        trial_data.LaserTrialTrainStart(iTrial) = rand(1,1)*(TaskParameters.GUI.LaserTrainStartMax_s-TaskParameters.GUI.LaserTrainStartMin_s) + TaskParameters.GUI.LaserTrainStartMin_s;
        trial_data.LaserTrialTrainStart(iTrial) = round(trial_data.LaserTrialTrainStart(iTrial)*10000)/10000;
    else
        trial_data.LaserTrialTrainStart(iTrial) = TaskParameters.GUI.LaserTrainStartMin_s;
    end
end




%% make auditory stimuli for first trials
% function notused
% switch TaskParameters.GUI.AuditoryStimulusType
%     case 1 %click stimuli
%         for a = 1:5
%             if BpodSystem.Data.Custom.AuditoryTrial(iTrial+a)              
%                 %correct left/right click train
%                 if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+a})
%                     BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}(1),BpodSystem.Data.Custom.RightClickTrain{iTrial+a}(1));
%                     BpodSystem.Data.Custom.RightClickTrain{iTrial+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}(1),BpodSystem.Data.Custom.RightClickTrain{iTrial+a}(1));
%                 elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+a})
%                     BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}(1) = BpodSystem.Data.Custom.RightClickTrain{iTrial+a}(1);
%                 elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{iTrial+a})
%                     BpodSystem.Data.Custom.RightClickTrain{iTrial+a}(1) = BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}(1);
%                 else
%                     BpodSystem.Data.Custom.LeftClickTrain{iTrial+a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
%                     BpodSystem.Data.Custom.RightClickTrain{iTrial+a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
%                 end
%                 if length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}) > length(BpodSystem.Data.Custom.RightClickTrain{iTrial+a})
%                     BpodSystem.Data.Custom.LeftRewarded(iTrial+a) = 1;
%                 elseif length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+a}) < length(BpodSystem.Data.Custom.RightClickTrain{iTrial+a})
%                     BpodSystem.Data.Custom.LeftRewarded(iTrial+a) = 0;
%                 else
%                     BpodSystem.Data.Custom.LeftRewarded(iTrial+a) = rand<0.5;
%                 end
%             else
%                 BpodSystem.Data.Custom.AuditoryOmega(iTrial+a) = NaN;
%                 BpodSystem.Data.Custom.LeftClickRate(iTrial+a) = NaN;
%                 BpodSystem.Data.Custom.RightClickRate(iTrial+a) = NaN;
%                 BpodSystem.Data.Custom.LeftRewarded(iTrial+a) = NaN;
%                 BpodSystem.Data.Custom.LeftClickTrain{iTrial+a} = [];
%                 BpodSystem.Data.Custom.RightClickTrain{iTrial+a} = [];
%             end %if auditory
%         end %for a=1:5
            
%     case 2 %freq stimuli
% 
%         StimulusSettings.SamplingRate = TaskParameters.GUI.Aud_SamplingRate; % Sound card sampling rate;
%         StimulusSettings.ramp = TaskParameters.GUI.Aud_Ramp;
%         StimulusSettings.nFreq = TaskParameters.GUI.Aud_nFreq; % Number of different frequencies to sample from
%         StimulusSettings.ToneOverlap = TaskParameters.GUI.Aud_ToneOverlap;
%         StimulusSettings.ToneDuration = TaskParameters.GUI.Aud_ToneDuration;
%         StimulusSettings.Noevidence=TaskParameters.GUI.Aud_NoEvidence;
%         StimulusSettings.minFreq = TaskParameters.GUI.Aud_minFreq ;
%         StimulusSettings.maxFreq = TaskParameters.GUI.Aud_maxFreq ;
%         StimulusSettings.UseMiddleOctave=TaskParameters.GUI.Aud_UseMiddleOctave;
%         StimulusSettings.Volume=TaskParameters.GUI.Aud_Volume;
%         StimulusSettings.nTones = floor((TaskParameters.GUI.AuditoryStimulusTime-StimulusSettings.ToneDuration*StimulusSettings.ToneOverlap)/(StimulusSettings.ToneDuration*(1-StimulusSettings.ToneOverlap))); %number of tones
        
%         if iTrial > TaskParameters.GUI.StartEasyTrials
%             newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,5,1,TaskParameters.GUI.Aud_Levels.AudPFrac)';
%             %include Fifty50 Trials
%             NewFifty50 = rand(5,1) < TaskParameters.GUI.Percent50Fifty;
%             newFracHigh(NewFifty50) = 50;
%         else
%             EasyProb = zeros(numel(TaskParameters.GUI.Aud_Levels.AudPFrac),1);
%             EasyProb(1) = 0.5; EasyProb(end)=0.5;
%             newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,5,1,EasyProb)';
%         end
% 
%         newCloud = cell(1,5);
%         newSound = cell(1,5);
%         for a = 1:5
%             if BpodSystem.Data.Custom.AuditoryTrial(iTrial+a)
%                 [Sound, Cloud, ~] = GenerateToneCloudDual(newFracHigh(a)/100, StimulusSettings);
%                 newCloud{a} = Cloud;
%                 newSound{a} = Sound;
%             end
%         end
% 
%         LeftRewarded = newFracHigh>50;
%         LeftRewarded (newFracHigh==050) = rand<0.5;
%         newFracHigh(~newAuditoryTrial) = nan(sum(~newAuditoryTrial),1);
%         BpodSystem.Data.Custom.AudFracHigh = [BpodSystem.Data.Custom.AudFracHigh, newFracHigh];
%         BpodSystem.Data.Custom.AudCloud = [BpodSystem.Data.Custom.AudCloud, newCloud];
%         BpodSystem.Data.Custom.AudSound = [BpodSystem.Data.Custom.AudSound, newSound];
%         BpodSystem.Data.Custom.LeftRewarded = [BpodSystem.Data.Custom.LeftRewarded, LeftRewarded];

% end %switch/case auditory stimulus type


% switch BpodSystem.Data.Custom.ClickTask(iTrial)
%     case true
%         if BpodSystem.Data.Custom.AuditoryTrial(a)
%                 BpodSystem.Data.Custom.AuditoryOmega(a) = betarnd(TaskParameters.GUI.AuditoryAlpha/4,TaskParameters.GUI.AuditoryAlpha/4,1,1);
%                 BpodSystem.Data.Custom.LeftClickRate(a) = round(BpodSystem.Data.Custom.AuditoryOmega(a)*TaskParameters.GUI.SumRates);
%                 BpodSystem.Data.Custom.RightClickRate(a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(a))*TaskParameters.GUI.SumRates);
%                 BpodSystem.Data.Custom.LeftClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
%                 BpodSystem.Data.Custom.RightClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
%                 %correct left/right click train
%                 if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
%                     BpodSystem.Data.Custom.LeftClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
%                     BpodSystem.Data.Custom.RightClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
%                 elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
%                     BpodSystem.Data.Custom.LeftClickTrain{a}(1) = BpodSystem.Data.Custom.RightClickTrain{a}(1);
%                 elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{1}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{a})
%                     BpodSystem.Data.Custom.RightClickTrain{a}(1) = BpodSystem.Data.Custom.LeftClickTrain{a}(1);
%                 else
%                     BpodSystem.Data.Custom.LeftClickTrain{a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
%                     BpodSystem.Data.Custom.RightClickTrain{a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
%                 end
%                 
%             if length(BpodSystem.Data.Custom.LeftClickTrain{a}) > length(BpodSystem.Data.Custom.RightClickTrain{a})
%                 BpodSystem.Data.Custom.LeftRewarded(a) = double(1);
%             elseif length(BpodSystem.Data.Custom.LeftClickTrain{1}) < length(BpodSystem.Data.Custom.RightClickTrain{a})
%                 BpodSystem.Data.Custom.LeftRewarded(a) = double(0);
%             else
%                 BpodSystem.Data.Custom.LeftRewarded(a) = rand<0.5;
%             end
%         else
%             BpodSystem.Data.Custom.AuditoryOmega(a) = NaN;
%             BpodSystem.Data.Custom.LeftClickRate(a) = NaN;
%             BpodSystem.Data.Custom.RightClickRate(a) = NaN;
%             BpodSystem.Data.Custom.LeftClickTrain{a} = [];
%             BpodSystem.Data.Custom.RightClickTrain{a} = [];
%         end
%     case false %frequency task
%         StimulusSettings.SamplingRate = TaskParameters.GUI.Aud_SamplingRate; % Sound card sampling rate;
%         StimulusSettings.ramp = TaskParameters.GUI.Aud_Ramp;
%         StimulusSettings.nFreq = TaskParameters.GUI.Aud_nFreq; % Number of different frequencies to sample from
%         StimulusSettings.ToneOverlap = TaskParameters.GUI.Aud_ToneOverlap;
%         StimulusSettings.ToneDuration = TaskParameters.GUI.Aud_ToneDuration;
%         StimulusSettings.Noevidence=TaskParameters.GUI.Aud_NoEvidence;
%         StimulusSettings.minFreq = TaskParameters.GUI.Aud_minFreq ;
%         StimulusSettings.maxFreq = TaskParameters.GUI.Aud_maxFreq ;
%         StimulusSettings.UseMiddleOctave=TaskParameters.GUI.Aud_UseMiddleOctave;
%         StimulusSettings.Volume=TaskParameters.GUI.Aud_Volume;
%         StimulusSettings.nTones = floor((TaskParameters.GUI.AuditoryStimulusTime-StimulusSettings.ToneDuration*StimulusSettings.ToneOverlap)/(StimulusSettings.ToneDuration*(1-StimulusSettings.ToneOverlap))); %number of tones
%         
%         EasyProb = zeros(numel(TaskParameters.GUI.Aud_Levels.AudPFrac),1);
%         EasyProb(1) = 0.5; EasyProb(end)=0.5;
%         newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,1,1,EasyProb);
%         [Sound, Cloud, ~] = GenerateToneCloudDual(newFracHigh/100, StimulusSettings);
%         BpodSystem.Data.Custom.AudFracHigh(a) = newFracHigh;
%         BpodSystem.Data.Custom.AudCloud{a} = Cloud;
%         BpodSystem.Data.Custom.AudSound{a} = Sound;
%         BpodSystem.Data.Custom.LeftRewarded(a)= newFracHigh>50;
% end % switch BpodSystem.Data.Custom.ClickTask(iTrial)

trial_data.LeftRewarded(iTrial) = rand<0.5;
BpodSystem.Data.Custom.TrialData = trial_data;

end %InitializeCustomDataFields