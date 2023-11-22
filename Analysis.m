function FigHandle = Analysis(DataFile)
global TaskParameters


if nargin < 1
    global BpodSystem
    if isempty(BpodSystem)
        [datafile, datapath] = uigetfile();
        load(fullfile(datapath, datafile));
        GUISettings = SessionData.SettingsFile.GUI;
    else
        SessionData = BpodSystem.Data;
        GUISettings = TaskParameters.GUI;
    end
else
    load(DataFile);
    GUISettings = SessionData.SettingsFile.GUI;
end

GracePeriodsMax = GUISettings.FeedbackDelayGrace; %assumes same for each trial
StimTime = GUISettings.AuditoryStimulusTime; %assumes same for each trial

TaskType = GUISettings.FeedbackDelaySelection;

if TaskType == 1  % reward-bias task
    MinWT = 0;
    MaxWT = GUISettings.FeedbackDelayMax;
elseif TaskType == 3 % time-investment task
    MinWT = GUISettings.VevaiometricMinWT; %assumes same for each trial
    MaxWT = 10;
end

AudBin = 8; % Bins for psychometric
AudBinWT = 6; % Bins for vevaiometric
windowCTA = 150; % window for CTA (ms)

%[~,Animal ] = fileparts(fileparts(fileparts(fileparts(BpodSystem.Path.CurrentDataFile))));
Animal = str2double(SessionData.Info.Subject);
if isnan(Animal)
    Animal = -1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nTrials = SessionData.nTrials;
DV = SessionData.Custom.TrialData.DecisionVariable(1:nTrials-1);
ChoiceLeft = SessionData.Custom.TrialData.ChoiceLeft(1:nTrials-1);
ST = SessionData.Custom.TrialData.SampleLength(1:nTrials-1);
CatchTrial = SessionData.Custom.TrialData.CatchTrial((1:nTrials-1));
Feedback = SessionData.Custom.TrialData.Feedback(1:nTrials-1);
Correct = SessionData.Custom.TrialData.ChoiceCorrect(1:nTrials-1);
IncorrectChoice = [];
for l = 1 : length(Correct)
    if Correct(l) == 1 
        IncorrectChoice(l) = 0;
    elseif Correct(l) == 0
        IncorrectChoice(l) = 1;
    else 
        IncorrectChoice(l) = NaN;
    end
end

StartNewTrial = SessionData.Custom.TrialData.Initiated(1:nTrials-1);
NoTrialStart(:) = ~StartNewTrial;
Rewarded = SessionData.Custom.TrialData.Rewarded(1:nTrials-1);
BrokeFixation = SessionData.Custom.TrialData.FixBroke(1:nTrials-1);
EarlyWithdrawal = SessionData.Custom.TrialData.EarlyWithdrawal(1:nTrials-1);
SkippedFeedback = ~SessionData.Custom.TrialData.Feedback(1:nTrials-1);
WT =  SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1);
if isfield(SessionData.Custom,'LaserTrial')
    LaserTrial =  SessionData.Custom.TrialData.LaserTrial(1:nTrials-1);
else
    LaserTrial=false(1,nTrials-1);
end

scarlet = [254, 60, 60]/255; % for incorrect sign, contracting with azure
denim = [31, 54, 104]/255; % mainly for unsuccessful trials
azure = [0, 162, 254]/255; % for rewarded sign

neon_green = [26, 255, 26]/255; % for NotBaited
neon_purple = [168, 12, 180]/255; % for SkippedBaited

sand = [225, 190 106]/255; % for left-right
turquoise = [64, 176, 166]/255;

%define "completed trial"
% not that abvious for errors
%Correct vector is 1 for correct choice, 0 for incorrect choice, nan
%for no choice
%now: correct --> received feedback (reward)
%     error --> always (if error catch)
%     catch --> always (if choice happened)

CompletedTrials = (Feedback&Correct==1) | (Correct==0) | CatchTrial&~isnan(ChoiceLeft);
nTrialsCompleted = sum(CompletedTrials);

%calculate exerienced dv
ExperiencedDV=DV;

