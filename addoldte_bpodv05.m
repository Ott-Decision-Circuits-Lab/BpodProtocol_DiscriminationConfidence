function newTE = AddOldTE_BpodV05(S)
global BpodSystem

TE=S.TE;
TrialParams=S.TrialParams;
TrialNum=S.currentTrial;
TE.nTrials=TrialNum;

        if TrialNum == 1
            % This is the first trial, initialize all fields
            TE.TrialStartTimeStamp = [];
            TE.InitialDelayDuration = [];
            TE.Stimulus1ID = [];
            TE.Stimulus1AvailableTimestamp = [];
            TE.Stimulus1SelfInitiateTimestamp = [];
            TE.Stimulus1OnsetTimestamp = [];
            TE.Stimulus1OffsetTimestamp = [];
            TE.Stimulus1SamplingDuration = [];
            TE.Stimulus1Modality = [];
            TE.Stimulus1DelayDuration = [];
            TE.Stimulus1EventName = cell(1,1);
            TE.InterStimulusInterval = [];
            TE.Stimulus2ID = [];
            TE.Stimulus2AvailableTimestamp = [];
            TE.Stimulus2SelfInitiateTimestamp = [];
            TE.Stimulus2OnsetTimestamp = [];
            TE.Stimulus2OffsetTimestamp = [];
            TE.Stimulus2SamplingDuration = [];
            TE.Stimulus2Modality = [];
            TE.Stimulus2DelayDuration = [];
            TE.Stimulus2EventName = cell(1,1);
            TE.ResponsePeriodDuration = [];
            TE.ResponseAttempted = [];
            TE.ResponseAttemptTimestamp = [];
            TE.ResponseAttemptDuration = [];
            TE.ResponseEventName = cell(1,1);
            TE.CorrectResponse = [];
            TE.Rewarded = [];
            TE.Punished = [];
            TE.RewardTimeStamp = [];
            TE.PunishTimeStamp = [];
            TE.PunishDuration = [];
            TE.ChoiceDir= [];
            TE.BasicStats = struct; % This will have accuracy, bias, etc.
            TE.SessionTimeDate = [datestr(now, 8) ' ' datestr(now, 1) datestr(now, 13)];
        end



%% new addtrial
        TE = AddTrialEvents(TE,S.RawTrialEvents, TrialNum); % Computes trial events from raw data

%% old addtrial

        TE.TrialTypes(TrialNum, 1) = TrialParams.TrialTypes(TrialNum); % Adds the trial type of the current trial to data

%% 

%         States_thistrial = BpodSystem.Data.RawEvents.Trial{TrialNum}.States;
        States_thistrial = TE.RawEvents.Trial{TrialNum}.States;
%         TE.TrialStartTimeStamp(TrialNum, 1) = S.RawTrialEvents.TrialStartTimestamp(1);
        TE.InitialDelayDuration(TrialNum, 1) = single(States_thistrial.InitialDelay(2) - States_thistrial.InitialDelay(1));
        

        TE.Stimulus1ID(TrialNum, 1) = TrialParams.StimulusID1(TrialNum);
        
        TE.Stimulus1AvailableTimestamp(TrialNum, 1) = States_thistrial.WaitForInitialPoke(1);
        
       TE.Stimulus1SelfInitiateTimestamp(TrialNum, 1) = States_thistrial.WaitForInitialPoke(2);

       TE.Stimulus1OnsetTimestamp(TrialNum, 1) = States_thistrial.DeliverStimulus1(end, 1);

       
try        if sum(isnan(States_thistrial.ContinueSampling)) == 0
            TE.Stimulus1OffsetTimestamp(TrialNum, 1) = States_thistrial.ContinueSampling(2);
           else
            TE.Stimulus1OffsetTimestamp(TrialNum, 1) = States_thistrial.DeliverStimulus1(end, 2);
           end
catch error 
end
        
try         TE.SamplingDuration(TrialNum, 1) = TE.Stimulus1OffsetTimestamp(TrialNum, 1) - TE.Stimulus1OnsetTimestamp(TrialNum, 1);
catch error
end
       
%         TE.Stimulus1Modality{TrialNum} = TrialParams.StimulusModality1{TrialNum};
         TE.Stimulus1DelayDuration(TrialNum, 1) = single(States_thistrial.StimulusDelay1(2) - States_thistrial.StimulusDelay1(1));       
        
