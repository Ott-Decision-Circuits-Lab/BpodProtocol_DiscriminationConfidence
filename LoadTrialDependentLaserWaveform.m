function LoadTrialDependentLaserWaveform(Player)

global BpodSystem
global TaskParameters

if ~BpodSystem.EmulatorMode
        % load Laser waveforms
        fs = Player.SamplingRate;
        
        if strcmpi(TaskParameters.GUIMeta.LaserColor.String{TaskParameters.GUI.LaserColor}, 'blue')
            LaserWaveform = GetLaserWaveform(fs);
            LaserWaveformIndex = 8;
            Player.loadWaveform(LaserWaveformIndex, LaserWaveform);
        elseif strcmpi(TaskParameters.GUIMeta.LaserColor.String{TaskParameters.GUI.LaserColor}, 'red')
            LaserWaveform = GetLaserWaveform(fs);
            LaserWaveformIndex = 9;
            Player.loadWaveform(LaserWaveformIndex, LaserWaveform);
        end
        
        StopWaveform = 0;
        StopWaveformIndex = 11;
        Player.loadWaveform(StopWaveformIndex, StopWaveform);
end

end %LoadTrialDependentLaserWaveform()