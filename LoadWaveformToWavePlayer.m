function LoadWaveformToWavePlayer(iTrial, ClickLength, SoundLevel)
global BpodSystem
global TaskParameters

if nargin < 3
    SoundLevel = 0.8;
end

if nargin < 2
    ClickLength = 1; % in sampling frame
end

if ~BpodSystem.EmulatorMode
    [Player, fs] = SetupWavePlayer();
    
    % load white noise
    PunishSound = rand(1, fs*TaskParameters.GUI.TimeOutEarlyWithdrawal)*2 - 1;
    SoundIndex = 1;
    Player.loadWaveform(SoundIndex, PunishSound);
    
    % load auditory stimuli
    %SoundChannels = [3];
    if BpodSystem.Data.Custom.TrialData.AuditoryTrial(iTrial) %auditory task
        if BpodSystem.Data.Custom.TrialData.ClickTask(iTrial) % click task    
            [LeftSound, RightSound] = GetClickStimulus(iTrial, TaskParameters.GUI.MinSampleAud, fs, ClickLength, SoundLevel, 'beta');
            
            SoundIndex = 2;
            Player.loadWaveform(SoundIndex, LeftSound);

            SoundIndex = 3;
            Player.loadWaveform(SoundIndex, RightSound);

        elseif TaskParameters.GUI.AuditoryStimulusType == 2 % freq task 
            Sound = GetFreqStimulus(iTrial, SoundLevel);
            
            SoundIndex = 2;
            Player.loadWaveform(SoundIndex, Sound);

        end

        % load error sound
        ErrorSound = 1 * SoundLevel;
        SoundIndex = 4;
        Player.loadWaveform(SoundIndex, ErrorSound);

        %SoundChannels = [3 1 2 3];  % Array of channels for each sound: play on left (1), right (2), or both (3)
    end
    %Player.Waveforms;
    %LoadSoundMessages(SoundChannels);
    trigger_matrix = Player.TriggerProfiles; %TriggerProfiles should be of 64 x nChannel
    trigger_matrix(1, 1:2) = 1; %first trigger profile: white noise (sound index: 1) on both channel
    trigger_matrix(2, 1) = 2; %second trigger profile: left sound (sound index:2) on left channel
    trigger_matrix(3, 2) = 3; %third trigger profile: right sound (sound index:3) on right channel
    trigger_matrix(4, 1:2) = [2 3]; %fourth profile: combination of second and third profile
    trigger_matrix(5, 1:2) = 4;
    Player.TriggerProfiles = trigger_matrix;
end
end