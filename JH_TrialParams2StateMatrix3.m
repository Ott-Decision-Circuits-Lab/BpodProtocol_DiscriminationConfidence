function sma = JH_TrialParams2StateMatrix3(S)
global BpodSystem

% for Olfactory2AFCaj
% portused=[1 2 3];
portused = BpodSystem.ProtocolSettings.portused;

currentTrial=S.currentTrial;
TrialType = S.TrialParams.TrialTypes(currentTrial);
InitiatingEvent1 = S.TrialParams.InitiatingEvent1(currentTrial); %new

%JH130706
DrinkIdleTimer = 0.2; % Hard-coded param - time for the animal to not lick before next trial can begin
GracePeriodDuration = 0.5; % Hard-coded param - time for animal to leave goal port for the leave to "count".

DirectDelivery = S.TrialParams.DirectDelivery{currentTrial}; %new

Stim1Modality = S.TrialParams.StimulusModality1(currentTrial); %new
Stim1ID = S.TrialParams.StimulusID1(currentTrial);  %new
InitialDelay = S.TrialParams.InitialDelays(currentTrial);
SelfInitiated1 = S.TrialParams.SelfInitiated1(currentTrial);
ValidSamplingTime1 = S.TrialParams.ValidSamplingTime1(currentTrial);
StimulusDelay1 = S.TrialParams.Stimulus1Delay(currentTrial);
StimulusDuration1 = S.TrialParams.Stimulus1Durations(currentTrial);
TimeForResponse1 = S.TrialParams.TimeForResponse1(currentTrial);
InterStimDelay = S.TrialParams.InterStimDelays(currentTrial); %new

Stim2Modality = S.TrialParams.StimulusModality2(currentTrial); %new
Stim2ID = S.TrialParams.StimulusID2(currentTrial); %new
UsesStim2 = S.TrialParams.UsingStim2(currentTrial);  %new
SelfInitiated2 = S.TrialParams.SelfInitiated2(currentTrial); %new
ValidSamplingTime2 = S.TrialParams.ValidSamplingTime2(currentTrial); %new
StimulusDelay2 = S.TrialParams.Stimulus2Delays(currentTrial); %new
StimulusDuration2 = S.TrialParams.Stimulus2Durations(currentTrial); %new
TimeForResponse2 = S.TrialParams.TimeForResponse2(currentTrial);  %new

RewardDelay = S.TrialParams.RewardDelays(currentTrial);
RewardedEvent1 = S.TrialParams.RewardedEvent1(currentTrial);
PunishedEvent1 = S.TrialParams.PunishedEvent1(currentTrial);
RewardedEvent2 = S.TrialParams.RewardedEvent2(currentTrial); %new 
PunishedEvent2 = S.TrialParams.PunishedEvent2(currentTrial); %new
RewardAmount = S.TrialParams.RewardAmount(currentTrial);
RewardProbability = S.TrialParams.RewardProbability(currentTrial);
UsesRewardLocationLED = S.TrialParams.RewardLocationLight(currentTrial);
PunishITItimer = S.TrialParams.PunishITI(currentTrial);

if UsesStim2 == 1
    TimeForResponse = TimeForResponse2;
else
    TimeForResponse = TimeForResponse1;
end

%% stimulus

Modality1 = Stim1Modality;
try 
    switch Stim1Modality
    case 'Odor'
        Modality1 = 1;
    case 'Sound'
        Modality1 = 2;
    case 'PortLED'
        Modality1 = 3;
    case 'ExternalTrig'
        Modality1 = 4;
    end
catch error
    Modality1=0;
end

if Modality1 == 1
    if Stim1ID > 0 % If the odor has not been zeroed due to delivery prob
     % odor conc
    OdorRatio_trialtypes = S.ProtocolSettings.OdorRatio_trialtypes;
    SetBankFlowRate(S.OlfIP, 1+S.BankPairOffset, OdorRatio_trialtypes(TrialType)); % Set bank 1 to 100ml/min (requires Bpod computer on same ethernet network as olfactometer)
    SetBankFlowRate(S.OlfIP, 2+S.BankPairOffset, 100-OdorRatio_trialtypes(TrialType)); % Set bank 1 to 100ml/min (requires Bpod computer on same ethernet network as olfactometer)
    end