% %click task
% if TaskParameters.GUI.AuditoryStimulusType == 1 %click
%     LeftClickTrain = SessionData.Custom.TrialData.LeftClickTrain(1:nTrials-1);
%     RightClickTrain = SessionData.Custom.TrialData.RightClickTrain(1:nTrials-1);
%     for t = 1 : length(ST)
%         R = SessionData.Custom.TrialData.RightClickTrain{t};
%         L = SessionData.Custom.TrialData.LeftClickTrain{t};SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)SessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)
%         Ri = sum(R<=ST(t));if Ri==0, Ri=1; end
%         Li = sum(L<=ST(t));if Li==0, Li=1; end
%         ExperiencedDV(t) = log10(Li/Ri);
%         %         ExperiencedDV(t) = (Li-Ri)./(Li+Ri);
%     endSessionData.Custom.TrialData.FeedbackTime(1:nTrials-1)
% elseif TaskParameters.GUI.AuditoryStimulusType == 2 %freq
% %     LevelsLow = 1:ceil(TaskParameters.GUI.Aud_nFreq/3);
% %     LevelsHigh = ceil(TaskParameters.GUI.Aud_nFreq*2/3)+1:TaskParameters.GUI.Aud_nFreq;
% %     AudCloud = SessionData.Custom.AudCloud(1:nTrials-1);
% %     for t = 1 : length(ST)
% %         NLow = sum(ismember(AudCloud{t},LevelsLow)); if NLow==0, NLow=1; end
% %         NHigh = sum(ismember(AudCloud{t},LevelsHigh)); if NHigh==0, NHigh=1; end
% %         ExperiencedDV(t) = log10(NHigh/NLow);
% %     end
% end

%caclulate  grace periods
GracePeriods=[];
GracePeriodsL=[];
GracePeriodsR=[];
for t = 1 : length(ST)
    GracePeriods = [GracePeriods;SessionData.RawEvents.Trial{t}.States.rewarded_Rin_grace(:,2)-SessionData.RawEvents.Trial{t}.States.rewarded_Rin_grace(:,1);SessionData.RawEvents.Trial{t}.States.rewarded_Lin_grace(:,2)-SessionData.RawEvents.Trial{t}.States.rewarded_Lin_grace(:,1)];
    if ChoiceLeft(t) == 1
        GracePeriodsL = [GracePeriodsL;SessionData.RawEvents.Trial{t}.States.rewarded_Lin_grace(:,2)-SessionData.RawEvents.Trial{t}.States.rewarded_Lin_grace(:,1)];
    elseif ChoiceLeft(t)==0
        GracePeriodsR = [GracePeriodsR;SessionData.RawEvents.Trial{t}.States.rewarded_Rin_grace(:,2)-SessionData.RawEvents.Trial{t}.States.rewarded_Rin_grace(:,1)];
    end
end


CompletedTrials = CompletedTrials==1;
CatchTrial = CatchTrial==1;

%laser trials?
if sum(LaserTrial)>0
    LaserCond = [false;true];
else
    LaserCond=false;
end
% CondColors={[0,0,0],[.9,.1,.1]};
CondColors = {'k', '#F7497A', '#1BA8D2', '#D4D1D1'};
CondStrings = {'Equal-1', '', '', 'Equal-2'};

%% ---------------------------------------------------------------------
%%                      Start Figure Creation
%% ---------------------------------------------------------------------
if TaskType==1
    FigPositionSize = [ 360         187        1500         600];
    nRows = 2;
    nCols = 3;
elseif TaskType==3
    if sum(CatchTrial)
        FigPositionSize = [ 360         187        1500         900];
        nRows = 3;
    else
        nRows = 2;
        FigPositionSize = [ 360         187        1500         600];
    end
    nCols = 3;
end
FigHandle = figure('Position', FigPositionSize, 'NumberTitle', 'off', ...
                   'Name', SessionData.Info.Subject);



%% ---------------------------------------------------------------------
%% Psychometric
%% ---------------------------------------------------------------------
subplot(nRows,nCols,4)
hold on

