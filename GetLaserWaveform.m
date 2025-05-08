function LaserWaveform = GetLaserWaveform(SamplingRate)

global TaskParameters
global BpodSystem

if nargin<1
    SamplingRate = 30000; % in Hz
end

Amplitude = TaskParameters.GUI.LaserAmp;
StimulationFreq = TaskParameters.GUI.LaserStimFreq;
PulseDuration = TaskParameters.GUI.LaserPulseDuration_ms;
TrainDuration = TaskParameters.GUI.LaserTrainDuration_ms;
RampDuration = TaskParameters.GUI.LaserRampDuration_ms;     % Ramp not implemented
RandomTrainStart = TaskParameters.GUI.LaserTrainRandStart;  %True-False argument   % Random start not implemented
MinimumTrainStart = TaskParameters.GUI.LaserTrainStartMin_s; %if RandomTrainStart=True, minimum number of s post trigger, where train can randomly start
MaximumTrainStart = TaskParameters.GUI.LaserTrainStartMax_s; %if RandomTrainStart=True, maximum number of s post trigger, where train can randomly start

Period = 1/StimulationFreq;
t = 0:1/SamplingRate:TrainDuration;
numPulses = floor(TrainDuration/Period);
delays = (0:numPulses-1)*Period;

% Generate pulse train
pulse = @(t) rectpuls(t-PulseDuration/2, PulseDuration); % Centered rectangular pulse
LaserWaveform = Amplitude * pulstran(t', [delays' ones(numPulses,1)], pulse, fs);

end