%         TE.Stimulus1EventName{TrialNum} = TrialParams.InitiatingEvent1{TrialNum};
%         if TrialPams.UsingStim2(TrialNum) == 1
%             TE.InterraStimulusInterval(TrialNum, 1) = single(States_thistrial.InterStimDelay(2) - States_thistrial.InterStimDelay(1));
%             TE.Stimulus2ID(TrialNum, 1) = TrialParams.StimulusID1(TrialNum);
%             TE.Stimulus2AvailableTimestamp(TrialNum, 1) = States_thistrial.WaitForSecondPoke(1);
%             TE.Stimulus2SelfInitiateTimestamp(TrialNum, 1) = States_thistrial.WaitForSecondPoke(2);
%             TE.Stimulus2OnsetTimestamp(TrialNum, 1) = States_thistrial.DeliverStimulus2(1);
%             TE.Stimulus2OffsetTimestamp(TrialNum, 1) = States_thistrial.DeliverStimulus2(2);
%             TE.Stimulus2SamplingDuration(TrialNum, 1) = TE.Stimulus2OffsetTimestamp(TrialNum) - TE.Stimulus2OnsetTimestamp(TrialNum);
%             TE.Stimulus2Modality{TrialNum} = TrialParams.StimulusModality2{TrialNum};
%             TE.Stimulus2DelayDuration(TrialNum, 1) = single(States_thistrial.StimulusDelay2(2) - States_thistrial.StimulusDelay2(1));
%             TE.Stimulus2EventName{TrialNum} = TrialParams.InitiatingEvent2{TrialNum};
%         end

portused = TE.Settings.portused;
portleft=num2str(portused(1));
portcenter=num2str(portused(2));
portright=num2str(portused(3));

portchanged=(portused~=[1 2 3]);


         TE.ResponsePeriodDuration(TrialNum, 1) = single(States_thistrial.WaitForResponse(2) - States_thistrial.WaitForResponse(1));
         
         
         %update TE
         changedportID=find(portchanged==1);
         for iChange=1:changedportID;
             portid_pre = changedportID(iChange);
             portid_post = portused(changedportID(iChange));
             statefields=fields(States_thistrial);
            for iFields=1:length(statefields)
                   if strncmp(statefields(iFields), ['Port' num2str(portid_post)], 5)
                      fieldinterest=statefields{iFields};
                      val = getfield(States_thistrial,fieldinterest);
                      States_thistrial = setfield(States_thistrial, [fieldinterest(1:4) num2str(portid_pre) fieldinterest(6:end)], val)
                       States_thistrial = rmfield(States_thistrial, fieldinterest);
                   end
            end             
         end
         
 
         
         
         if ~isfield(States_thistrial, 'Port1RewardDelay')
             States_thistrial.Port1RewardDelay=[NaN NaN];
         end
         
         if ~isfield(States_thistrial, 'Port2RewardDelay')
             States_thistrial.Port2RewardDelay=[NaN NaN];
         end
         
         if ~isfield(States_thistrial, 'Port3RewardDelay')
             States_thistrial.Port3RewardDelay=[NaN NaN];
         end
         
         if ~isfield(States_thistrial, 'Port1PunishAttempt')
             States_thistrial.Port1PunishAttempt=[NaN NaN];
         end  
 
                  
         if ~isfield(States_thistrial, 'Port2PunishAttempt')
             States_thistrial.Port2PunishAttempt=[NaN NaN];
         end
            
         if ~isfield(States_thistrial, 'Port3PunishAttempt')
             States_thistrial.Port3PunishAttempt=[NaN NaN];
         end 
    
                 
         TE.ResponseAttempted(TrialNum, 1) = (sum(((sum(isnan(States_thistrial.Port1RewardDelay)) == 0))) > 0) || (sum(((sum(isnan(States_thistrial.Port3RewardDelay)) == 0))) > 0) || (sum(((sum(isnan(States_thistrial.Port2RewardDelay)) == 0))) > 0) || (sum(((sum(isnan(States_thistrial.PunishITI)) == 0))) > 0);
  
