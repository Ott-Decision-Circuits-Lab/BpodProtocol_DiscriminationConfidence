function LoadIndependentWaveform(Player)
% global Player
global TaskParameters

fs = Player.SamplingRate;

PunishSound = rand(1, fs*TaskParameters.GUI.TimeOutEarlyWithdrawal)*2 - 1;
SoundIndex = 1;
try
    Player.loadWaveform(SoundIndex, PunishSound);
catch
    fprintf('Error: Punish Sound not loaded, probably TimeOutEarlyWithdrawal set as 0.');
end

SoundLevel = 0.8;
ErrorSound = rand(1, fs*TaskParameters.GUI.TimeOutIncorrectChoice)*2 - 1; 
% ErrorSound = ErrorSound * SoundLevel;
SoundIndex = 2;
try
    Player.loadWaveform(SoundIndex, ErrorSound);
catch
    fprintf('Error: Error Sound not loaded, probably TimeOutIncorrectChoice set as 0.');
end

end