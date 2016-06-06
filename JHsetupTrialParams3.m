function S = JHsetupTrialParams3(S)
global BpodSystem
portused = BpodSystem.ProtocolSettings.portused;

% basic information
        [path1 sessionname]=fileparts(BpodSystem.DataPath);
        [path2 junk]=fileparts(path1)
        [path3 task]=fileparts(path2)
        [junk animal]=fileparts(path3)       
%          [OlfIP BankPairOffset Carrier hostname] = olfactometerIP_JH;
        hostname=strtrim(evalc('system(''hostname'');'));
        OlfIP = [192 168 1 110];
        BankPairOffset = 2;
        Carrier=1;


%         imagedir = fullfile(BpodSystem.DropboxPath, 'Images', animal)
%         imagepath=fullfile(imagedir, sessionname, '.jpg')
%         if ~exist(imagedir)
%             mkdir(imagedir)
%         end
%         export_fig sessionname

        S.sessionname=sessionname;
        S.animal=animal;
        S.protocol=task;
        S.starttime=datestr(BpodSystem.Birthdate);
          S.OlfIP=OlfIP;
          S.BankPairOffset=BankPairOffset;
          S.hostname=hostname;
          S.Carrier=Carrier;
         
%         S.savepath=
%      


OdorRatio_trialtypes = S.ProtocolSettings.OdorRatio_trialtypes;
S.OdorRatio_trialtypes = OdorRatio_trialtypes;

OdorRatio = sort(OdorRatio_trialtypes, 'descend');
S.OdorRatio = OdorRatio;

nTrialTypes = length(OdorRatio);
MaxTrials = S.ProtocolSettings.MaxTrials;

% creat random TrialTypes
TrialTypes = ceil(rand(MaxTrials, 1)*nTrialTypes);


    S.TrialParams = struct;
    S.TrialParams.MaxTrials=MaxTrials;

% Extract Stimulus 1 ID for all trials
    S.TrialParams.StimulusID1 = TrialTypes;
    S.TrialParams.UsingStim2 = zeros(MaxTrials,1);
    S.TrialParams.StimulusID2 = zeros(MaxTrials,1);
    S.TrialParams.TrialTypes = TrialTypes;
    S.TrialParams.LeftCorrect=mod(TrialTypes,2);
    S.TrialParams.RightCorrect=abs(1-mod(TrialTypes,2));

    S.TrialParams.TrialIDByTrial = zeros(MaxTrials,1);