DVAxis = linspace(-1, 1, 21);
nBlocks = max(GUISettings.BlockTable.BlockNumber);
BlockIdx = [0; cumsum(GUISettings.BlockTable.BlockLen)];
for i = 1:nBlocks
    BlockBegin = BlockIdx(i) + 1;
    BlockEnd = BlockIdx(i+1);
    if BlockBegin < nTrials
        if BlockEnd > nTrials
            BlockEnd = nTrials - 1;
        end
        if i==1 | i>3
            LocalColor = CondColors{i};
        else
            if GUISettings.BlockTable.RewL(i) > GUISettings.BlockTable.RewR(i)
                LocalColor = CondColors{2};
                CondStrings{i} = 'L>R';
            else
                LocalColor = CondColors{3};
                CondStrings{i} = 'R>L';
            end
        end
        CompletedTrialsBlock = CompletedTrials(BlockBegin:BlockEnd);
        LeftChoicesBlock = ChoiceLeft(BlockBegin:BlockEnd);
        LeftChoicesBlock = LeftChoicesBlock(CompletedTrialsBlock);
        AudDV = ExperiencedDV(BlockBegin:BlockEnd);
        AudDV = AudDV(CompletedTrialsBlock);
        CorrectBlock = Correct(BlockBegin:BlockEnd);
        CorrectBlock = CorrectBlock(CompletedTrialsBlock);
        if ~isempty(AudDV)
            BinIdx = discretize(AudDV, DVAxis);

            PsycY = grpstats(LeftChoicesBlock, BinIdx, 'mean');
            PsycX = grpstats(AudDV, BinIdx, 'mean');
            plot(PsycX,PsycY,'ok','MarkerFaceColor', LocalColor, ...
                                  'MarkerEdgeColor', LocalColor, ...
                                  'MarkerSize', 6);
    
            XFit = linspace(min(AudDV)-10*eps, max(AudDV)+10*eps, 100);
            YFit = glmval(glmfit(AudDV, LeftChoicesBlock','binomial'),XFit,'logit');
            plot(XFit, YFit, 'Color', LocalColor, 'LineWidth', 2);
    
            xlabel('DV');
            ylabel('p left')
            
            text(0.95*min(get(gca,'XLim')),1-i*0.05, ...
                [num2str(round(nanmean(CorrectBlock)*100)), ...
                 '% Correct, nTrials=',num2str(sum(CompletedTrialsBlock))], ...
                 'Color', LocalColor);
        end
    end
end
legend('',CondStrings{1},'',CondStrings{2},'',CondStrings{3},'',CondStrings{4}, 'Location', 'southeast')


%% ---------------------------------------------------------------------
%% sampling time
%% ---------------------------------------------------------------------
% panel=subplot(nRows,nCols,2);
% hold on
% if sum(CompletedTrials)>1
%     center = linspace(min(ST(CompletedTrials)),max(ST(CompletedTrials)),15);
%     h=hist(ST(CompletedTrials),center);
%     if ~isempty(h)
%         h=h/sum(h);
%         % ylabel('p')
%         plot(abs(ExperiencedDV(CompletedTrials)),ST(CompletedTrials),'.k');
%         xlabel('DV');
%         ylabel('Sampling time [s]')
%         ylim([mean(ST(CompletedTrials)) - 0.0001, mean(ST(CompletedTrials)) + 0.0001]);
% 
%         ax2 = axes('Position',panel.Position);
%         panel.Position=ax2.Position;
%         plot(h,center,'r','LineWidth',2,'Parent',ax2);
%         ylim([mean(ST(CompletedTrials)) - 0.0001, mean(ST(CompletedTrials)) + 0.0001]);
%         yticks([]);
% 
%         ax2.YAxis.Visible='off';
%         ax2.XAxisLocation='top';
%         ax2.Color='none';
%         ax2.XAxis.FontSize = 8;
%         ax2.XAxis.Color=[1,0,0];
%         ax2.XLabel.String = 'p';
%         ax2.XLabel.Position=[0.15,3.1,0];
%         [r,p]=corr(abs(ExperiencedDV(CompletedTrials&~isnan(ST)))',ST(CompletedTrials&~isnan(ST))','type','Spearman');
%         text(min(get(gca,'XLim'))+0.05,max(get(gca,'YLim'))-0.00001,['r=',num2str(round(r*100)/100),', p=',num2str(round(p*100)/100)]);
%         
%     end
% end



%% ---------------------------------------------------------------------
%% grace periods
%% ---------------------------------------------------------------------
subplot(nRows,nCols,5)
%remove "full" grace periods
GracePeriods(GracePeriods>=GracePeriodsMax-0.001 & GracePeriods<=GracePeriodsMax+0.001 )=[];
GracePeriodsR(GracePeriodsR>=GracePeriodsMax-0.001 & GracePeriodsR<=GracePeriodsMax+0.001 )=[];
GracePeriodsL(GracePeriodsL>=GracePeriodsMax-0.001 & GracePeriodsL<=GracePeriodsMax+0.001 )=[];
center = 0:0.025:max(GracePeriods);
if ~all(isnan(GracePeriodsL)) && numel(center) > 1 && ~all(isnan(GracePeriodsR))
    g = hist(GracePeriods,center);g=g/sum(g);
    gl = hist(GracePeriodsL,center);gl=gl/sum(gl);
    gr = hist(GracePeriodsR,center);gr=gr/sum(gr);
    hold on
    plot(center,g,'k','LineWidth',2)
    plot(center,gl, 'Color', CondColors{2},'LineWidth',2)
    plot(center,gr, 'Color', CondColors{3},'LineWidth',2)
    legend('Both','Left','Right', 'Location', 'east')
    xlabel('Grace period (s)');ylabel('p');
    text(min(get(gca,'XLim'))+0.05,max(get(gca,'YLim'))-0.05,['n=',num2str(sum(~isnan(GracePeriods))),' (L=',num2str(sum(~isnan(GracePeriodsL))),'/R=',num2str(sum(~isnan(GracePeriodsR))),')']);
end



if TaskType==3
%% ---------------------------------------------------------------------
%% waiting time distributions
%% ---------------------------------------------------------------------
ColorsCond = {[.5,.5,.5],[.9,.1,.1]};
if length(LaserCond)==1
    %no laser
    subplot(nRows,nCols,6)
    hold on
    xlabel('waiting time (s)'); ylabel ('n trials');
    WTnoFeedbackL = WT(~Feedback & ChoiceLeft == 1);
    WTnoFeedbackR = WT(~Feedback & ChoiceLeft == 0);
    histogram(WTnoFeedbackL,10,'EdgeColor','none','FaceColor', CondColors{2});
    histogram(WTnoFeedbackR,10,'EdgeColor','none','FaceColor', CondColors{3});

    meanWTL = nanmean(WTnoFeedbackL);
    meanWTR = nanmean(WTnoFeedbackR);
    line([meanWTL,meanWTL],get(gca,'YLim'),'Color', CondColors{2});
    line([meanWTR,meanWTR],get(gca,'YLim'),'Color', CondColors{3});
    text(meanWTL-1,1.05*(max(get(gca,'YLim'))-min(get(gca,'YLim'))), ...
        ['m_l=',num2str(round(meanWTL*10)/10)],'Color', CondColors{2});
    text(meanWTL-1,1.15*(max(get(gca,'YLim'))-min(get(gca,'YLim'))), ...
        ['m_r=',num2str(round(meanWTR*10)/10)],'Color', CondColors{3});
    
    PshortWTL = sum(WTnoFeedbackL<MinWT)/sum(~isnan(WTnoFeedbackL));
    PshortWTR = sum(WTnoFeedbackR<MinWT)/sum(~isnan(WTnoFeedbackR));
    text(max(get(gca,'XLim'))+0.03,0.85*(max(get(gca,'YLim'))-min(get(gca,'YLim')))+min(get(gca,'YLim')),['L_{2}=',num2str(round(PshortWTL*100)/100),', R_{2}=',num2str(round(PshortWTR*100)/100)],'Color',[0,0,0]);
    
% else%laser
%     subplot(3,4,7)
%     hold on
%     xlabel('waiting time (s)'); ylabel ('n trials');
%     subplot(3,4,8)
%     hold on
%     xlabel('waiting time (s)'); ylabel ('n trials');
%     PshortWTL=cell(1,2);PshortWTR=cell(1,2);
%     for i =1:length(LaserCond)
%     
%     WTnoFeedbackL = WT(~Feedback & ChoiceLeft == 1 & LaserTrial==LaserCond(i));
%     WTnoFeedbackR = WT(~Feedback & ChoiceLeft == 0 & LaserTrial==LaserCond(i));
%      meanWTL = nanmean(WTnoFeedbackL);
%     meanWTR = nanmean(WTnoFeedbackR);
%     subplot(3,4,7)
%     histogram(WTnoFeedbackL,10,'EdgeColor','none','FaceColor',ColorsCond{i});
%     line([meanWTL,meanWTL],get(gca,'YLim'),'Color',ColorsCond{i});
%     text(meanWTL-1,(1.05-0.1*(i-1))*(max(get(gca,'YLim'))-min(get(gca,'YLim'))),['m_l=',num2str(round(meanWTL*10)/10)],'Color',ColorsCond{i});
%     subplot(3,4,8)
%     histogram(WTnoFeedbackR,10,'EdgeColor','none','FaceColor',ColorsCond{i});
%     line([meanWTR,meanWTR],get(gca,'YLim'),'Color',ColorsCond{i});
%     text(meanWTL-1,(1.05-0.1*(i-1))*(max(get(gca,'YLim'))-min(get(gca,'YLim'))),['m_r=',num2str(round(meanWTR*10)/10)],'Color',ColorsCond{i});
% 
%     PshortWTL{i} = sum(WTnoFeedbackL<MinWT)/sum(~isnan(WTnoFeedbackL));
%     PshortWTR{i} = sum(WTnoFeedbackR<MinWT)/sum(~isnan(WTnoFeedbackR));
%     
%     end
%     for i =1:length(LaserCond)
%         text(max(get(gca,'XLim'))+0.03,(0.85/i)*(max(get(gca,'YLim'))-min(get(gca,'YLim')))+min(get(gca,'YLim')),['L_{2}=',num2str(round(PshortWTL{i}*100)/100),', R_{2}=',num2str(round(PshortWTR{i}*100)/100)],'Color',ColorsCond{i});
%     end
end



if sum(CatchTrial)
%% ---------------------------------------------------------------------
%% conditioned psychometric
%% ---------------------------------------------------------------------
%
subplot(nRows,nCols,7)
hold on
%low
WTmed=median(WT(CompletedTrials&CatchTrial&WT>MinWT&WT<MaxWT));
AudDV = ExperiencedDV(CompletedTrials&CatchTrial&WT<=WTmed&WT>MinWT);
if ~isempty(AudDV)
    ChoiceLeftadj = ChoiceLeft(CompletedTrials&CatchTrial&WT<=WTmed&WT>MinWT);
    BinIdx = discretize(AudDV,linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,AudBin+1));
    PsycY = grpstats(ChoiceLeftadj,BinIdx,'mean');
    PsycX = grpstats(AudDV,BinIdx,'mean');
    h1=plot(PsycX,PsycY,'ok','MarkerFaceColor',[.5,.5,.5],'MarkerEdgeColor','w','MarkerSize',6);
    XFit = linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,100);
    YFit = glmval(glmfit(AudDV,ChoiceLeftadj','binomial'),linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,100),'logit');
    plot(XFit,YFit,'Color',[.5,.5,.5]);
    %high
    AudDV = ExperiencedDV(CompletedTrials&CatchTrial&WT>WTmed&WT<MaxWT);
    ChoiceLeftadj = ChoiceLeft(CompletedTrials&CatchTrial&WT>WTmed&WT<MaxWT);
    BinIdx = discretize(AudDV,linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,AudBin+1));
    PsycY = grpstats(ChoiceLeftadj,BinIdx,'mean');
    PsycX = grpstats(AudDV,BinIdx,'mean');
    h2=plot(PsycX,PsycY,'ok','MarkerFaceColor','k','MarkerEdgeColor','w','MarkerSize',6);
    XFit = linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,100);
    YFit = glmval(glmfit(AudDV,ChoiceLeftadj','binomial'),linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,100),'logit');
    plot(XFit,YFit,'k');
    xlabel('DV');ylabel('p left')
    legend([h2,h1],{['WT>',num2str(round(WTmed*100)/100)],['WT<',num2str(round(WTmed*100)/100)]},'Units','normalized','Position',[0.333,0.85,0.1,0.1])
end



%% ---------------------------------------------------------------------
%% calibration
%% ---------------------------------------------------------------------
subplot(nRows,nCols,8)
hold on
xlabel('Waiting time (s)');ylabel('p correct')
WTBin=5;
ColorsCorrect = {[.1,.9,.1],[.1,.8,.6]};
ColorsError = {[.9,.1,.1],[.9,.1,.6]};

for i =1:length(LaserCond)
    WTCatch = WT(CompletedTrials&CatchTrial&WT>MinWT&WT<MaxWT & LaserTrial==LaserCond(i));
    if ~isempty(WTCatch)
        BinIdx = discretize(WTCatch,linspace(min(WTCatch)-10*eps,max(WTCatch)+10*eps,WTBin+1));
        WTX = grpstats(WTCatch,BinIdx,'mean');
        PerfY = grpstats(Correct(CompletedTrials&CatchTrial&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i)),BinIdx,'mean');
        plot(WTX,PerfY,'Color',CondColors{i},'LineWidth',2);
        [r,p]=corr(WTCatch',Correct(CompletedTrials&CatchTrial&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i))','type','Spearman');
        text(min(get(gca,'XLim'))+0.05,max(get(gca,'YLim'))-0.07*i,['r=',num2str(round(r*100)/100),', p=',num2str(round(p*100)/100)],'Color',CondColors{i});
    end
end



%% ---------------------------------------------------------------------
%% Vevaiometric
%% ---------------------------------------------------------------------
subplot(nRows,nCols,9)
hold on

xlabel('DV');ylabel('Waiting time (s)')
AudDV = ExperiencedDV(CompletedTrials&CatchTrial&WT<MaxWT&WT>MinWT);
Rcatch=cell(1,2);Pcatch=cell(1,2);Rerror=cell(1,2);Perror=cell(1,2);


for i =1:length(LaserCond)
    
    WTCatch = WT(CompletedTrials&CatchTrial&Correct==1&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i));
    DVCatch = ExperiencedDV(CompletedTrials&CatchTrial&Correct==1&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i));
    if ~isempty(DVCatch)
        BinIdx = discretize(DVCatch,linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,AudBinWT+1));
        if ~all(isnan(BinIdx))
            WTCatchY = grpstats(WTCatch,BinIdx,'mean');
            DVCatchX = grpstats(DVCatch,BinIdx,'mean');
            plot(DVCatchX,WTCatchY,'Color',ColorsCorrect{i},'LineWidth',2)
        end
        WTError = WT(CompletedTrials&Correct==0&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i));
        DVError = ExperiencedDV(CompletedTrials&Correct==0&WT>MinWT&WT<MaxWT  & LaserTrial==LaserCond(i));
        BinIdx = discretize(DVError,linspace(min(AudDV)-10*eps,max(AudDV)+10*eps,AudBinWT+1));
        if ~all(isnan(BinIdx))
            WTErrorY = grpstats(WTError,BinIdx,'mean');
            DVErrorX = grpstats(DVError,BinIdx,'mean');
            plot(DVErrorX,WTErrorY,'Color',ColorsError{i},'LineWidth',2)
        end
        
        plot(DVCatch,WTCatch,'o','MarkerSize',2,'MarkerFaceColor',ColorsCorrect{i},'Color',ColorsCorrect{i})
        plot(DVError,WTError,'o','MarkerSize',2,'MarkerFaceColor',ColorsError{i},'Color',ColorsError{i})
        legend('Correct Catch','Error','Location','best')
        %evaluate vevaiometric
        [Rc,Pc] = EvaluateVevaiometric(DVCatch,WTCatch);
        [Re,Pe] = EvaluateVevaiometric(DVError,WTError);
        Rcatch{i}=Rc;Pcatch{i}=Pc;Rerror{i}=Re;Perror{i}=Pe;
        %confidence auc
        [auc(i),~,auc_sem(i)] = rocarea_torben(WTCatch,WTError,'bootstrap',200);
        
    end