end


Modality2 = 0;
try
    switch Stim2Modality
        case 'Odor'
            Modality2 = 1;
        case 'Sound'
            Modality2 = 2;
        case 'PortLED'
            Modality2 = 3;
        case 'ExternalTrig'
            Modality2 = 4;
    end
catch error
    Modality1=0;
end

if UsesStim2 == 1
    % Determine state machine code for odor/mixture to deliver if applicable
    if Modality2 == 1
        if Stim2ID > 0 % If the odor has not been zeroed due to delivery prob
        end
    end
end


% % Determine the stim-ready light
% Stim1ReadyDIO = 0;
StimAbortEvent = ['Port' num2str(portused(2)) 'Out']; % abort before stim delivery: no count as trial
PostStimAbortEvent = ['Port' num2str(portused(2)) 'Out']; % abort after stim delivery: count as canceled trial
LightCode1 = ['DIO.Port' num2str(portused(2)) 'LED']; 

%% Determine which LED to light if LED stimulus
% --->search ThisTrialPunishBNC
% PunishTTL1 = S.TrialParams.Ch1PTrig(currentTrial);
% PunishTTL2 = S.TrialParams.Ch2PTrig(currentTrial);
% PunishAction = {};
% if ((PunishTTL1 == 1) || (PunishTTL2 == 1))
%     PunishAction = {'BNCState', PunishTTL1 + 2*PunishTTL2};
% end
% 
%% Get water valve times

valvecodes_seq=[2^0 2^1 2^2 2^3 2^4 2^5 2^6 2^7];
ValveTimes = nan(1,3);
ValveCodes= nan(1,3);
for x = 1:3
    if strcmp(RewardedEvent1, ['Port' num2str(portused(x)) 'In'])
        ValveTimes(x) = GetValveTimes(RewardAmount,portused(x));     
    end
    
     if strcmp(RewardedEvent2, ['Port' num2str(portused(x)) 'In'])
        ValveTimes(x) = GetValveTimes(RewardAmount,portused(x));     
     end   
     
    if x==2 % centra port
    ValveCodes(x) = 0;
    else
    ValveCodes(x) = valvecodes_seq(portused(x));
    end
end

LedCenter=['PWM' num2str(portused(2))];
LedLeft=['PWM' num2str(portused(1))];
LedRight=['PWM' num2str(portused(3))];

%% setup for state matrix-----

%% Change routing if stim 1 self-initiated
if SelfInitiated1 == 0
    InitialActionState = 'DeliverStimulus1';
else
    InitialActionState = 'WaitForInitialPoke';
end

% Change routing if not using second stimulus
if UsesStim2 == 0
    if DirectDelivery == 0
        FirstStimDoneAction = 'WaitForResponse';
    else
        FirstStimDoneAction = 'DirectDeliverReward1';
    end
else
    FirstStimDoneAction = 'InterStimDelay';
    if DirectDelivery == 0
        SecondStimDoneAction = 'WaitForResponse';
    else
        SecondStimDoneAction = 'DirectDeliverReward1';
    end
end

% Change routing if stim 2 self-initiated
if SelfInitiated2 == 0
    SecondActionState = 'DeliverStimulus2';
else
    SecondActionState = 'WaitForSecondPoke';
end
     
    
% Handle empty rewarded event slots			
	if isempty(RewardedEvent2)			
	    RewardedEvent2 = RewardedEvent1;			
	end			
	if isempty(PunishedEvent2)			
	    PunishedEvent2 = PunishedEvent1;			
	end
        
