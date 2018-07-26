function ParameterMatrix = configurePulsePalLaser(PulsePalMatrix)
%configure channel 3+4 of PulsePal configuration Matrix to play laser
%stimulus according to settings

global TaskParameters

OutputChannels = [3,4];

ParameterMatrix = PulsePalMatrix;
StimFreq = TaskParameters.GUI.LaserStimFreq;

if StimFreq == 0 %special case: continuous stimulation
    %Inter-pulse interval
    ParameterMatrix(8,OutputChannels+1)={0};
    %single pulse duration
    ParameterMatrix(5,OutputChannels+1)={10};
else
    %Inter-pulse interval
    ParameterMatrix(8,OutputChannels+1)={1./StimFreq - TaskParameters.GUI.LaserPulseDuration_ms/1000};
    %single pulse duration
    ParameterMatrix(5,OutputChannels+1)={TaskParameters.GUI.LaserPulseDuration_ms/1000};
end

%Burst Duration
ParameterMatrix(9,OutputChannels+1)={10};
%stimulus train duration
ParameterMatrix(11,OutputChannels+1)={10};