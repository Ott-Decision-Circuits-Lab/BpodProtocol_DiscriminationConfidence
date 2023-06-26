function [photometryData,photometry2Data]=Nidaq_photometry(action)
global nidaq TaskParameters

switch action
    case 'ini'
%% NIDAQ Initialization
% Define parameters for analog inputs and outputs.
nidaq.device            = TaskParameters.GUI.nidaqDev;
nidaq.duration      	= TaskParameters.GUI.NidaqDuration;
nidaq.sample_rate     	= TaskParameters.GUI.NidaqSamplingRate;
nidaq.ai_channels       = {'ai0','ai1'};           % photodetectors (green and red)
nidaq.ai_data           = [];
nidaq.ao_channels       = {'ao0','ao1'};           % LED1 and LED2
nidaq.ao_data           = [];

% for the doric minicube:
% ai0: green photodetector (F1)
% ai1: red photodetector (F2)
% ao0: "LED1", is blue (470nm) LED
% ao1: "LED2", is either yellow (535nm) LED or UV (405nm) LED
% there are only 2 ao channels on our NIDAQ card.
% isosbestic is currently coded as LED2
    % main limitation is that it needs to be driven at a different
    % frequency than the green LED, and so it needs to be on a different
    % ao. but then the red LED won't be able to be on a separate frequency.
    % this may not be a huge problem, but it's the sacrifice made.


daq.reset
daq.HardwareInfo.getInstance('DisableReferenceClockSynchronization',true); % Necessary for this Nidaq

%create nidaq session
nidaq.session = daq.createSession('ni');

% For the photometry - Photoreceiver + LEDs
for ch = nidaq.ai_channels
    nch=addAnalogInputChannel(nidaq.session,nidaq.device,ch,'Voltage');
    nch.TerminalConfig='SingleEnded';
end
for ch = nidaq.ao_channels
    nch=addAnalogOutputChannel(nidaq.session,nidaq.device,ch,'Voltage');
    nch.TerminalConfig='SingleEnded';
end


% Sampling rate
nidaq.session.Rate = nidaq.sample_rate;
nidaq.session.IsContinuous = false;
lh{1} = nidaq.session.addlistener('DataAvailable',@Nidaq_callback);

    case 'WaitToStart'
%% GET NIDAQ READY TO RECORD
nidaq.ai_data            = [];
if TaskParameters.GUI.Photometry
    nidaq.LED1              = Nidaq_modulation(TaskParameters.GUI.LED1_Amp,TaskParameters.GUI.LED1_Freq);
    nidaq.LED2              = Nidaq_modulation(0,TaskParameters.GUI.LED1_Freq);
if TaskParameters.GUI.Isobestic405 || TaskParameters.GUI.RedChannel
    nidaq.LED2              = Nidaq_modulation(TaskParameters.GUI.LED2_Amp,TaskParameters.GUI.LED2_Freq);
end
if TaskParameters.GUI.DbleFibers
    nidaq.LED2              = Nidaq_modulation(TaskParameters.GUI.LED1b_Amp,TaskParameters.GUI.LED1b_Freq);
end
else
    nidaq.LED1              = Nidaq_modulation(0,TaskParameters.GUI.LED1_Freq);
    nidaq.LED2              = Nidaq_modulation(0,TaskParameters.GUI.LED1_Freq);
end
nidaq.ao_data           = [nidaq.LED1 nidaq.LED2];

nidaq.session.queueOutputData(nidaq.ao_data);
nidaq.session.NotifyWhenDataAvailableExceeds = nidaq.sample_rate/5;
nidaq.session.prepare();
nidaq.session.startBackground();

    case 'Stop'
%% STOP NIDAQ
    nidaq.session.stop()
    wait(nidaq.session) % Wait until nidaq session stop
    nidaq.session.outputSingleScan(zeros(1,length(nidaq.ao_channels))); % drop output back to 0 
    case 'Save'
%% Save Data
photometryData=[];
photometry2Data=[];
wheelData=[];

% reallocates raw data
if TaskParameters.GUI.Photometry
    photometryData = nidaq.ai_data(:,1);
    if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
        photometry2Data = nidaq.ai_data(:,2);
    end
end

% saves output channels for photometry
if TaskParameters.GUI.Photometry
    if TaskParameters.GUI.Modulation
        if TaskParameters.GUI.RedChannel & TaskParameters.GUI.Isobestic405
            photometryData  = [photometryData  nidaq.ao_data(1:size(photometryData,1),:)];
            photometry2Data = [photometry2Data nidaq.ao_data(1:size(photometry2Data,1),2)];
        elseif TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
            photometryData  = [photometryData  nidaq.ao_data(1:size(photometryData,1),1)];
            photometry2Data = [photometry2Data nidaq.ao_data(1:size(photometry2Data,1),2)];
        elseif TaskParameters.GUI.Isobestic405
            photometryData  = [photometryData  nidaq.ao_data(1:size(photometryData,1),:)];
        else
            photometryData  = [photometryData  nidaq.ao_data(1:size(photometryData,1),1)];
        end
    end
end
end  
end     