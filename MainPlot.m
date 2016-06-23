function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem

switch Action
    case 'init'
        %% Outcome
        %initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >=3  %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %         Xdata = 1:numel(SideList); Ydata = SideList(Xdata);
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.OdorID = line(1:numel(BpodSystem.Data.Custom.OdorID),BpodSystem.Data.Custom.OdorID==1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(2,0.5,'0mL','verticalalignment','middle','horizontalalignment','left');
        BpodSystem.GUIHandles.OutcomePlot.RewardedL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.RewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoResponseL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoResponseR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0.5, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',6);
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-1, 2], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 18);
        hold(AxesHandles.HandleOutcome, 'on');
        %% Psyc
        BpodSystem.GUIHandles.OutcomePlot.Psyc = line(AxesHandles.HandlePsyc,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
        AxesHandles.HandlePsyc.YLim = [-.05 1.05];
        AxesHandles.HandlePsyc.XLim = 100*[-.05 1.05];
        AxesHandles.HandlePsyc.XLabel.String = '% odor A'; % FIGURE OUT UNIT
        AxesHandles.HandlePsyc.YLabel.String = '% choice A';
        AxesHandles.HandlePsyc.Title.String = 'Psychometric';
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';
        %% OST histogram
        hold(AxesHandles.HandleOST,'on')
        AxesHandles.HandleOST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleOST.YLabel.String = 'nTrials';
        AxesHandles.HandleOST.Title.String = 'OST';
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (s)';
        AxesHandles.HandleFeedback.YLabel.String = 'nTrials';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';
    case 'update'
        %% Outcome
        CurrentTrial = varargin{1};
        OutcomeRecord = BpodSystem.Data.Custom.OutcomeRecord;
        
        % recompute xlim
        [mn, mx] = rescaleX(AxesHandles.HandleOutcome,CurrentTrial,nTrialsToShow);
        
        %axes(AxesHandle); %cla;
        %plot future trials
        %         FutureTrialsIndx = CurrentTrial:mx;
        %         Xdata = FutureTrialsIndx; Ydata = SideList(Xdata);
        %         set(BpodSystem.GUIHandles.FutureTrialLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
        %Plot current trial
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', CurrentTrial+1, 'ydata', .5);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', CurrentTrial+1, 'ydata', .5);
        set(BpodSystem.GUIHandles.OutcomePlot.OdorID, 'xdata', 1:numel(BpodSystem.Data.Custom.OdorID), 'ydata',double(BpodSystem.Data.Custom.OdorID==1));
        
        %Plot past trials
        if any(~isnan(OutcomeRecord))
            indxToPlot = mn:CurrentTrial;
            %Cumulative Reward Amount
            set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [CurrentTrial + 1.6 .5], 'string', ...
                [num2str(BpodSystem.Data.TrialSettings(end).GUI.RewardAmount * sum(BpodSystem.Data.Custom.Rewarded==1 & ...
                BpodSystem.Data.Custom.Feedback) / 1000) ' mL']);
            %Plot Rewarded Left
            ndxRwdL = OutcomeRecord(indxToPlot) == find(strcmp('rewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxRwdL); Ydata = ones(1,sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedL, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Rewarded Right
            ndxRwdR = OutcomeRecord(indxToPlot) == find(strcmp('rewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxRwdR); Ydata = zeros(1,sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedR, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Unrewarded Left
            ndxUrdL = OutcomeRecord(indxToPlot) == find(strcmp('unrewarded_Lin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxUrdL); Ydata = zeros(1,sum(ndxUrdL));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedL, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Unrewarded Right
            ndxUrdR = OutcomeRecord(indxToPlot) == find(strcmp('unrewarded_Rin',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxUrdR); Ydata = ones(1,sum(ndxUrdR));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedR, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Broken Fixation
            ndxBroke = OutcomeRecord(indxToPlot) == find(strcmp('broke_fixation',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxBroke); Ydata = ones(1,sum(ndxBroke))*.5;
            set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
            %Plot NoFeedback trials
            ndxNoFeedback = ~BpodSystem.Data.Custom.Feedback(indxToPlot);
            OdorID = BpodSystem.Data.Custom.OdorID(indxToPlot);
            Xdata = indxToPlot(ndxNoFeedback);
            Ydata = double(OdorID(ndxNoFeedback)==1);
            set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        end
        %% Psyc
        stimSet = unique(BpodSystem.Data.Custom.OdorFracA);
        BpodSystem.GUIHandles.OutcomePlot.Psyc.XData = stimSet;
        psyc = nan(size(stimSet));
        for iStim = 1:numel(stimSet)
            ndxStim = BpodSystem.Data.Custom.OdorFracA == stimSet(iStim);
            ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft);
            psyc(iStim) = nansum(BpodSystem.Data.Custom.ChoiceLeft(ndxStim)/sum(ndxStim&~ndxNan));
        end
        BpodSystem.GUIHandles.OutcomePlot.Psyc.YData = psyc;
        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ChoiceLeft)-1;
        %% Stimulus delay
        cla(AxesHandles.HandleFix)
        BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.BrokeFixTime(BpodSystem.Data.Custom.BrokeFix));
        BpodSystem.GUIHandles.OutcomePlot.HistFix.NumBins = 10;
        BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.OST(~BpodSystem.Data.Custom.BrokeFix));
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.NumBins = 10;
        
        %% OST
        cla(AxesHandles.HandleFeedback)
        BpodSystem.GUIHandles.OutcomePlot.HistOSTbroke = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.OST(BpodSystem.Data.Custom.BrokeFix));
        BpodSystem.GUIHandles.OutcomePlot.HistOSTbroke.NumBins = 10;
        BpodSystem.GUIHandles.OutcomePlot.HistOSTok = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.OST(~BpodSystem.Data.Custom.BrokeFix));
        BpodSystem.GUIHandles.OutcomePlot.HistOSTbroke.NumBins = 10;
        HandleOST
        %% Feedback delay
        cla(AxesHandles.HandleFeedback)
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.FeedbackTime(~BpodSystem.Data.Custom.Feedback));
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.NumBins = 10;
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end


