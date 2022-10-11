function Dual2AFC
% 2-AFC olfactory and auditory discrimination task implented for Bpod fork https://github.com/KepecsLab/bpod
% This project is available on https://github.com/KepecsLab/BpodProtocols_Olf2AFC/

global BpodSystem
global nidaq
global TaskParameters

TaskParameters = GUISetup();  % Set experiment parameters in GUISetup.m

InitializeCustomDataFields(); % Initialize data (trial type) vectors and first values

% ------------------------Setup Stimuli--------------------------------%
if ~BpodSystem.EmulatorMode
    [Player, fs] = SetupWavePlayer();
    PunishSound = rand(1, fs*.5)*2 - 1;  % white noise
    SoundIndex=1;
    Player.loadWaveform(SoundIndex, PunishSound);
    SoundChannels = [3];  % Array of channels for each sound: play on left (1), right (2), or both (3)
    LoadSoundMessages(SoundChannels);
end
% ---------------------------------------------------------------------%

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

% %server data
% [~,BpodSystem.Data.Custom.Rig] = system('hostname');
% [~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.Path.CurrentDataFile))));

%% Configuring PulsePal
% load PulsePalParamStimulus.mat
% load PulsePalParamFeedback.mat
% BpodSystem.Data.Custom.PulsePalParamStimulus=configurePulsePalLaser(PulsePalParamStimulus);
% BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
% clear PulsePalParamFeedback PulsePalParamStimulus
% if BpodSystem.Data.Custom.AuditoryTrial(1)
%    if ~BpodSystem.EmulatorMode
%     
%     if BpodSystem.Data.Custom.ClickTask(1) 
%         ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
%         SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
%         SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
%     else
%         InitiatePsychtoolbox(1);
%         PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.AudSound{1});
%         BpodSystem.Data.Custom.AudSound{1} = {};
%     end
%     end
% end

InitializePlots();


%% NIDAQ Initialization and Plots
if TaskParameters.GUI.Photometry
    [FigNidaq1,FigNidaq2]=InitializeNidaq();
end

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    InitiateOlfactometer(iTrial);
    InitiatePsychtoolbox(iTrial);
    
    %% send state matrix to Bpod
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    
    %% NIDAQ Get nidaq ready to start
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('WaitToStart');
    end
    
    %% Run Trial
    RawEvents = RunStateMatrix;
    
    %% NIDAQ Stop acquisition and save data in bpod structure
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('Stop');
        [PhotoData,Photo2Data]=Nidaq_photometry('Save');
        NidaqData=PhotoData;
        if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
            Nidaq2Data=Photo2Data;
        else
            Nidaq2Data=[];
        end
        % save separately per trial (too large/slow to save entire history to disk)
        if BpodSystem.BeingUsed~=0 %only when bpod still active (due to how bpod stops a protocol this would be run again after the last trial)
            if ~isdir(BpodSystem.DataPath(1:end-4)), mkdir(BpodSystem.DataPath(1:end-4)), end
            fname = fullfile(BpodSystem.DataPath(1:end-4),['NidaqData',num2str(iTrial),'.mat']);
            save(fname,'NidaqData','Nidaq2Data')
        end
    end
    
    %% Bpod save
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    
    %% pause conditions    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    
    if (BpodSystem.Data.TrialStartTimestamp(iTrial) - BpodSystem.Data.TrialStartTimestamp(1))/60 > TaskParameters.GUI.MaxSessionTime
        TaskParameters.GUI.MaxSessionTime = 1000;
        try
            Notify() % optional notify sript in your MATLAB path (not part of protocol)
        catch
        end
        RunProtocol('StartPause')
    end
    
    %% insert session description in protocol into data.info
    if iTrial == 1
        BpodSystem.Data.Info.SessionDescription = ["To teach the subject the nose poking sequence with correct timings"];
        BpodSystem.Data.Custom.General.SessionDescription = BpodSystem.Data.Info.SessionDescription;
    end

    % append session description in setting into data.info
    if TaskParameters.GUI.SessionDescription ~= BpodSystem.Data.Info.SessionDescription(end)
        BpodSystem.Data.Info.SessionDescription = [BpodSystem.Data.Info.SessionDescription, TaskParameters.GUI.SessionDescription];
        BpodSystem.Data.Custom.General.SessionDescription = BpodSystem.Data.Info.SessionDescription;
    end
    
    %% update custom data fields for this trial and draw future trials
    updateCustomDataFields(iTrial);
    SaveBpodSessionData();
    
    %% update behavior plots
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    %% update photometry plots
    if TaskParameters.GUI.Photometry
        PlotPhotometryData(FigNidaq1,FigNidaq2, PhotoData, Photo2Data);
    end
    
    iTrial = iTrial + 1;
    
end

%% photometry check
if TaskParameters.GUI.Photometry
    CheckPhotometry(PhotoData, Photo2Data);
end

end