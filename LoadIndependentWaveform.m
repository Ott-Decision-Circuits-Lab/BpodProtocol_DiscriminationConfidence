function LoadIndependentWaveform(Player)
% global Player
global TaskParameters

fs = Player.SamplingRate;

if TaskParameters.GUI.TimeOutEarlyWithdrawal > 0
    PunishSound = rand(1, fs*3)*2 - 1;
    SoundIndex = 1;
    try
        Player.loadWaveform(SoundIndex, PunishSound);
    catch
        fprintf('Error: Punish sound not loaded.\n');
    end
end

if TaskParameters.GUI.TimeOutIncorrectChoice > 0
    SoundLevel = 0.8;
    ErrorSound = rand(1, fs*TaskParameters.GUI.TimeOutIncorrectChoice)*2 - 1; 
    % ErrorSound = ErrorSound * SoundLevel;
    SoundIndex = 2;
    try
        Player.loadWaveform(SoundIndex, ErrorSound);
    catch
        fprintf('Error: IncorrectChoice sound not loaded.\n');
    end
end 

if TaskParameters.GUI.SkippedFeedbackFeedbackType == 2
     t = linspace(0, 1, fs/3);  % Time vector
    SkipSound = cos(2 * pi * 440 * t);  % Cosine wave between -1 and 1
    SoundIndex = 5;
    try
        Player.loadWaveform(SoundIndex, SkipSound);
    catch
        fprintf('Error: SkippedFeedback beep sound not loaded.\n');
    end
end




end

