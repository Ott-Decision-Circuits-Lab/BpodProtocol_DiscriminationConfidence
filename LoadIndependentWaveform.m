function LoadIndependentWaveform(Player)
% global Player
global TaskParameters

fs = Player.SamplingRate;

if TaskParameters.GUI.TimeOutEarlyWithdrawal > 0
    PunishSound = rand(1, fs*TaskParameters.GUI.TimeOutEarlyWithdrawal)*2 - 1;
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

end