% Determine actions for all possible responses
ResponseActionString = {};
RewardStateClustersToAdd = zeros(1,3);
PunishStateClustersToAdd = zeros(1,6);
WaitingForResponseDIO = 0;
for x = 1:3
    if rand < RewardProbability
        if strcmp(RewardedEvent1, ['Port' num2str(portused(x)) 'In'])
            ResponseActionString = [ResponseActionString {['Port' num2str(portused(x)) 'In']} {['Port' num2str(portused(x)) 'RewardTrig']}];
            RewardStateClustersToAdd(x) = 1;
        end
          if strcmp(RewardedEvent2, ['Port' num2str(portused(x)) 'In'])
            ResponseActionString = [ResponseActionString {['Port' num2str(portused(x)) 'In']} {['Port' num2str(portused(x)) 'RewardTrig']}];
            RewardStateClustersToAdd(x) = 1;
        end
    else
            ResponseActionString = [ResponseActionString {['Port' num2str(portused(x)) 'In']} {['iti']}];      
    end
     if strcmp(PunishedEvent1, ['Port' num2str(portused(x)) 'In'])
         ResponseActionString = [ResponseActionString {['Port' num2str(portused(x)) 'In']} {['Port' num2str(portused(x)) 'PunishAttempt']}];
         PunishStateClustersToAdd(x) = 1;
     end
     if strcmp(PunishedEvent2, ['Port' num2str(portused(x)) 'In'])
         ResponseActionString = [ResponseActionString {['Port' num2str(portused(x)) 'In']} {['Port' num2str(portused(x)) 'PunishAttempt']}];
         PunishStateClustersToAdd(x) = 1;
     end
end
ResponseActionString = [ResponseActionString {'Tup'} {'iti'}];

%% Calculate BNC out values for checkboxes (i.e. TTL on BNC1 with reward)

% Initial delay
ThisTrialIDBNC = 0;
% Stimulus delay
ThisTrialSDBNC = 0; 
% Stimulus
ThisTrialStimBNC = 0;
% Reward
ThisTrialRewardBNC = 0; 
% Punishment
ThisTrialPunishBNC = 0; 

ThisTrialIDBNC = ThisTrialIDBNC + S.TrialParams.Ch1IDTrig(currentTrial);
ThisTrialIDBNC = ThisTrialIDBNC + S.TrialParams.Ch2IDTrig(currentTrial)*2;

ThisTrialSDBNC = ThisTrialSDBNC + S.TrialParams.Ch1SDTrig(currentTrial);
ThisTrialSDBNC = ThisTrialSDBNC + S.TrialParams.Ch2SDTrig(currentTrial)*2;

ThisTrialStimBNC = ThisTrialStimBNC + S.TrialParams.Ch1STrig(currentTrial);
ThisTrialStimBNC = ThisTrialStimBNC + S.TrialParams.Ch2STrig(currentTrial)*2;

ThisTrialRewardBNC = ThisTrialRewardBNC + S.TrialParams.Ch1RTrig(currentTrial);
ThisTrialRewardBNC = ThisTrialRewardBNC + S.TrialParams.Ch2RTrig(currentTrial)*2;

ThisTrialPunishBNC = ThisTrialPunishBNC + S.TrialParams.Ch1PTrig(currentTrial);
ThisTrialPunishBNC = ThisTrialPunishBNC + S.TrialParams.Ch2PTrig(currentTrial)*2;


% if BpodSystem.ProtocolSettings.ErrorSound==1
%     hostname=strtrim(evalc('system(''hostname'');'));
%     if strcmp(hostname,'cnmc15-PC') 
% %         ThisTrialPunishBNC=ThisTrialPunishBNC+2;
%         ThisTrialPunishBNC=12; %JH I'm not considering opt stim dur task
%     else
%         ThisTrialPunishBNC=3;
%     end
% end


%% add state
sma = NewStateMatrix();


sma = AddState(sma, 'Name', 'InitialDelay', ...
    'Timer', InitialDelay,...
    'StateChangeConditions', ...
    {'Tup', InitialActionState},...
    'OutputActions', {'BNCState', ThisTrialIDBNC});

%Wait for initial poke.  Sends immediately to StimulusDelay1.
% Presumably S.TrialParams.InitiatingEvent1{currentTrial} is
% 'Port2In' most of the time.

sma = AddState(sma, 'Name', 'WaitForInitialPoke', ...
    'Timer', 0,...                                 % from 'self_timer', 0,
    'StateChangeConditions', {InitiatingEvent1, 'StimulusDelay1'},...
    'OutputActions', {LedCenter, 255});

