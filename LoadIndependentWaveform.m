function LoadIndependentWaveform(Player)
% global Player
global BpodSystem
global TaskParameters

fs = Player.SamplingRate;

if TaskParameters.GUI.TimeOutEarlyWithdrawal > 0
    PunishSound = rand(1, fs*TaskParameters.GUI.TimeOutEarlyWithdrawal)*2 - 1;
    SoundIndex = 1;
    try
        if BpodSystem.Data.Custom.SessionMeta.PlayerType=="HiFi"
            Player.load(SoundIndex, PunishSound);
        elseif BpodSystem.Data.Custom.SessionMeta.PlayerType=="Analog"
            Player.loadWaveform(SoundIndex, PunishSound);
        end
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
            
        if BpodSystem.Data.Custom.SessionMeta.PlayerType=="HiFi"
            Player.load(SoundIndex, ErrorSound);
        elseif BpodSystem.Data.Custom.SessionMeta.PlayerType=="Analog"
            Player.loadWaveform(SoundIndex, ErrorSound);
        end
    catch
        fprintf('Error: IncorrectChoice sound not loaded.\n');
    end
end 

end