end
for i =1:length(LaserCond)
    if ~isempty(Rcatch{i}) && ~isempty(Pcatch{i}) && ~isempty(Rerror{i}) && ~isempty(Perror{i})
        unit = max(get(gca,'YLim'))-min(get(gca,'YLim'));
        text(max(get(gca,'XLim'))+0.03,max(get(gca,'YLim'))-unit*(0.1+(i-1)*.5),['r_l=',num2str(round(Rcatch{i}(1)*100)/100),' r_r=',num2str(round(Rcatch{i}(2)*100)/100)],'Color',ColorsCorrect{i});
        text(max(get(gca,'XLim'))+0.03,max(get(gca,'YLim'))-unit*(0.2+(i-1)*.5),['r=',num2str(round(Rcatch{i}(3)*100)/100),', p=',num2str(round(Pcatch{i}(3)*100)/100)],'Color',ColorsCorrect{i});
        text(max(get(gca,'XLim'))+0.03,max(get(gca,'YLim'))-unit*(0.3+(i-1)*.5),['r_l=',num2str(round(Rerror{i}(1)*100)/100),' r_r=',num2str(round(Rerror{i}(2)*100)/100)],'Color',ColorsError{i});
        text(max(get(gca,'XLim'))+0.03,max(get(gca,'YLim'))-unit*(0.4+(i-1)*.5),['r=',num2str(round(Rerror{i}(3)*100)/100),', p=',num2str(round(Perror{i}(3)*100)/100)],'Color',ColorsError{i});
    end
