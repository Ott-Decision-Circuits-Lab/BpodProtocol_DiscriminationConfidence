function LoadTrialDependentLaserWaveform(Player, LaserColor)

global BpodSystem
global TaskParameters

if ~BpodSystem.EmulatorMode
    if nargin <2
        LaserColor = blue;
    end

    % load Laser waveforms
    fs = Player.SamplingRate;
  
    if strcmpi(LaserColor, 'blue')
        LaserWaveform = GetLaserWaveform(fs);
        LaserWaveformIndex = 7;
        Player.loadWaveform(LaserWaveformIndex, LaserWaveform);
    elseif strcmpi(LaserColor, 'red')
        LaserWaveform = GetLaserWaveform(fs);
        LaserWaveformIndex = 8;
        Player.loadWaveform(LaserWaveformIndex, LaserWaveform);
    end

    StopWaveform = 0;
    StopWaveformIndex = 11;
    Player.loadWaveform(StopWaveformIndex, StopWaveform);

end

end %LoadTrialDependentWaveform()