%Waiting for stimulus onset.
% - If next event is Tup, then he waited long enough - deliver stimulus.
% - If next event is StimAbortEvent1 (presumably 'Port2Out'?) then go back to
%waiting state.  This can ALSO be sent to 'iti', in which case it will
%register as a failed trial. But if this has happened, we know that he hasn't
%seen the stimulus at all!  So counting this as a trial-reset (rather than
%forcing a new trial) separates these two kinds of failures.

sma = AddState(sma, 'Name', 'StimulusDelay1', ...
    'Timer', StimulusDelay1,...
    'StateChangeConditions', {StimAbortEvent, 'WaitForInitialPoke',...  % If Port2Out, then abort trial silently (ie., not counted as a failure
    'Tup', 'DeliverStimulus1'},...              % If Tup, deliver the stimulus. 
    'OutputActions', {'BNCState', ThisTrialSDBNC, LedCenter, 0});

switch Modality1
    case 1
        % Deliver an olfactory stimulus
        
        %Deliver stimulus.  If 'Port2Out' happens before 'Tup', then counts as
        %a failed trial.  Note that there is an N-ms period in which he
        %could abort before odor reaches him that counts as a failed trial
        %(vs. a trail reset if he aborts before the odor valve opens).
        
        sma = AddState(sma, 'Name', 'DeliverStimulus1', ...
            'Timer', ValidSamplingTime1,...
            'StateChangeConditions', {'Tup', 'ContinueSampling', PostStimAbortEvent, 'iti'},...
            'OutputActions', {'SoftCode', 1, 'BNCState', ThisTrialStimBNC});
        
        
        % After Tup in ValidSamplingTime1, he can either keep sampling
        % until he gets bored or until the stimulus duration is over.
        % After this point, we enter 'FirstStimDoneAction', which is either
        % a) 'WaitForResponse' (if Direct Delivery is 0) or b)
        % 'DirectDeliverReward1' (if Direct Delivery is 1).
                
        sma = AddState(sma, 'Name', 'ContinueSampling', ...
            'Timer', (StimulusDuration1 - ValidSamplingTime1),...
            'StateChangeConditions', ...
            {PostStimAbortEvent, FirstStimDoneAction, ...
            'Tup', FirstStimDoneAction},...
            'OutputActions',  {});
    case 2
        % Deliver an auditory stimulus
        sma = AddState(sma, 'Name', 'DeliverStimulus1', ...
            'Timer', ValidSamplingTime1,...
            'StateChangeConditions', ...
            {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling'},...
            'OutputActions', {'SoundOut',Stim1ID,'BNCState', ThisTrialStimBNC});
        
        sma = AddState(sma, 'Name', 'ContinueSampling', ...
            'Timer', (StimulusDuration1 - ValidSamplingTime1),...
            'StateChangeConditions', ...
            {PostStimAbortEvent, FirstStimDoneAction, 'Tup', FirstStimDoneAction},...
            'OutputActions', {});
    case 3
        % Deliver a light stimulus w/ LED.
        sma = AddState(sma, 'Name', 'DeliverStimulus1', ...
            'Timer', ValidSamplingTime1,...
            'StateChangeConditions', ...
            {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling'},...
            'OutputActions', {'Dout',LightCode1,'BNCState', ThisTrialStimBNC});
        sma = AddState(sma, 'Name', 'ContinueSampling', ...
            'Timer', (StimulusDuration1 - ValidSamplingTime1),...
            'StateChangeConditions', ...
            {PostStimAbortEvent, FirstStimDoneAction, 'Tup', FirstStimDoneAction},...
            'OutputActions', {'Dout',LightCode1});
    case 4
        % Deliver a TTL stimulus
        disp('Not implemented.  Talk to Josh.')
        keyboard
        
    otherwise
            sma = AddState(sma, 'Name', 'DeliverStimulus1', ...
            'Timer', 0,...
            'StateChangeConditions', ...
            {'Tup', 'WaitForResponse'},...
            'OutputActions', {LedLeft, 255, LedRight, 255});
        
end

if UsesStim2 == 1
    sma = AddState(sma, 'Name', 'InterStimDelay', ...
        'Timer', InterStimDelay,...
        'StateChangeConditions', ...
        {'Tup', SecondActionState},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'WaitForSecondPoke', ...
        'Timer', 0,...
        'StateChangeConditions', ...
        {S.TrialParams.InitiatingEvent2{currentTrial}, 'StimulusDelay2'},...
        'OutputActions', {'Dout', Stim2ReadyDIO});
    sma = AddState(sma, 'Name', 'StimulusDelay2', ...
        'Timer', StimulusDelay2,...
        'StateChangeConditions', ...
        {S.TrialParams.InitiatingEvent2{currentTrial}, 'DeliverStimulus2', StimAbortEvent, 'WaitForSecondPoke', 'Tup', 'DeliverStimulus2'},...
        'OutputActions', {});
    
    switch Modality2
        case 1
            sma = AddState(sma, 'Name', 'DeliverStimulus2', ...
                'Timer', ValidSamplingTime2,...
                'StateChangeConditions', ...
                {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling2'},...
                'OutputActions', {'OdorOut',OdorCode2});
            sma = AddState(sma, 'Name', 'ContinueSampling2', ...
                'Timer', (StimulusDuration2 - ValidSamplingTime2),...
                'StateChangeConditions', ...
                {PostStimAbortEvent, SecondStimDoneAction, 'Tup', SecondStimDoneAction},...
                'OutputActions', {'OdorOut',OdorCode2,'BNCState', ThisTrialStimBNC});
        case 2
            % Deliver an auditory stimulus
            sma = AddState(sma, 'Name', 'DeliverStimulus2', ...
                'Timer', ValidSamplingTime2,...
                'StateChangeConditions', ...
                {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling2'},...
                'OutputActions', {'SoundOut',Stim2ID,'BNCState', ThisTrialStimBNC});
            sma = AddState(sma, 'Name', 'ContinueSampling2', ...
                'Timer', (StimulusDuration2 - ValidSamplingTime2),...
                'StateChangeConditions', ...
                {PostStimAbortEvent, SecondStimDoneAction, 'Tup', SecondStimDoneAction},...
                'OutputActions', {});
        case 3
            % Deliver a port light stimulus
            sma = AddState(sma, 'Name', 'DeliverStimulus2', ...
                'Timer', ValidSamplingTime2,...
                'StateChangeConditions', ...
                {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling2'},...
                'OutputActions', {'Dout',LightCode2,'BNCState', ThisTrialStimBNC});
            sma = AddState(sma, 'Name', 'ContinueSampling2', ...
                'Timer', (StimulusDuration2 - ValidSamplingTime2),...
                'StateChangeConditions', ...
                {PostStimAbortEvent, SecondStimDoneAction, 'Tup', SecondStimDoneAction},...
                'OutputActions', {'Dout',LightCode2});
        case 4
            % Deliver a TTL stimulus
        otherwise
            sma = AddState(sma, 'Name', 'DeliverStimulus2', ...
                'Timer', 0,...
                'StateChangeConditions', ...
                {PostStimAbortEvent, 'iti', 'Tup', 'ContinueSampling2'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'ContinueSampling2', ...
                'Timer', (StimulusDuration2 - ValidSamplingTime2),...
                'StateChangeConditions', ...
                {PostStimAbortEvent, SecondStimDoneAction, 'Tup', SecondStimDoneAction},...
                'OutputActions', {});
    end
    
    
end
        

% After a successful sampling period (whatever that is in this trial) we
% wait for a response.  The only available responses are a) poke in one of the three
% pokes, or b) wait until ITI.  Others could be coded, but we need to
% process 'D2in' or similar events here.  Once these actions happen, we
% send to XYZResponseAction or if 'Tup' then this is a failed trial and we
% send to 'iti'.
sma = AddState(sma, 'Name', 'WaitForResponse', ...
    'Timer', TimeForResponse,...
    'StateChangeConditions', ...
    ResponseActionString,...
    'OutputActions',  {LedLeft, 255, LedRight, 255});  % No LED right.  'PWM1', 255, 'PWM3', 255 'SoftCode', 2

% Add reward state clusters
for x = 1:3
    if RewardStateClustersToAdd(x) == 1
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'RewardTrig'], ...
            'Timer', 0,...
            'StateChangeConditions', ...
            {'Tup', ['Port' num2str(portused(x)) 'RewardDelay']},...
            'OutputActions', {LedLeft, 0, LedRight, 0});
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'RewardDelay'], ...
            'Timer', RewardDelay,...
            'StateChangeConditions', ...
            {'Tup', ['Port' num2str(portused(x)) 'Reward'], ['Port' num2str(portused(x)) 'Out'], ['Port' num2str(portused(x)) 'RewardGrace']},...
            'OutputActions', {});
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'RewardGrace'], ...
            'Timer', GracePeriodDuration,...
            'StateChangeConditions', ...
            {'Tup', 'iti', 'Port2In', 'iti', ['Port' num2str(portused(x)) 'In'], ['Port' num2str(portused(x)) 'RewardDelay']},...
            'OutputActions', {});
        
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'Reward'], ...
            'Timer', ValveTimes(x),...
            'StateChangeConditions', ...
            {'Tup', 'Drinking'},...
            'OutputActions', {'ValveState', ValveCodes(x),'BNCState', ThisTrialRewardBNC});
    end