end

%% ---------------------------------------------------------------------
%% confidence index
%% ---------------------------------------------------------------------
% subplot(nRows,nCols,8)
% hold on
% for i =1:length(LaserCond)
%     errorbar(1:size(auc,2),auc(i,:),auc_sem(i,:),'o','MarkerFaceColor',CondColors{i},'MarkerEdgeColor',CondColors{i},'LineWidth',2,'Color',CondColors{i})
% end
% xlabel('DV quantile')
% ylabel('AUC')
% 
% RedoTicks(gcf);

end % if sum(CatchTrial)
end % if TaskType==3

%% ---------------------------------------------------------------------
%% Event overview across session
%% ---------------------------------------------------------------------
TrialOverviewHandle = axes(FigHandle, 'Position', [0.025    0.7    0.55    0.28]);
hold on
set(TrialOverviewHandle,...
    'TickDir', 'out',...
    'YAxisLocation', 'right',...
    'YLim', [0,9],...
    'YTick', 1:8,...
    'YTickLabel', {'NoTrialStart', 'BrokeFixation', 'EarlyWithdrawal',...
                   'IncorrectChoice', 'Catch', 'Rewarded', ...
                   'SkippedFeedback', 'ChoiceLeft'},...
    'FontSize', 12);
xlabel(TrialOverviewHandle, 'nTrial', 'FontSize', 14);

