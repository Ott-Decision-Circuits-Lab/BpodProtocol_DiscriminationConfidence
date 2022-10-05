function InitializeCustomDataFields()
%{ 
Initializing data (trial type) vectors and first values
%}

global BpodSystem
global TaskParameters

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
BpodSystem.Data.Custom.ResolutionTime = [];
BpodSystem.Data.Custom.Rewarded = false(0);
BpodSystem.Data.Custom.RewardMagnitude = TaskParameters.GUI.RewardAmount*[TaskParameters.GUI.BlockTable.RewL(1), TaskParameters.GUI.BlockTable.RewR(1)];
BpodSystem.Data.Custom.TrialNumber = [];
BpodSystem.Data.Custom.LaserTrial = false;
BpodSystem.Data.Custom.LaserTrialTrainStart = NaN;
BpodSystem.Data.Custom.AuditoryTrial = rand(1,2) < TaskParameters.GUI.PercentAuditory;
BpodSystem.Data.Custom.ClickTask = true(1,2) & TaskParameters.GUI.AuditoryStimulusType == 1;
BpodSystem.Data.Custom.OlfactometerStartup = false;
BpodSystem.Data.Custom.PsychtoolboxStartup = false;

% make auditory stimuli for first trials
for a = 1:2
    switch BpodSystem.Data.Custom.ClickTask(a)
        case true
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
                    BpodSystem.Data.Custom.LeftRewarded(a) = double(1);
                elseif length(BpodSystem.Data.Custom.LeftClickTrain{1}) < length(BpodSystem.Data.Custom.RightClickTrain{a})
                    BpodSystem.Data.Custom.LeftRewarded(a) = double(0);
                else
                    BpodSystem.Data.Custom.LeftRewarded(a) = rand<0.5;
                end
            else
                BpodSystem.Data.Custom.AuditoryOmega(a) = NaN;
                BpodSystem.Data.Custom.LeftClickRate(a) = NaN;
                BpodSystem.Data.Custom.RightClickRate(a) = NaN;
                BpodSystem.Data.Custom.LeftClickTrain{a} = [];
                BpodSystem.Data.Custom.RightClickTrain{a} = [];
            end
            
            
        case false
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
            
            EasyProb = zeros(numel(TaskParameters.GUI.Aud_Levels.AudPFrac),1);
            EasyProb(1) = 0.5; EasyProb(end)=0.5;
            newFracHigh = randsample(TaskParameters.GUI.Aud_Levels.AudFracHigh,1,1,EasyProb);
            [Sound, Cloud, ~] = GenerateToneCloudDual(newFracHigh/100, StimulusSettings);
            BpodSystem.Data.Custom.AudFracHigh(a) = newFracHigh;
            BpodSystem.Data.Custom.AudCloud{a} = Cloud;
            BpodSystem.Data.Custom.AudSound{a} = Sound;
            BpodSystem.Data.Custom.LeftRewarded(a)= newFracHigh>50;
    end
    if BpodSystem.Data.Custom.AuditoryTrial(a)
        if BpodSystem.Data.Custom.ClickTask
            BpodSystem.Data.Custom.DV(a) = (length(BpodSystem.Data.Custom.LeftClickTrain{a}) - length(BpodSystem.Data.Custom.RightClickTrain{a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{a}) + length(BpodSystem.Data.Custom.RightClickTrain{a}));
        else
            BpodSystem.Data.Custom.DV(a) = (2*BpodSystem.Data.Custom.AudFracHigh(a)-100)/100;
        end
        BpodSystem.Data.Custom.OdorFracA(a) = NaN;
        BpodSystem.Data.Custom.OdorID(a) = NaN;
        BpodSystem.Data.Custom.OdorPair(a) = NaN;
    else
        BpodSystem.Data.Custom.DV(a) = (2*BpodSystem.Data.Custom.OdorFracA(a)-100)/100;
    end
end%for a+1:2
end