%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function Olfactory2AFCaj
% This protocol demonstrates control of the Island Motion olfactometer by using the hardware serial port to control an Arduino Leonardo Ethernet client. 
% Written by Josh Sanders, 10/2014.
%
% SETUP
% You will need:
% - An Island Motion olfactometer: http://island-motion.com/5.html
% - Arduino Leonardo double-stacked with the Arduino Ethernet shield and the Bpod shield
% - This computer connected to the olfactometer's Ethernet router
% - The Ethernet shield connected to the same router
% - Arduino Leonardo connected to this computer (note its COM port)
% - Arduino Leonardo programmed with the Serial Ethernet firmware (in /Bpod Firmware/SerialEthernetModule/)

global BpodSystem

%% Define parameters
    S.ProtocolSettings = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
  % set TrialParams  
    S = JHsetupTrialParams3(S);
  
%% GUI    
%     S.GUI.Weight = 0;
%     S.GUI.EasyTrialNum = 40;
%     S.GUI.RewardAmount = 25;
%     S.GUI.Corrpara = 0; % correction parameter
% 
%     % Initialize parameter GUI plugin
%     BpodParameterGUI('init', S);
    BpodSystem.Data = S;
%% Initialize plots

% BpodSystem.GUIHandles.LiveDispFig = figure('Position',[425 200 1000 600],'name','Live session display','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off', 'CloseRequestFcn', 'ClearProtocol; delete(BpodSystem.GUIHandles.LiveDispFig);');
BpodSystem.GUIHandles.LiveDispFig = figure('Position',[425 200 1000 600],'name','Live session display','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
BG = imread('LiveSessionDataBG.bmp');
image(BG); axis off;

% BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .65 0.9 0.25]);
BpodSystem.GUIHandles.LivePlot1 = axes('position',[.07  .23  .42  .375], 'TickDir', 'out', 'YColor', [1 1 1], 'XColor', [1 1 1]);
BpodSystem.GUIHandles.LivePlot2 = axes('position',[.56  .23  .42  .375], 'TickDir', 'out', 'YColor', [1 1 1], 'XColor', [1 1 1]);
pause(0.5)
BpodSystem.GUIHandles.ProtocolNameDisplay = uicontrol('Style', 'text', 'String', 'DelayMatchToSample2', 'Position', [170 67 175 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.45 .45 .45]);
BpodSystem.GUIHandles.SubjectNameDisplay = uicontrol('Style', 'text', 'String', 'Einstein', 'Position', [170 40 175 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.45 .45 .45]);
BpodSystem.GUIHandles.starttime = uicontrol('Style', 'text', 'String', 'MainPhase', 'Position', [170 13 175 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.45 .45 .45]);
BpodSystem.GUIHandles.TrialNumberDisplay = uicontrol('Style', 'text', 'String', '1', 'Position', [520 67 105 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.44 .44 .44]);
BpodSystem.GUIHandles.TrialNumberDisplay = uicontrol('Style', 'text', 'String', '1', 'Position', [520 67 105 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.44 .44 .44]);
BpodSystem.GUIHandles.TrialTypeDisplay = uicontrol('Style', 'text', 'String', '1', 'Position', [520 40 105 18], 'FontWeight', 'bold', 'FontSize', 10, 'ForegroundColor', [1 1 1], 'BackgroundColor', [.44 .44 .44]);
Plot1Attribs = get(BpodSystem.GUIHandles.LivePlot1);
set(Plot1Attribs.Title, 'String', 'Live Plot 1', 'FontSize', 8, 'Color', 'w', 'FontName', 'arial', 'fontweight', 'bold');
Plot2Attribs = get(BpodSystem.GUIHandles.LivePlot2);
set(Plot2Attribs.Title, 'String', 'Live Plot 2', 'FontSize', 8, 'Color', 'w', 'FontName', 'arial', 'fontweight', 'bold');

OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init', S.TrialParams.LeftCorrect');

set(BpodSystem.GUIHandles.SubjectNameDisplay, 'String', S.animal);
set(BpodSystem.GUIHandles.ProtocolNameDisplay, 'String', S.sessionname);
set(BpodSystem.GUIHandles.starttime, 'String', S.starttime);


% BpodNotebook('init');

%% Initialize Ethernet client on hardware serial port 1 and connect to olfactometer

%% Define odors, program Ethernet server with commands for switching olfactometer valves
% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_Odor';

if ~BpodSystem.EmulatorMode
 SetCarrierFlowRate(900);
end

%% Main trial loop
MaxTrials = S.TrialParams.MaxTrials;
S.nStartedTrials = 1;
for x = 1:MaxTrials 
    S.x = x;
    if S.nStartedTrials>1
        nStartedTrials=S.currentTrial;
        currentTrial=nStartedTrials + x;
    else
        currentTrial=x;
    end
         
    S.currentTrial=currentTrial;
%     S = JHOverride_bpodV05 (S);
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

 % add state
    sma = JH_TrialParams2StateMatrix3(S);
 
 % send to bpod   
    SendStateMatrix(sma);
 
% Run!   
    RawTrialEvents = RunStateMatrix;
  
% save    
    if ~isempty(fieldnames(RawTrialEvents)) % If trial data was returned
        S.RawTrialEvents=RawTrialEvents;
        S.TE = addoldte_bpodv05(S);
        
        [path1 sessionname]=fileparts(BpodSystem.DataPath);
        [path2 junk]=fileparts(path1)
        [path3 task]=fileparts(path2)
        [junk animal]=fileparts(path3)
%         imagedir = fullfile(BpodSystem.DropboxPath, 'Images', animal)
%         imagepath=fullfile(imagedir, sessionname, '.jpg')
%         if ~exist(imagedir)
%             mkdir(imagedir)
%         end
%         export_fig sessionname
%      
% plot  
        S.sessionname=sessionname;
        S.animal=animal;
        S.task=task;
        BpodSystem.Data = S; 
 tic
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
toc
        UpdateOutcomePlot(S.TrialParams.StimulusID1,BpodSystem.Data);
        UpdatePshycoPlot(BpodSystem.Data);
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.currentTrial);
for x = 1:Data.currentTrial
    if (Data.TE.Rewarded(x))
        Outcomes(x) = 1;
    elseif (Data.TE.Punished(x))
        Outcomes(x) = 0;
    else
        Outcomes(x) = 3;
    end
end
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.currentTrial+1,mod(TrialTypes, 2)',Outcomes)
    try 
    set(BpodSystem.GUIHandles.TrialNumberDisplay, 'String', num2str(Data.currentTrial));
    set(BpodSystem.GUIHandles.TrialTypeDisplay, 'String', num2str(TrialTypes));    
    catch error 
    end

function UpdatePshycoPlot(S)
global BpodSystem
% jh plot
LivePlot1 = BpodSystem.GUIHandles.LivePlot1; 
LivePlot2 = BpodSystem.GUIHandles.LivePlot2;

S.TE.OdorRatio_trialtypes=S.OdorRatio_trialtypes;
S.TE.OdorRatio=S.OdorRatio;

subplot(LivePlot1)
biasplot(S.TE, LivePlot1);  

% Timecourse plot

subplot(LivePlot2)
timecourseplot(S.TE, LivePlot2)

