function biasplot(TE, handle)


% figure setting
lc=[0 0.5 1]; %Left block color
rc=[1 0.5 0]; %Right block color
color={'k', lc, rc};
%


% get stimulus information
    try OdorRatioMatrix=TE.Stimuli.OdorStimuli(:, 4);
        OdorRatio_trialtypes=nans(1, length(OdorRatioMatrix)-1);
        for i=2:length(OdorRatioMatrix);
            OdorRatio_trialtypes(i-1)=OdorRatioMatrix{i};
        end
    catch error
        OdorRatio_trialtypes=TE.OdorRatio_trialtypes;
    end
    
    [LeftOdorRatio ix]=sort(OdorRatio_trialtypes);

% get trial type and outcome list
    AttemptedTrialList=logical(TE.ResponseAttempted);
    %only analyze initial t
    if isfield(TE, 'Corrpara')
    AttemptedTrialList(TE.Corrpara==1)=0;
    end
    
    ResponseEventName=TE.ResponseEventName;
%     uname= unique(ResponseEventName); %JH 140502
%     if strcmp(uname(end), ['Port' LeftPort 'In'])
%             LeftResponse=(ismember(ResponseEventName, ['Port' LeftPort 'in'])==1); %Get Left response
%     else
            LeftResponse=(ismember(ResponseEventName, 'Lin')==1) %Get Left response
%     end
    OutcomeList = LeftResponse(AttemptedTrialList)
    TrialTypeList = TE.Stimulus1ID(AttemptedTrialList);

% get block list
    if isfield(TE, 'RewardOmissionBlock')
%     BiasBlockList=TE.RewardOmissionBlock(AttemptedTrialList);
        try BiasBlockList=TE.OriginalSessionParams.Reward_omissionBlock(AttemptedTrialList);
        catch error
            BiasBlockList=TE.RewardOmissionBlock(AttemptedTrialList);
        end
    NumBlock=length(unique(BiasBlockList));
    else
    BiasBlockList=zeros(size(OutcomeList));
    NumBlock=1;
    end
    
    % get delay list
    if isfield(TE, 'OriginalSessionParams.RewardDelays')
    minRDelay=num2str(min(TE.OriginalSessionParams.RewardDelays));
    meanRDelay=num2str(nanmean(TE.OriginalSessionParams.RewardDelays));
    maxRDelay=num2str(max(TE.OriginalSessionParams.RewardDelays));
    else
    minRDelay='0';
    meanRDelay='0';
    maxRDelay='0';  
    end
    
% Psychometric function plot

NumTrialType=length(LeftOdorRatio);
avDATA=nans(NumBlock, NumTrialType);
sdDATA=nans(NumBlock, NumTrialType);
for bl=0:NumBlock-1
    for type=1:NumTrialType
        blocktype=(BiasBlockList==bl);
        trialtype=(TrialTypeList == ix(type));
        avDATA(bl+1, type)=nanmean(OutcomeList(trialtype&blocktype));
        
        try sdDATA(bl+1, type)=nansem(OutcomeList(trialtype&blocktype));
        catch error 
            sdDATA(bl+1, type)= NaN;
        end
    end    
    ErrorPlot = errorbar(avDATA(bl+1, :), sdDATA(1,:), 'color', color{bl+1});
    hold on
    
end

% figure setting
if isfield(TE, 'Weight')
Weight=TE.Weight;
Wg= num2str(Weight);
else
Wg=0;
end

if isfield(TE, 'CorPro')
CorPro=TE.CorPro;
CP= num2str(CorPro);
else
CP=255;
end

if isfield(TE, 'Settings')
RewardAmount=TE.Settings.RewardAmount;
Rew= num2str(RewardAmount);
else
Rew=255;
end

if isfield(TE, 'EasyTrialNum')
EasyTrialNum=TE.EasyTrialNum(1);
ETN= num2str(EasyTrialNum);
else
ETN=255;
end

if isfield(TE, 'OriginalSessionParams')
PunishITI=TE.OriginalSessionParams.PunishITI(1);
PITI= num2str(PunishITI);
else
PITI=255;
end

if isfield(TE, 'RewSize')
RewSize=TE.RewSize;
Bias= num2str(RewSize);
else
Bias=255;
end

if isfield(TE, 'BiasProb')
BiasProb=TE.BiasProb;
Prob= num2str(BiasProb);
else
Prob=255;
end

info = ['Wg=' Wg ', CP=' CP ', Rew=' Rew ',Prob=' Prob ', BiasS=' Bias ', Delay=' maxRDelay];
% info = ['CP=' CP ', Rew=' Rew ', Punish= ' PITI ',Prob=' Prob ', BiasS=' Bias ', Delay=' maxRDelay];

title(info, 'fontsize', 11);
set(handle, 'XTick', 1:NumTrialType);
set(handle, 'XTickLabel', LeftOdorRatio);
set(handle,'Box','off')         
set(handle,'Tickdir','out'); 
ylim([0 1]);
xlim([0.5 NumTrialType+0.5]);

Plot2Attribs = get(handle);
set(Plot2Attribs.XLabel, 'String', 'Odor ratio(%Left)');
set(Plot2Attribs.YLabel, 'String', 'Left choice (%)');

l=legend( 'Contol', 'Left', 'Right', 'location', 'SouthEast');
set(l,'FontSize',12,'Color','w','XColor','w','YColor','w');

 hold off

