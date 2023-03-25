function LoadTrialDependentWaveform(Player, iTrial, SoundLevel, ClickLength)

global BpodSystem
global TaskParameters

if ~BpodSystem.EmulatorMode
    if nargin <3
        SoundLevel = 1;
    end
    
    if nargin <4
        ClickLength = 2; % in sampling frame
    end

    % load auditory stimuli
    fs = Player.SamplingRate;
    
    if TaskParameters.GUI.AuditoryStimulusType == 1 % click task
        [LeftClickTrain, RightClickTrain] = GetClickStimulus(iTrial, TaskParameters.GUI.AuditoryStimulusTime, fs, ClickLength, SoundLevel, 'beta');

        LeftSoundIndex = 3;
        Player.loadWaveform(LeftSoundIndex, LeftClickTrain);

        RightSoundIndex = 4;
        Player.loadWaveform(RightSoundIndex, RightClickTrain);
    elseif TaskParameters.GUI.AuditoryStimulusType == 2 % freq task
        warning('Error: Frequency stimulus has not been implemented.');
    end
end

end %LoadTrialDependentWaveform()