%% add stim1
    % Extract Stimulus 1 Modalilty for all trials
    S.TrialParams.StimulusModality1 = ones(MaxTrials,1); %olfactory==1
    
    % Extract Stim 1 Self Initiated / Automatic for all trials
    S.TrialParams.SelfInitiated1 = ones(MaxTrials,1);
    S.TrialParams.SelfInitiated2 = zeros(MaxTrials,1);
    
    % Extract Stim 1 Initiating Event for all trials
    InitiatingEvent1 = repmat({['Port' num2str(portused(2)) 'In']}, nTrialTypes, 1);
    S.TrialParams.InitiatingEvent1 = InitiatingEvent1(TrialTypes);

    % Stimulus modality
    Stim1Modality = repmat({'Odor'}, nTrialTypes, 1);
    S.TrialParams.Stim1Modality = Stim1Modality(TrialTypes);
    Stim2Modality = repmat({'none'}, nTrialTypes, 1);    
    S.TrialParams.Stim2Modality = Stim2Modality(TrialTypes);

    % Extract Stim 1 ReactionTime / Forced Sampling Period / Automatic for all trials
    Unused1 = zeros(MaxTrials,1);
    S.TrialParams.Unused1 = Unused1;
        
    S.TrialParams.RewardLocationLight = zeros(MaxTrials,1);
            
    % Extract Stim1 Minimum Sampling Time for Valid Poke / Automatic for all trials
    S.TrialParams.ValidSamplingTime1 = ones(MaxTrials,1).*S.ProtocolSettings.ValidSamplingTime1;
    
    % Extract Stim1 Time for response for all trials
    S.TrialParams.TimeForResponse1 = ones(MaxTrials,1).*S.ProtocolSettings.TimeForResponse1;

    %% add stim2 (does not matter, no use)
    % Extract Stimulus 2 ID for all trials
    StimulusID2 = zeros(MaxTrials,1);
    S.TrialParams.StimulusID2 = StimulusID2(TrialTypes);
 
    % Extract Stimulus 2 Modalilty for all trials
    S.TrialParams.StimulusModality2 = zeros(MaxTrials,1);
    
    % Extract Stim 2 Self Initiated / Automatic for all trials
    S.TrialParams.SelfInitiated2 = zeros(MaxTrials,1);
    
    % Extract Stim 2 Initiating Event for all trials
    S.TrialParams.InitiatingEvent2 =zeros(MaxTrials,1);
    
    % Extract Stim 2 ReactionTime / Forced Sampling Period / Automatic for all trials
    S.TrialParams.Unused2 = zeros(MaxTrials,1);
    
    % Extract Stim2 Minimum Sampling Time for Valid Poke / Automatic for all trials
    S.TrialParams.ValidSamplingTime2= zeros(MaxTrials,1);
    
    % Extract Stim2 Time for response for all trials
    S.TrialParams.TimeForResponse2 = zeros(MaxTrials,1);
    
    %%
    
    % Extract Direct Delivery Mode for all trials
    DirectDelivery=repmat({0}, nTrialTypes, 1) ;
    S.TrialParams.DirectDelivery = DirectDelivery(TrialTypes);
    
    % Extract Rewarded Event 1 for all trials
    RewardedEvent1 = {['Port' num2str(portused(1)) 'In'], ['Port' num2str(portused(3)) 'In'], ['Port' num2str(portused(1)) 'In'], ['Port' num2str(portused(3)) 'In'], ['Port' num2str(portused(1)) 'In'], ['Port' num2str(portused(3)) 'In']};
    S.TrialParams.RewardedEvent1 = RewardedEvent1(TrialTypes);
    
    
    % Extract Punished Event 1 for all trials
    PunishedEvent1 = {['Port' num2str(portused(3)) 'In'], ['Port' num2str(portused(1)) 'In'], ['Port' num2str(portused(3)) 'In'], ['Port' num2str(portused(1)) 'In'], ['Port' num2str(portused(3)) 'In'], ['Port' num2str(portused(1)) 'In']};
    S.TrialParams.PunishedEvent1 = PunishedEvent1(TrialTypes);
    

    % Extract RewardAmount for all trials
