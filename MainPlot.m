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
        BpodSystem.GUIHandles.OutcomePlot.OdorFracA = line(1:numel(BpodSystem.Data.Custom.OdorFracA),BpodSystem.Data.Custom.OdorFracA/100, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        BpodSystem.GUIHandles.OutcomePlot.Rewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
%         BpodSystem.GUIHandles.OutcomePlot.RewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Unrewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
%         BpodSystem.GUIHandles.OutcomePlot.UnrewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoResponseL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoResponseR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0.5, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',6);
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-.25, 1.25], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
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
        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';
        %% OST histogram
        hold(AxesHandles.HandleOST,'on')
        AxesHandles.HandleOST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleOST.YLabel.String = 'trial counts';
        AxesHandles.HandleOST.Title.String = 'Odor sampling time';
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'trial counts';
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
        set(BpodSystem.GUIHandles.OutcomePlot.OdorFracA, 'xdata', 1:numel(BpodSystem.Data.Custom.OdorFracA), 'ydata',BpodSystem.Data.Custom.OdorFracA/100);
        
        %Plot past trials
        if any(~isnan(OutcomeRecord))
            indxToPlot = mn:CurrentTrial;
            %Cumulative Reward Amount
            set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [CurrentTrial+1 1], 'string', ...
                [num2str(BpodSystem.Data.TrialSettings(end).GUI.RewardAmount * sum(BpodSystem.Data.Custom.Rewarded==1 & ...
                BpodSystem.Data.Custom.Feedback) / 1000) ' mL']);
            %Plot Rewarded
            ndxRwd = ismember(OutcomeRecord(indxToPlot), find(strncmp('rewarded',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end},8)));
            Xdata = indxToPlot(ndxRwd);
            Ydata = BpodSystem.Data.Custom.OdorFracA(indxToPlot); Ydata = Ydata(ndxRwd)/100;
            set(BpodSystem.GUIHandles.OutcomePlot.Rewarded, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Unrewarded
            ndxUrd = ismember(OutcomeRecord(indxToPlot),find(strncmp('unrewarded',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end},10)));
            Xdata = indxToPlot(ndxUrd);
            Ydata = BpodSystem.Data.Custom.OdorFracA(indxToPlot); Ydata = Ydata(ndxUrd)/100;
            set(BpodSystem.GUIHandles.OutcomePlot.Unrewarded, 'xdata', Xdata, 'ydata', Ydata);
            %Plot Broken Fixation
            ndxBroke = OutcomeRecord(indxToPlot) == find(strcmp('broke_fixation',BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}));
            Xdata = indxToPlot(ndxBroke); Ydata = ones(1,sum(ndxBroke))*.5;
            set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
            %Plot NoFeedback trials
            ndxNoFeedback = ~BpodSystem.Data.Custom.Feedback(indxToPlot);
            OdorFracA = BpodSystem.Data.Custom.OdorFracA(indxToPlot)/100;
            Xdata = indxToPlot(ndxNoFeedback);
            Ydata = OdorFracA(ndxNoFeedback);
            set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        end
        %% Psyc
        OdorFracA = BpodSystem.Data.Custom.OdorFracA(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
        stimSet = unique(OdorFracA);
        BpodSystem.GUIHandles.OutcomePlot.Psyc.XData = stimSet;
        psyc = nan(size(stimSet));
        for iStim = 1:numel(stimSet)
            ndxStim = OdorFracA == stimSet(iStim);
            ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft(:));
            psyc(iStim) = nansum(BpodSystem.Data.Custom.ChoiceLeft(ndxStim)/sum(ndxStim&~ndxNan));
        end
        BpodSystem.GUIHandles.OutcomePlot.Psyc.YData = psyc;
        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ChoiceLeft)-1;
        %% Stimulus delay
        cla(AxesHandles.HandleFix)
        BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(BpodSystem.Data.Custom.FixBroke)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(~BpodSystem.Data.Custom.FixBroke)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'none';
        %% OST
        cla(AxesHandles.HandleOST)
        BpodSystem.GUIHandles.OutcomePlot.HistOSTbroke = histogram(AxesHandles.HandleOST,BpodSystem.Data.Custom.OST*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistOSTbroke.BinWidth = 50;
        %% Feedback delay
        cla(AxesHandles.HandleFeedback)
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.FeedbackTime(~BpodSystem.Data.Custom.Feedback)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 100;
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
        %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';
        BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.FeedbackTime(BpodSystem.Data.Custom.Feedback)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 100;
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'b';
%         BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end