idxTrial = 1:nTrials;
NoTrialStartndxTrial = idxTrial(NoTrialStart == 1);
NoTrialStartHandle = line(TrialOverviewHandle,...
                          'xdata', NoTrialStartndxTrial,...
                          'ydata', ones(size(NoTrialStartndxTrial)) * 1,...
                          'LineStyle', 'none',...
                          'Marker', '.',...
                          'MarkerEdge', denim);

BrokeFixationndxTrial = idxTrial(BrokeFixation == 1);
BrokeFixationHandle = line(TrialOverviewHandle,...
                           'xdata', BrokeFixationndxTrial,...
                           'ydata', ones(size(BrokeFixationndxTrial)) * 2,...
                           'LineStyle', 'none',...
                           'Marker', '.',...
                           'MarkerEdge', denim);

EarlyWithdrawalndxTrial = idxTrial(EarlyWithdrawal == 1);
EarlyWithdrawalHandle = line(TrialOverviewHandle,...
                             'xdata', EarlyWithdrawalndxTrial,...
                             'ydata', ones(size(EarlyWithdrawalndxTrial)) * 3,...
                             'LineStyle', 'none',...
                             'Marker', '.',...
                             'MarkerEdge', turquoise);

IncorrectChoicendxTrial = idxTrial(IncorrectChoice == 1);
IncorrectChoiceHandle = line(TrialOverviewHandle,...
                             'xdata', IncorrectChoicendxTrial,...
                             'ydata', ones(size(IncorrectChoicendxTrial)) * 4,...
                             'LineStyle', 'none',...
                             'Marker', '.',...
                             'MarkerEdge', scarlet);

