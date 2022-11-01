function LoadIndependentWaveform(Player)
% global Player
global TaskParameters

fs = Player.SamplingRate;

PunishSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;
SoundIndex = 1;
Player.loadWaveform(SoundIndex, PunishSound);

SoundLevel = 0.8;
ErrorSound = 1 * SoundLevel;
SoundIndex = 2;
Player.loadWaveform(SoundIndex, ErrorSound);

end