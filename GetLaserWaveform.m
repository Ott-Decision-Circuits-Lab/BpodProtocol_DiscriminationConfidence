function LaserWaveform = GetLaserWaveform(SamplingRate)

global TaskParameters
global BpodSystem

if nargin<1
    SamplingRate = 10000; % in Hz <- max fs for laser is 30k but we use 10k so that it's easier to calculate the waveform
end

Amplitude = TaskParameters.GUI.LaserAmp;
StimulationFreq = TaskParameters.GUI.LaserStimFreq;
PulseDuration = TaskParameters.GUI.LaserPulseDuration_ms / 1000; % so that now it is all in second
TrainDuration = TaskParameters.GUI.LaserTrainDuration_ms / 1000;
RampDuration = TaskParameters.GUI.LaserRampDuration_ms;     % Ramp not implemented
RandomTrainStart = TaskParameters.GUI.LaserTrainRandStart;  %True-False argument   % Random start not implemented
MinimumTrainStart = TaskParameters.GUI.LaserTrainStartMin_s; %if RandomTrainStart=True, minimum number of s post trigger, where train can randomly start
MaximumTrainStart = TaskParameters.GUI.LaserTrainStartMax_s; %if RandomTrainStart=True, maximum number of s post trigger, where train can randomly start

if strcmpi(TaskParameters.GUIMeta.LaserStimProtocol.String{TaskParameters.GUI.LaserStimProtocol}, 'Mainen')
    % e.g. 1s train of 50Hz with pulse duration 10ms
    Period = 1/StimulationFreq; % Period = 1/50Hz = 0.02s
    t = 0:1/SamplingRate:TrainDuration; %  t = 0:0.0001:1s (but GUI said in ms so wrong already)
    numPulses = floor(TrainDuration/Period); % TrainDuration in ms or s?
    delays = (0:numPulses-1)*Period; % I guess this tries to get the of-set time of a pulse

    % Generate pulse train
    pulse = @(t) rectpuls(t-PulseDuration/2, PulseDuration); % Centered rectangular pulse <- shape of one pulse
    LaserWaveform = Amplitude * pulstran(t', [delays' ones(numPulses,1)], pulse); % unnecessary input for funciton

elseif strcmpi(TaskParameters.GUIMeta.LaserStimProtocol.String{TaskParameters.GUI.LaserStimProtocol}, 'Doya') 
    LaserWaveform = 1;  % in Doya condition, laser is continuously on during stim period, is this syntax correct?
end

LaserWaveform = repmat(LaserWaveform, 5, 1); % <- make 5 copies in rows
LaserWaveform = reshape(LaserWaveform, 1, []); % <- reshape it so that now one step becomes five steps
end