end

% Add punish state clusters


%JH130531 changed
for x = 1:3
    if PunishStateClustersToAdd(x) == 1
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'PunishAttempt'], ...
            'Timer', RewardDelay,...
            'StateChangeConditions', ...
            {'Tup', 'Punish', ['Port' num2str(portused(x)) 'Out'], ['Port' num2str(portused(x)) 'PunishGrace']},...
            'OutputActions', {LedLeft, 0, LedRight, 0});
        sma = AddState(sma, 'Name', ['Port' num2str(portused(x)) 'PunishGrace'], ...
            'Timer', GracePeriodDuration,...
            'StateChangeConditions', ...
            {'Tup', 'iti', 'Port2In', 'iti', ['Port' num2str(portused(x)) 'In'], ['Port' num2str(portused(x)) 'PunishAttempt']},...  %JH Tup is abort trial (rats don't know the outcome yet).
            'OutputActions', {});
    end
end


%JH130601 130706available
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 0,...
    'StateChangeConditions', ...
    {['Port' num2str(portused(1)) 'Out'], 'ResetDrinkTimer', ['Port' num2str(portused(3)) 'Out'], 'ResetDrinkTimer'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'ResetDrinkTimer', ...
    'Timer', DrinkIdleTimer,...
    'StateChangeConditions', ...
    {'Tup', 'iti', ['Port' num2str(portused(1)) 'In'], 'Drinking', ['Port' num2str(portused(3)) 'In'], 'iti', ['Port' num2str(portused(3)) 'In'], 'Drinking'},...
    'OutputActions', {});
%JH130601 end 130706available


sma = AddState(sma, 'Name', 'Punish', ...
    'Timer', 0,...
    'StateChangeConditions', ...
    {['Port' num2str(portused(1)) 'Out'], 'PunishITI', ['Port' num2str(portused(3)) 'Out'], 'PunishITI', ['Port' num2str(portused(2)) 'In'], 'PunishITI'},...
    'OutputActions', {'BNCState', ThisTrialPunishBNC}); %JH130531 added 

sma = AddState(sma, 'Name', 'PunishITI', ...
    'Timer', PunishITItimer,...
    'StateChangeConditions', ...
   {'Tup', 'iti'},...
    'OutputActions', {}); %JH130531 added 

sma = AddState(sma, 'Name', 'iti', ...
    'Timer', 0,...
    'StateChangeConditions', ...
    {'Tup', 'exit'},...
    'OutputActions', {});

%  JH141105 what's this? not necessary?
% sma = AddState(sma, 'Name', 'MadeWithEditor', ... 
%     'Timer', 0,...
%     'StateChangeConditions', ...
%     {'Tup', 'final_state'},...
%     'OutputActions', {});





% % For debugging
%         disp(['Trial ' num2str(currentTrial)])
%         disp('Stimulus Delay: ')
%             StimulusDelay1;
%         disp('Stimulus Duration: ')
%             StimulusDuration1 - ValidSamplingTime1;
%         disp(['FirstStimDoneAction: ' FirstStimDoneAction])