CatchndxTrial = idxTrial(CatchTrial == 1);
CatchHandle = line(TrialOverviewHandle,...
                    'xdata', CatchndxTrial,...
                    'ydata', ones(size(CatchndxTrial)) * 5,...
                    'LineStyle', 'none',...
                    'Marker', '.',...
                    'MarkerEdge', neon_green);

RewardedndxTrial = idxTrial(Rewarded == 1);
RewardedHandle = line(TrialOverviewHandle,...
                    'xdata', RewardedndxTrial,...
                    'ydata', ones(size(RewardedndxTrial)) * 6,...
                    'LineStyle', 'none',...
                    'Marker', '.',...
                    'MarkerEdge', azure);


SkippedFeedbackndxTrial = idxTrial(SkippedFeedback == 1); % Choice made is Baited but Skipped
SkippedFeedbackHandle = line(TrialOverviewHandle,...
                           'xdata', SkippedFeedbackndxTrial,...
                           'ydata', ones(size(SkippedFeedbackndxTrial)) * 7,...
                           'LineStyle', 'none',...
                           'Marker', '.',...
                           'MarkerEdge', neon_purple);

ChoiceLeftndxTrial = idxTrial(ChoiceLeft == 1);
ChoiceLeftHandle = line(TrialOverviewHandle,...
                    'xdata', ChoiceLeftndxTrial,...
                    'ydata', ones(size(ChoiceLeftndxTrial)) * 8,...
                    'LineStyle', 'none',...
                    'Marker', '.',...
                    'MarkerEdge', sand);

%% ---------------------------------------------------------------------
%% Event count and ratio in session
%% ---------------------------------------------------------------------
EventOverviewHandle = axes(FigHandle, 'Position', [0.77    0.7    0.16    0.27]);
hold on
YTickLabel = {strcat(num2str(nTrials), ' | 100%'),...
              strcat(num2str(length(NoTrialStartndxTrial)), ' | ', sprintf('%04.1f', 100*length(NoTrialStartndxTrial)/nTrials), '%'),...
              strcat(num2str(length(BrokeFixationndxTrial)), ' | ', sprintf('%04.1f', 100*length(BrokeFixationndxTrial)/nTrials), '%'),...
              strcat(num2str(length(EarlyWithdrawalndxTrial)), ' | ', sprintf('%04.1f', 100*length(EarlyWithdrawalndxTrial)/nTrials), '%'),...
              strcat(num2str(length(IncorrectChoicendxTrial)), ' | ', sprintf('%04.1f', 100*length(IncorrectChoicendxTrial)/nTrials), '%'),...
              strcat(num2str(length(CatchndxTrial)), ' | ', sprintf('%04.1f', 100*length(CatchndxTrial)/nTrials), '%'),...
              strcat(num2str(length(RewardedndxTrial)), ' | ', sprintf('%04.1f', 100*length(RewardedndxTrial)/nTrials), '%'),...
              strcat(num2str(length(SkippedFeedbackndxTrial)), ' | ', sprintf('%04.1f', 100*length(SkippedFeedbackndxTrial)/nTrials), '%'),...
              strcat(num2str(length(ChoiceLeftndxTrial)), ' | ', sprintf('%04.1f', 100*length(ChoiceLeftndxTrial)/nTrials), '%'),...
              'Count |       %'};

