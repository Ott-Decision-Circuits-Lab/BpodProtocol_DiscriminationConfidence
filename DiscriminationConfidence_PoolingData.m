function DiscriminationConfidence_PoolingData()

dataFolder = 'C:\Users\emlon\Documents\ConsolidatedDocuments\Academic\Charité and ECN classes\Ott Lab\Ott Lab local data folder\Psilocybin vs PBS files DiscriminationConfidence\50\PBS';
sessionFiles = dir(strcat(dataFolder, '\*.mat')); % Struct with filename, folder, date, bytes, isdir, datenum

%% start looping to select SessionData as a cell array
DataHolder = {}; % Unprocessed cell that will lump together all individual SessionData

for iSession = 1:length(sessionFiles)

    sessionFileName = sessionFiles(iSession).name;
    sessionFullPath = fullfile(dataFolder, sessionFileName);
    
    load(sessionFullPath); % variable name will be 'SessionData'
    RatID = SessionData.Info.Subject;

    if SessionData.nTrials >= 50 && SessionData.SettingsFile.GUI.PercentCatch == 10 && SessionData.SettingsFile.GUI.FeedbackDelayGrace >= 0.2 && SessionData.SettingsFile.GUI.FeedbackDelayMax == 8 % Ensure that the session is valid (has many trials, and has the final settings of feedback delay)
        DataHolder{end+1} = SessionData; % Add session to DataHolder cell (1 x nSessions cell)
    end

end

dataHolderFilePath = fullfile(dataFolder, '\Selected_Data.mat'); % Create a filepath to ... 
save(dataHolderFilePath, 'DataHolder') % ... DataHolder cell
    
%% Concatenate SessionData into one single file

% ConcatenatedDataHolder is the pooled struct to be analyzed as 'SessionData'
ConcatenatedDataHolder.Info.Subject = num2str(RatID);
ConcatenatedDataHolder.Info.SessionDate = datetime('20000101', 'InputFormat', 'yyyyMMdd'); % temporary entry, later corrected
ConcatenatedDataHolder.nTrials = 0;
ConcatenatedDataHolder.SettingsFile.GUI = {};

ConcatenatedDataHolder.RawEvents.Trial = {};
ConcatenatedDataHolder.TrialStartTimestamp = [];
ConcatenatedDataHolder.TrialEndTimestamp = [];

% ConcatenatedTrialData is a struct with trial data, will be put into ConcatenatedDataHolder
ConcatenatedTrialData.ChoiceLeft = [];
ConcatenatedTrialData.DecisionVariable = [];
ConcatenatedTrialData.ChoiceCorrect = [];
ConcatenatedTrialData.NoDecision = [];
ConcatenatedTrialData.NoTrialStart = [];
ConcatenatedTrialData.FixBroke = [];
ConcatenatedTrialData.EarlyWithdrawal = [];
ConcatenatedTrialData.StartNewTrial = [];
ConcatenatedTrialData.SkippedFeedback = [];
ConcatenatedTrialData.Rewarded = [];

ConcatenatedTrialData.SampleLength = [];
ConcatenatedTrialData.CatchTrial = [];
ConcatenatedTrialData.Feedback = [];
ConcatenatedTrialData.Initiated = [];

ConcatenatedTrialData.MoveTime = [];
ConcatenatedTrialData.FeedbackTime = [];
ConcatenatedTrialData.RewardProb = [];
ConcatenatedTrialData.LightLeft = [];

ConcatenatedTrialData.BlockNumber = [];
ConcatenatedTrialData.BlockTrialNumber = [];
ConcatenatedTrialData.RewardMagnitude = [];

% for files before April 2023, no DrinkingTime is available
ConcatenatedTrialData.DrinkingTime = [];