%     RewardAmount = ones(MaxTrials,1).*S.ProtocolSettings.RewardAmount;
    RewardAmount = ones(MaxTrials,1);
    RewardAmountLeft = S.ProtocolSettings.RewardAmount(1);
    try     RewardAmountRight = S.ProtocolSettings.RewardAmount(2);
    catch error
           RewardAmountRight = S.ProtocolSettings.RewardAmount(1);
    end
    
    RewardAmount(logical(S.TrialParams.LeftCorrect))=RewardAmountLeft;
    RewardAmount(logical(S.TrialParams.RightCorrect))=RewardAmountRight;
            
    S.TrialParams.RewardAmount = RewardAmount;

    % Extract Reward Probability for all trials
    RewardProbability =  ones(MaxTrials,1).*S.ProtocolSettings.RewardProbability;
    S.TrialParams.RewardProbability = RewardProbability;
    
    % Extract PunishITI for all trials    
    PunishITI =  ones(MaxTrials,1).*S.ProtocolSettings.PunishITI;
    S.TrialParams.PunishITI = PunishITI;
    
    % Extract Stim1 Go Light (binary) for all trials
    StimReadyLight1 = ones(MaxTrials,1).*0;
    S.TrialParams.StimReadyLight1 = StimReadyLight1;
     
    % Extract pulses to be sent on external stimulation channels
    S.TrialParams.Ch1IDTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch1IDTrig;
    S.TrialParams.Ch1SDTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch1SDTrig;
    S.TrialParams.Ch1STrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch1STrig;
    S.TrialParams.Ch1RTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch1RTrig;
    S.TrialParams.Ch1PTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch1PTrig;

    S.TrialParams.Ch2IDTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch2IDTrig;
    S.TrialParams.Ch2SDTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch2SDTrig;
    S.TrialParams.Ch2STrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch2STrig;
    S.TrialParams.Ch2RTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch2RTrig;
    S.TrialParams.Ch2PTrig =  ones(MaxTrials,1).*S.ProtocolSettings.Ch2PTrig;
        
    % Define Initial Delay, Stim Delay and Reward Delay for all trials using parameters in matrix
    S.TrialParams.InitialDelays = zeros(MaxTrials,1);
    S.TrialParams.Stimulus1Delay = zeros(MaxTrials,1);
    S.TrialParams.Stimulus1Durations = zeros(MaxTrials,1);
    S.TrialParams.Stimulus2Delays = zeros(MaxTrials,1);
    S.TrialParams.Stimulus2Durations = zeros(MaxTrials,1);
    S.TrialParams.RewardDelays = zeros(MaxTrials,1);
    
    RewardedEvent1={};
    PunishedEvent1={};
    RewardedEvent2={};
    PunishedEvent2={};
    for x=1:length(S.TrialParams.LeftCorrect)
        if (S.TrialParams.LeftCorrect(x))
         RewardedEvent1(x, 1)= {['Port' num2str(portused(1)) 'In']};
         PunishedEvent1(x, 1)= {['Port' num2str(portused(3)) 'In']};
         RewardedEvent2(x, 1)= {''};
         PunishedEvent2(x, 1)= {''};
        else
         RewardedEvent1(x, 1)= {['Port' num2str(portused(3)) 'In']};   
         PunishedEvent1(x, 1)= {['Port' num2str(portused(1)) 'In']};
         RewardedEvent2(x, 1)= {''};   
         PunishedEvent2(x, 1)= {''};
        end      
    end
    S.TrialParams.RewardedEvent1 = RewardedEvent1;
    S.TrialParams.PunishedEvent1 = PunishedEvent1;
    S.TrialParams.RewardedEvent2 = RewardedEvent2;
    S.TrialParams.PunishedEvent2 = PunishedEvent2;

    
    for z = 1:length(TrialTypes)
        
        
        IDMean = 0; % S.ProtocolSettings.InitialDelaysMean;
        IDMin = 0; % S.ProtocolSettings.InitialDelaysMin;
        IDMax = 0; % S.ProtocolSettings.InitialDelaysMax;
        IDDistrib = 'Uniform';
              
        SD1Mean = S.ProtocolSettings.Stim1DelayMean;
        SD1Min = S.ProtocolSettings.Stim1DelayMin;
        SD1Max =S.ProtocolSettings.Stim1DelayMax;
        SD1Distrib = 'Uniform';

        SDr1Mean = S.ProtocolSettings.Stim1DurationMean;
        SDr1Min = S.ProtocolSettings.Stim1DurationMin;
        SDr1Max =S.ProtocolSettings.Stim1DurationMax;
        SDr1Distrib = 'Uniform';

        ISDMean = S.ProtocolSettings.InterStimDelayMean;
        ISDMin = S.ProtocolSettings.InterStimDelayMin;
        ISDMax =S.ProtocolSettings.InterStimDelayMax;
        ISDDistrib = 'Uniform';
        
        SD2Mean = 0; %S.ProtocolSettings.Stim2DelayMean;
        SD2Min =0; % S.ProtocolSettings.Stim2DelayMin;
        SD2Max = 0; %S.ProtocolSettings.Stim2DelayMax;
        SD2Distrib = 'Uniform';
        
        SDr2Mean =0; % S.ProtocolSettings.Stim2DurationMean;
        SDr2Min =0; % S.ProtocolSettings.Stim2DurationMin;
        SDr2Max =0; %S.ProtocolSettings.Stim2DurationMax;
        SDr2Distrib  = 'Uniform';        
 
        RDMean = S.ProtocolSettings.RewardDelayMean;
        RDMin = S.ProtocolSettings.RewardDelayMin;
        RDMax =S.ProtocolSettings.RewardDelayMax;
        RDDistrib =S.ProtocolSettings.RDDistrib;
      
      Found = 0;
        while Found == 0
            switch IDDistrib
                case 'Exp'
                    IDCandidate = Joshexprnd(IDMean);
                case 'Uniform'
                    IDCandidate = rand*IDMean;
                case 'Norm'
                    %AGV see other note.
                    IDCandidate = randn+IDMean;
            end
            if (IDCandidate < IDMax) && (IDCandidate > IDMin)
                Found = 1;
            end
            if (IDMean == IDMax) && (IDMin == IDMean)
                IDCandidate = IDMean;
                Found = 1;
            end
        end
        S.TrialParams.InitialDelays(z) = IDCandidate;
        
     Found = 0;
        while Found == 0
            switch SD1Distrib
                case 'Exp'
                    SD1Candidate = Joshexprnd(SD1Mean);
                case 'Uniform'
                    SD1Candidate = rand*SD1Mean;
                case 'Norm'
                    %agv - this seems off, as over small ranges (0.1 -
                    %0.3s, say) this will effectively be a uniform
                    %distribution.
                    SD1Candidate = randn+SD1Mean;
            end
            if (SD1Candidate < SD1Max) && (SD1Candidate > SD1Min)
                Found = 1;
            end
            if (SD1Mean == SD1Max) && (SD1Min == SD1Mean)
                SD1Candidate = SD1Mean;
                Found = 1;
            end
        end
        S.TrialParams.Stimulus1Delays(z) = SD1Candidate;
        Found = 0;
        while Found == 0
            switch SDr1Distrib
                case 'Exp'
                    SDr1Candidate = Joshexprnd(SDr1Mean);
                case 'Uniform'
                    SDr1Candidate = rand*SDr1Mean;
                case 'Norm'
                    %AGV see other note.
                    SDr1Candidate = randn+SDr1Mean;
            end
            if (SDr1Candidate < SDr1Max) && (SDr1Candidate > SDr1Min)
                Found = 1;
            end
            if (SDr1Mean == SDr1Max) && (SDr1Min == SDr1Mean)
                SDr1Candidate = SDr1Mean;
                Found = 1;
            end
        end
        S.TrialParams.Stimulus1Durations(z) = SDr1Candidate;
        
        Found = 0;
        while Found == 0
            switch ISDDistrib
                case 'Exp'
                    ISDCandidate = Joshexprnd(ISDMean);
                case 'Uniform'
                    ISDCandidate = rand*ISDMean;
                case 'Norm'
                    %AGV see other note.
                    ISDCandidate = randn+ISDMean;
            end
            if (ISDCandidate < ISDMax) && (ISDCandidate > ISDMin)
                Found = 1;
            end
            if (ISDMean == ISDMax) && (ISDMin == ISDMean)
                ISDCandidate = ISDMean;
                Found = 1;
            end
        end
        S.TrialParams.InterStimDelays(z, 1) = ISDCandidate;
        Found = 0;
        while Found == 0
            switch SD2Distrib
                case 'Exp'
                    SD2Candidate = Joshexprnd(SD2Mean);
                case 'Uniform'
                    SD2Candidate = rand*SD2Mean;
                case 'Norm'
                    %AGV see other note.
                    SD2Candidate = randn+SD2Mean;
            end
            if (SD2Candidate < SD2Max) && (SD2Candidate > SD2Min)
                Found = 1;
            end
            if (SD2Mean == SD2Max) && (SD2Min == SD2Mean)
                SD2Candidate = SD2Mean;
                Found = 1;
            end
        end
        S.TrialParams.Stimulus2Delays(z) = SD2Candidate;
        Found = 0;
        while Found == 0
            switch SDr2Distrib
                case 'Exp'
                    SDr2Candidate = Joshexprnd(SDr2Mean);
                case 'Uniform'
                    SDr2Candidate = rand*SDr2Mean;
                case 'Norm'
                    %AGV see other note.
                    SDr2Candidate = randn+SDr2Mean;
            end
            if (SDr2Candidate < SDr2Max) && (SDr2Candidate > SDr2Min)
                Found = 1;
            end
            if (SDr2Mean == SDr2Max) && (SDr2Min == SDr2Mean)
                SDr2Candidate = SDr2Mean;
                Found = 1;
            end
        end
        S.TrialParams.Stimulus2Durations(z) = SDr2Candidate;
        
        Found = 0;
        while Found == 0
            switch RDDistrib
                case 'Exp'
                    RDCandidate = Joshexprnd(RDMean);
                case 'Uniform'
                    RDCandidate = rand*RDMean;
                case 'Norm'
                    %AGV see other note.
                    RDCandidate = randn+RDMean;
            end
            if (RDCandidate < RDMax) && (RDCandidate > RDMin)
                Found = 1;
            end
            if (RDMax == RDMin) && (RDMean == RDMin)
                RDCandidate = RDMean;
                Found = 1;
            end
        end
        S.TrialParams.RewardDelays(z) = RDCandidate;
    end
    
end



function Number = Joshexprnd(Mean)
    Number = -1*Mean*log(rand);
end