set(EventOverviewHandle,...
    'TickDir', 'out',...
    'XLim', [0, 100],...
    'YLim', [0, 9],...
    'YTick', 0:8,...
    'YTickLabel', YTickLabel,...
    'FontSize', 12);
xlabel(EventOverviewHandle, 'Proportion (%)', 'FontSize', 12);
title('Event Proportion', 'FontSize', 12)

TrialChoiceLeft = max(ChoiceLeft, [], 1);
xdata = 3:9;

TrialDataTable = table(NoTrialStart', BrokeFixation', EarlyWithdrawal',...
                       IncorrectChoice', CatchTrial', Rewarded', ...
                       SkippedFeedback', ChoiceLeft', ...
                       'VariableNames', {'NoTrialStart', 'BrokeFixation', 'EarlyWithdrawal',...
                                        'IncorrectChoice', 'Catch', 'Rewarded', ...
                                        'SkippedFeedback', 'ChoiceLeft'});

TrialDataTable = TrialDataTable(~isnan(TrialChoiceLeft), :); %filters out no choice trials
ChoiceLeftSortedEventMean = table2array(grpstats(fillmissing(TrialDataTable(:, 1:8), 'constant', 0), 'ChoiceLeft'));
ChoiceLeftSortedEventCount = ChoiceLeftSortedEventMean(:, 2) .* ChoiceLeftSortedEventMean(:, xdata);
ChoiceLeftSortedEventProportion = 100 * ChoiceLeftSortedEventCount ./ sum(ChoiceLeftSortedEventCount, 1);

ydata = ChoiceLeftSortedEventProportion';
ChoiceLeftProportions = (ChoiceLeftSortedEventMean(:,2) ./ sum(ChoiceLeftSortedEventMean(:,2))) .* 100;

ChoiceLeftProportions = ChoiceLeftProportions';
ydata = [ydata; ChoiceLeftProportions];
xdata2 = 1:length(ydata);
EventRatioHandle = barh(EventOverviewHandle, xdata2, ydata, 'stacked');

ChoiceLeft = rmmissing(ChoiceLeft);
CuedPalette = [1 0 1 ; 0 1 1];

for i = 1:length(EventRatioHandle)
    EventRatioHandle(i).FaceColor = CuedPalette(i, :);
end

ChoiceLeftLegend = ["Right", "Left"];
EventRatioLegendHandle = legend(EventOverviewHandle, ChoiceLeftLegend,...
                                'Position', [0.7    0.97    0.10    0.012],...
                                'NumColumns', 2);


end  % Analysis()
%% ---------------------------------------------------------------------


%% ---------------------------------------------------------------------
%%                      Helper Functions
%% ---------------------------------------------------------------------
function RedoTicks(h)
    Chil=get(h,'Children');
    
    for i = 1:length(Chil)
        if strcmp(Chil(i).Type,'axes')
            set(Chil(i),'TickDir','out','TickLength',[0.03 0.03],'box','off')
        end
        if strcmp(Chil(i).Type,'legend')
            set(Chil(i),'box','off')
        end
    end
end

function [R,P] = EvaluateVevaiometric(DV,WT)
    % for Vevaiometric (certainty/confidence), part of Analysis()
    R = zeros(1,3);
    P=zeros(1,3);

    if sum(DV<=0)>0
        [R(1),P(1)] = corr(DV(DV<=0)',WT(DV<=0)','type','Spearman');
    end
    if sum(DV>0)>0
        [R(2),P(2)] = corr(DV(DV>0)',WT(DV>0)','type','Spearman');
    end
    if sum(~isnan(DV))>0
        [R(3),P(3)] = corr(abs(DV)',WT','type','Spearman');
    end
end