% Fill pre-allocated fields, one session at a time
for iSession = 1:length(DataHolder)

    % Assign trial data for this iteration
    nTrials = DataHolder{iSession}.nTrials;
    ConcatenatedDataHolder.nTrials = ConcatenatedDataHolder.nTrials + nTrials;
    TrialData = DataHolder{iSession}.Custom.TrialData;
    
    ConcatenatedTrialData.ChoiceLeft = [ConcatenatedTrialData.ChoiceLeft, TrialData.ChoiceLeft(1:nTrials)];
    ConcatenatedTrialData.DecisionVariable = [ConcatenatedTrialData.DecisionVariable, TrialData.DecisionVariable(1:nTrials)];
    ConcatenatedTrialData.ChoiceCorrect = [ConcatenatedTrialData.ChoiceCorrect, TrialData.ChoiceCorrect(1:nTrials)];
    ConcatenatedTrialData.FixBroke = [ConcatenatedTrialData.FixBroke, TrialData.FixBroke(1:nTrials)];
    ConcatenatedTrialData.EarlyWithdrawal = [ConcatenatedTrialData.EarlyWithdrawal, TrialData.EarlyWithdrawal(1:nTrials)];
    ConcatenatedTrialData.Rewarded = [ConcatenatedTrialData.Rewarded, TrialData.Rewarded(1:nTrials)];
    
    ConcatenatedTrialData.SampleLength = [ConcatenatedTrialData.SampleLength, TrialData.SampleLength(1:nTrials)];
    ConcatenatedTrialData.CatchTrial = [ConcatenatedTrialData.CatchTrial, TrialData.CatchTrial(1:nTrials)];
    ConcatenatedTrialData.Feedback = [ConcatenatedTrialData.Feedback, TrialData.Feedback(1:nTrials)];
    ConcatenatedTrialData.Initiated = [ConcatenatedTrialData.Initiated, TrialData.Initiated(1:nTrials)];

    ConcatenatedTrialData.MoveTime = [ConcatenatedTrialData.MoveTime, TrialData.MoveTime(1:nTrials)];
    ConcatenatedTrialData.FeedbackTime = [ConcatenatedTrialData.FeedbackTime, TrialData.FeedbackTime(1:nTrials)];
    
    % for files before April 2023, no DrinkingTime is available
    try
        ConcatenatedTrialData.DrinkingTime = [ConcatenatedTrialData.DrinkingTime, TrialData.DrinkingTime(1:nTrials)];
    catch
        ConcatenatedTrialData.DrinkingTime = [ConcatenatedTrialData.DrinkingTime, nan(1, nTrials)];
    end
    
    ConcatenatedDataHolder.RawEvents.Trial = [ConcatenatedDataHolder.RawEvents.Trial, DataHolder{iSession}.RawEvents.Trial];
    ConcatenatedDataHolder.TrialStartTimestamp = [ConcatenatedDataHolder.TrialStartTimestamp, DataHolder{iSession}.TrialStartTimestamp(:, 1:nTrials)];
    ConcatenatedDataHolder.TrialEndTimestamp = [ConcatenatedDataHolder.TrialEndTimestamp, DataHolder{iSession}.TrialEndTimestamp(:, 1:nTrials)];
end
ConcatenatedDataHolder.Custom.TrialData = ConcatenatedTrialData; % Add concatenated trial data to ConcatenatedDataHolder
ConcatenatedDataHolder.SettingsFile = DataHolder{iSession}.SettingsFile; % Assumes settings files are identical

% HARD CODED:Artificially extend block length to ensure that no reward bias blocks get unduly inserted
ConcatenatedDataHolder.SettingsFile.GUI.BlockTable.BlockLen = ConcatenatedDataHolder.SettingsFile.GUI.BlockTable.BlockLen*10;

SessionData = ConcatenatedDataHolder;
ConcatenatedDataFilePath = fullfile(dataFolder, 'Concatenated_Data.mat');
save(ConcatenatedDataFilePath, 'SessionData')

% FigHandle = Analysis(ConcatenatedDataFilePath);
% saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.fig'))
% saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.png'))
    