if TE.ResponseAttempted(TrialNum, 1) == 1
            ResponseType = find([(sum(((sum(isnan(States_thistrial.Port1RewardDelay)) == 0))) > 0)  (sum(((sum(isnan(States_thistrial.Port3RewardDelay)) == 0))) > 0)  (sum(((sum(isnan(States_thistrial.Port2RewardDelay)) == 0))) > 0) (sum(((sum(isnan(States_thistrial.PunishITI)) == 0))) > 0)]);
            switch ResponseType
                case 1
                    TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port1RewardDelay(1);
                    DSiz = size(States_thistrial.Port1RewardDelay); DLinearLength = DSiz(1)*DSiz(2);
                    TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port1RewardDelay(DLinearLength) - States_thistrial.Port1RewardDelay(1));
                    TE.ResponseEventName{TrialNum,1} = 'Lin';
                    TE.ChoiceDir(TrialNum, 1) = 1;           
                    TE.RewardTimeStamp(TrialNum, 1) = States_thistrial.Port1Reward(1);
                case 2
                    TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port3RewardDelay(1);
                    DSiz = size(States_thistrial.Port3RewardDelay); DLinearLength = DSiz(1)*DSiz(2);
                    TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port3RewardDelay(DLinearLength) - States_thistrial.Port3RewardDelay(1));
                    TE.ResponseEventName{TrialNum,1} = 'Rin';
                    TE.ChoiceDir(TrialNum, 1) = 2;
                    TE.RewardTimeStamp(TrialNum, 1) = States_thistrial.Port3Reward(1);
                case 3
                    TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port2RewardDelay(1);
                    DSiz = size(States_thistrial.Port2RewardDelay); DLinearLength = DSiz(1)*DSiz(2);
                    TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port2RewardDelay(DLinearLength) - States_thistrial.Port2RewardDelay(1));
                    TE.ResponseEventName{TrialNum,1} = 'Cin';
                    TE.ChoiceDir(TrialNum, 1) = 0;
                    TE.RewardTimeStamp(TrialNum, 1) = States_thistrial.Port2Reward(1);
                case 4
                    TE.ResponseAttemptTimestamp(TrialNum, 1) = NaN;
                    TE.ResponseAttemptDuration(TrialNum, 1) = NaN;
                    TE.RewardTimeStamp(TrialNum, 1) = NaN;
                    if sum(isnan(States_thistrial.Port1PunishAttempt)) == 0
                        TE.ResponseEventName{TrialNum,1} = 'Lin';
                        TE.ChoiceDir(TrialNum, 1) = 1;
                        DSiz = size(States_thistrial.Port1PunishAttempt); DLinearLength = DSiz(1)*DSiz(2);
                        TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port1PunishAttempt(DLinearLength) - States_thistrial.Port1PunishAttempt(1));
                        TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port1PunishAttempt(1);
                    elseif sum(isnan(States_thistrial.Port2PunishAttempt)) == 0
                        DSiz = size(States_thistrial.Port2PunishAttempt); DLinearLength = DSiz(1)*DSiz(2);
                        TE.ResponseEventName{TrialNum,1} = 'Cin';
                        TE.ChoiceDir(TrialNum, 1) = 0;
                        TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port2PunishAttempt(DLinearLength) - States_thistrial.Port2PunishAttempt(1));
                        TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port2PunishAttempt(1);
                    elseif sum(isnan(States_thistrial.Port3PunishAttempt)) == 0
                        TE.ResponseEventName{TrialNum,1} = 'Rin';
                        TE.ChoiceDir(TrialNum, 1) = 2;
                        DSiz = size(States_thistrial.Port3PunishAttempt); DLinearLength = DSiz(1)*DSiz(2);
                        TE.ResponseAttemptDuration(TrialNum, 1) = single(States_thistrial.Port3PunishAttempt(DLinearLength) - States_thistrial.Port3PunishAttempt(1));
                        TE.ResponseAttemptTimestamp(TrialNum, 1) = States_thistrial.Port3PunishAttempt(1);
                    end
            end
        else
            ResponseType = 5;
            TE.ResponseAttemptTimestamp(TrialNum, 1) = NaN;
            TE.ResponseAttemptDuration(TrialNum, 1) = NaN;
            TE.ResponseEventName{TrialNum,1} = '';
            TE.ChoiceDir(TrialNum, 1) = 0;   
            TE.RewardTimeStamp(TrialNum, 1) = NaN;

        end
        if ResponseType < 4
            TE.CorrectResponse(TrialNum, 1) = 1;
        else
            TE.CorrectResponse(TrialNum, 1) = 0;
        end
        TE.RewardAmount(TrialNum, 1) = TrialParams.RewardAmount(TrialNum, 1);
        TE.Rewarded(TrialNum, 1) = sum((sum(isnan(States_thistrial.Drinking)))) == 0;
        TE.Punished(TrialNum, 1) = (sum(isnan(States_thistrial.PunishITI)) == 0);
        TE.PunishTimeStamp(TrialNum, 1) = States_thistrial.PunishITI(1);
        TE.PunishDuration(TrialNum, 1) = single(States_thistrial.PunishITI(2) - States_thistrial.PunishITI(1));        


        try 
        TE.RewardOmissionBlock(TrialNum, 1) = TrialParams.RewardOmissionBlock(TrialNum, 1);
        TE.RewardDelays(TrialNum, 1) = TrialParams.RewardDelays(TrialNum, 1);
        catch error
            
        end
        


newTE = TE;
