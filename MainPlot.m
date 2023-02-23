function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters

StimTypeMarkerY = -1.75;


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
        MarkerSize = 6;
        MarkerFont = 15;

        % Stimulus type
        BpodSystem.GUIHandles.OutcomePlot.Olf = line(-1,-1, 'LineStyle','none','Marker','O','MarkerEdge','#cdcdcd','MarkerFace','w', 'MarkerSize', MarkerSize - 2);
        BpodSystem.GUIHandles.OutcomePlot.Aud = line(-.5,-1, 'LineStyle','none','Marker','^','MarkerEdge', '#cdcdcd','MarkerFace', 'w', 'MarkerSize', MarkerSize - 2);
        
        % Current trial and target
        BpodSystem.GUIHandles.OutcomePlot.DecisionVariable = line(0, .5, 'LineStyle','none','Marker','_','MarkerEdge','#0ca98c','MarkerFace','#11f3ca', 'MarkerSize', MarkerSize+5);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize', MarkerSize);
        
        % Responses and reward
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1,1.1,'0mL','verticalalignment','bottom','horizontalalignment','center', 'FontSize', MarkerFont);
        BpodSystem.GUIHandles.OutcomePlot.Correct = line(-0.5,1.2, 'LineStyle','none','Marker','^','MarkerEdge','#0b8bad','MarkerFace','#0fb7e4', 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.Incorrect = line(-0.5,-1.2, 'LineStyle','none','Marker','v','MarkerEdge','#ad0b94','MarkerFace','#e50fc4', 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.Catch = line(-.1, 0, 'LineStyle','none','Marker','square','MarkerEdge', '#ea4b0a','MarkerFace', 'none', 'MarkerSize', MarkerSize+5);
        

        % Indicators of an invalid trial
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-.5, 0, 'LineStyle','none','Marker','*','MarkerEdge','#974bde','MarkerFace','none', 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-.4, 0, 'LineStyle','none','Marker','d','MarkerEdge','#974bde','MarkerFace','none', 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-.3, 0, 'LineStyle','none','Marker','+','MarkerEdge','#974bde','MarkerFace','none', 'MarkerSize', MarkerSize);
        BpodSystem.GUIHandles.OutcomePlot.NoResponse = line(-.2, 0, 'LineStyle','none','Marker','x','MarkerEdge','#974bde','MarkerFace','none', 'MarkerSize', MarkerSize);
        
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-2, 2], 'YTick', [-1, 1],'YTickLabel', {'Right','Left'}, 'FontSize', MarkerFont);
        
        set(BpodSystem.GUIHandles.OutcomePlot.Olf,'xdata', -.5, 'ydata', StimTypeMarkerY); %find(~BpodSystem.Data.Custom.TrialData.AuditoryTrial),'ydata',BpodSystem.Data.Custom.TrialData.DecisionVariable(~BpodSystem.Data.Custom.TrialData.AuditoryTrial));
        set(BpodSystem.GUIHandles.OutcomePlot.Aud,'xdata', -.5, 'ydata', StimTypeMarkerY); %find(BpodSystem.Data.Custom.TrialData.AuditoryTrial),'ydata',BpodSystem.Data.Custom.TrialData.DecisionVariable(BpodSystem.Data.Custom.TrialData.AuditoryTrial));
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', MarkerFont);
        hold(AxesHandles.HandleOutcome, 'on');

        %% Psyc Olfactory
        BpodSystem.GUIHandles.OutcomePlot.PsycOlf = line(AxesHandles.HandlePsycOlf,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit = line(AxesHandles.HandlePsycOlf,[0 100],[.5 .5],'color','k','Visible','off');
        AxesHandles.HandlePsycOlf.YLim = [-.05 1.05];
        AxesHandles.HandlePsycOlf.XLim = 100*[-.05 1.05];
        AxesHandles.HandlePsycOlf.XLabel.String = '% odor A'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycOlf.YLabel.String = '% left';
        AxesHandles.HandlePsycOlf.Title.String = 'Psychometric Olf';

        %% Psyc Auditory
        BpodSystem.GUIHandles.OutcomePlot.PsycAud = line(AxesHandles.HandlePsycAud,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudFit = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],'color','k','Visible','off');
        AxesHandles.HandlePsycAud.YLim = [-.05 1.05];
        AxesHandles.HandlePsycAud.XLim = [-1.05, 1.05];
        AxesHandles.HandlePsycAud.XLabel.String = 'beta'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycAud.YLabel.String = '% left';
        AxesHandles.HandlePsycAud.Title.String = 'Psychometric Aud';
        
        %% Vevaiometric curve
        hold(AxesHandles.HandleVevaiometric,'on')
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','g','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','r','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','r','Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','r');
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','g','Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','g');
        AxesHandles.HandleVevaiometric.YLim = [0 10];
        AxesHandles.HandleVevaiometric.XLim = [-1.05, 1.05];
        AxesHandles.HandleVevaiometric.XLabel.String = 'Decision Variable';
        AxesHandles.HandleVevaiometric.YLabel.String = 'Wait time (s)';
        AxesHandles.HandleVevaiometric.Title.String = 'Vevaiometric';

        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = '# Trials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';

        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'Trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';

        %% SampleLength histogram
        hold(AxesHandles.HandleSampleLength,'on')
        AxesHandles.HandleSampleLength.XLabel.String = 'Time (ms)';
        AxesHandles.HandleSampleLength.YLabel.String = 'Trial counts';
        AxesHandles.HandleSampleLength.Title.String = 'Stimulus sample length';

        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'Trial counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';

    case 'update'
        TDTemp = BpodSystem.Data.Custom.TrialData;

        %% Reposition and hide/show axes
        ShowPlots = [TaskParameters.GUI.ShowPsycOlf,TaskParameters.GUI.ShowPsycAud,TaskParameters.GUI.ShowVevaiometric,...
                     TaskParameters.GUI.ShowTrialRate,TaskParameters.GUI.ShowFix,TaskParameters.GUI.ShowSampleLength,TaskParameters.GUI.ShowFeedback];
        NoPlots = sum(ShowPlots);
        NPlot = cumsum(ShowPlots);
        if ShowPlots(1)
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf.Position =      [NPlot(1)*.05+0.005                                    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycOlf,'Children'),'Visible','off');
        end
        if ShowPlots(2)
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Position =      [NPlot(2)*.05+0.005 + (NPlot(2)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud,'Children'),'Visible','off');
        end
        if ShowPlots(3)
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Position = [NPlot(3)*.05+0.005 + (NPlot(3)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric,'Children'),'Visible','off');
        end
        if ShowPlots(4)
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Position =    [NPlot(4)*.05+0.005 + (NPlot(4)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','off');
        end
        if ShowPlots(5)
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Position =          [NPlot(5)*.05+0.005 + (NPlot(5)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFix,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFix,'Children'),'Visible','off');
        end
        if ShowPlots(6)
            BpodSystem.GUIHandles.OutcomePlot.HandleSampleLength.Position =           [NPlot(6)*.05+0.005 + (NPlot(6)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleSampleLength.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleSampleLength,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleSampleLength.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleSampleLength,'Children'),'Visible','off');
        end
        if ShowPlots(7)
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Position =     [NPlot(7)*.05+0.005 + (NPlot(7)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFeedback,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFeedback,'Children'),'Visible','off');
        end
        
        %% Outcome
        iTrial = varargin{1};
        LeftChoices = TDTemp.ChoiceLeft;

        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim
        StimTypeYMarkers = StimTypeMarkerY * ones(size(TDTemp.TrialNumber));
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial+1, 'ydata', 0);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', iTrial+1, 'ydata', 0);
        
        % plot modality background
        set(BpodSystem.GUIHandles.OutcomePlot.Olf, 'xdata', find(~TDTemp.AuditoryTrial), 'ydata', StimTypeYMarkers(~TDTemp.AuditoryTrial));  %TDTemp.DecisionVariable(~TDTemp.AuditoryTrial));
        set(BpodSystem.GUIHandles.OutcomePlot.Aud, 'xdata', find(TDTemp.AuditoryTrial), 'ydata', StimTypeYMarkers(TDTemp.AuditoryTrial));  %TDTemp.DecisionVariable(TDTemp.AuditoryTrial));
        
        % plot past&future trials
        set(BpodSystem.GUIHandles.OutcomePlot.DecisionVariable, 'xdata', mn:numel(TDTemp.DecisionVariable), 'ydata', TDTemp.DecisionVariable(mn:end));
        
        %Plot past trial outcomes
        indxToPlot = mn:iTrial;
        Ydata = TDTemp.DecisionVariable(indxToPlot); 

        CumRewardTotal = CalculateCumulativeReward();
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
            [num2str(CumRewardTotal/1000) ' mL']);

        %Plot Rewarded
        ndxCor = TDTemp.ChoiceCorrect(indxToPlot)==1;
        set(BpodSystem.GUIHandles.OutcomePlot.Correct, 'xdata', indxToPlot(ndxCor), 'ydata', Ydata(ndxCor));

        %Plot Incorrect
        ndxInc = TDTemp.ChoiceCorrect(indxToPlot)==0;
        set(BpodSystem.GUIHandles.OutcomePlot.Incorrect, 'xdata', indxToPlot(ndxInc), 'ydata', Ydata(ndxInc));

        %Plot Broken Fixation
        ndxBroke = TDTemp.FixBroke(indxToPlot);
        %Ydata = zeros(1,sum(ndxBroke));
        set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', indxToPlot(ndxBroke), 'ydata', Ydata(ndxBroke));

        %Plot Early Withdrawal
        ndxEarly = TDTemp.EarlyWithdrawal(indxToPlot);
        %Ydata = zeros(1,sum(ndxEarly));
        set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', indxToPlot(ndxEarly), 'ydata', Ydata(ndxEarly));

        %Plot missed choice trials
        ndxMiss = isnan(LeftChoices(indxToPlot))&~ndxBroke&~ndxEarly;
        set(BpodSystem.GUIHandles.OutcomePlot.NoResponse, 'xdata', indxToPlot(ndxMiss), 'ydata', Ydata(ndxMiss));

        %Plot NoFeedback trials
        ndxNoFeedback = ~TDTemp.Feedback(indxToPlot) & ~ndxMiss;
        set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', indxToPlot(ndxNoFeedback), 'ydata', Ydata(ndxNoFeedback));

        %Plot catch trials
        ndxCatch = TDTemp.CatchTrial(indxToPlot) & ~ndxMiss;
        set(BpodSystem.GUIHandles.OutcomePlot.Catch, 'xdata', indxToPlot(ndxCatch), 'ydata', Ydata(ndxCatch));
        % --------------------------------------------------------------- %


        
        
        %% Psyc Olf
        if TaskParameters.GUI.ShowPsycOlf
            OdorFracA = TDTemp.OdorFracA(1:numel(LeftChoices));
            OdorTrials = ~TDTemp.AuditoryTrial(1:numel(LeftChoices));
            OdorNaNs = isnan(OdorFracA);

            if isfield(BpodSystem.Data.Custom,'BlockNumber')
                BlockNumber = TDTemp.BlockNumber;
            else
                BlockNumber = ones(size(LeftChoices));
            end
            setBlocks = reshape(unique(BlockNumber),1,[]); 

            ndxNan = isnan(LeftChoices);
            for iBlock = setBlocks(end)
                ndxBlock = TDTemp.BlockNumber(1:numel(LeftChoices)) == iBlock;
                if any(ndxBlock)
                    setStim = reshape(unique(OdorFracA(ndxBlock&~OdorNaNs)),1,[]);
                    psyc = nan(size(setStim));
                    if isempty(psyc)
                        continue
                    end

                    for iStim = setStim
                        ndxStim = reshape(OdorFracA == iStim,1,[]);
                        psyc(setStim==iStim) = sum(LeftChoices(ndxStim&~ndxNan&ndxBlock&OdorTrials))/...
                            sum(ndxStim&~ndxNan&ndxBlock&OdorTrials);
                    end
                    if iBlock <= numel(BpodSystem.GUIHandles.OutcomePlot.PsycOlf) && ishandle(BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock))
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock).XData = setStim;
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock).YData = psyc;
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock).XData = linspace(min(setStim),max(setStim),100);
                        if sum(OdorFracA(ndxBlock&OdorTrials))>0
                            BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock).YData = glmval(glmfit(OdorFracA(ndxBlock&OdorTrials),...
                                LeftChoices(ndxBlock&OdorTrials)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
                        end
                    else
                        lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
                        bias = tanh(.3 * [1 -1] * TDTemp.RewardMagnitude(:, find(ndxBlock,1)));
                        lineColor(1) = 0.08+0.04*bias; lineColor(2) = .75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
                        %                     lineColor = lineColor + [0 0.3843*(tanh(TDTemp.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]')) 0]
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock) = line(AxesHandles.HandlePsycOlf,setStim,psyc, 'LineStyle','none','Marker','o',...
                            'MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock) = line(AxesHandles.HandlePsycOlf,[0 100],[.5 .5],'color',lineColor);
                    end
                end
                % GUIHandles.OutcomePlot.Psyc.YData = psyc;
            end
            %
            %
            %         stimSet = unique(OdorFracA);
            %         BpodSystem.GUIHandles.OutcomePlot.PsycOlf.XData = stimSet;
            %         psyc = nan(size(stimSet));
            %         for iStim = 1:numel(stimSet)
            %             ndxStim = OdorFracA == stimSet(iStim);
            %             ndxNan = isnan(LeftChoices(:));
            %             psyc(iStim) = nansum(LeftChoices(ndxStim)/sum(ndxStim&~ndxNan));
            %         end
            %         BpodSystem.GUIHandles.OutcomePlot.PsycOlf.YData = psyc;
        end
        
        %% Psych Aud
        if TaskParameters.GUI.ShowPsycAud

            
            LeftNaNs = isnan(LeftChoices);
            AudDV = TDTemp.DecisionVariable(1:numel(LeftChoices));
            DVNaNs = isnan(AudDV);
            AudTrials = TDTemp.AuditoryTrial(1:numel(LeftChoices));
            

            if isfield(BpodSystem.Data.Custom,'BlockNumber')
                BlockNumber = TDTemp.BlockNumber;
            else
                BlockNumber = ones(size(LeftChoices));
            end

            setBlocks = reshape(unique(BlockNumber),1,[]);
            
            for iBlock = setBlocks(end)
                BlockIdx = TDTemp.BlockNumber(1:numel(LeftChoices)) == iBlock;
                
                if any(BlockIdx)
                    ValidTrials = AudTrials & ~LeftNaNs & ~DVNaNs & BlockIdx;
                    LeftAudTrialsInBlock = LeftChoices(ValidTrials);

                    AudBin = 8; % Magic number!?
                    BinIdx = discretize(AudDV, linspace(-1, 1, AudBin+1));
                    LeftAudBinsInBlock = BinIdx(ValidTrials);

                    PsycY = grpstats(LeftAudTrialsInBlock, LeftAudBinsInBlock, 'mean');
                    PsycX = unique(LeftAudBinsInBlock) / AudBin*2 -1 -1 / AudBin;

                    if isempty(PsycY) || isempty(PsycX)
                        continue
                    end
                    
                    if iBlock <= numel(BpodSystem.GUIHandles.OutcomePlot.PsycAud) && ishandle(BpodSystem.GUIHandles.OutcomePlot.PsycAud(iBlock))
                        BpodSystem.GUIHandles.OutcomePlot.PsycAud(iBlock).YData = PsycY;
                        BpodSystem.GUIHandles.OutcomePlot.PsycAud(iBlock).XData = PsycX;
                        if sum(ValidTrials) > 5
                            BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
                            BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.YData = glmval(glmfit(AudDV(ValidTrials),...
                                LeftAudTrialsInBlock','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
                        end
                    else
                        lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
                        bias = tanh(.3 * [1 -1] * TDTemp.RewardMagnitude(:, find(BlockIdx,1)));
                        lineColor(1) = 0.08+0.04*bias; lineColor(2) = .75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
                        %                     lineColor = lineColor + [0 0.3843*(tanh(TDTemp.RewardMagnitude(find(BlockIdx,1),:) * [1 -1]')) 0]
                        BpodSystem.GUIHandles.OutcomePlot.PsycAud(iBlock) = line(AxesHandles.HandlePsycAud,PsycX,PsycY, 'LineStyle','none','Marker','o',...
                            'MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlfAud(iBlock) = line(AxesHandles.HandlePsycAud,[0 100],[.5 .5],'color',lineColor);
                        
                    end
                end
            end
        end



        %% Vevaiometric
        if TaskParameters.GUI.ShowVevaiometric
            ErrorTrials = TDTemp.ChoiceCorrect(1:iTrial) == 0 ; %all (completed) error trials (including catch errors)
            CorrectCatches = TDTemp.CatchTrial(1:iTrial) & TDTemp.ChoiceCorrect(1:iTrial) == 1; %only correct catch trials
            Invested = TDTemp.FeedbackTime > TaskParameters.GUI.VevaiometricMinWT;
            ErrIdx = ErrorTrials & Invested;
            CorrIdx = CorrectCatches & Invested;
            
            DV = TDTemp.DecisionVariable(1:iTrial);
            DVNBin = TaskParameters.GUI.VevaiometricNBin;
            BinIdx = discretize(DV,linspace(-1,1,DVNBin+1));
            Xerr = unique(BinIdx(ErrIdx))/DVNBin*2-1-1/DVNBin;
            Xcatch = unique(BinIdx(CorrIdx))/DVNBin*2-1-1/DVNBin;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.XData = Xerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.XData = Xcatch;

            FeedbackErr = TDTemp.FeedbackTime(ErrIdx);
            FeedbackCorr = TDTemp.FeedbackTime(CorrIdx);
            WTerr = grpstats(FeedbackErr, BinIdx(ErrIdx),'mean')';
            WTcatch = grpstats(FeedbackCorr, BinIdx(CorrIdx),'mean')';
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.YData = WTerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.YData = WTcatch;

            
            if TaskParameters.GUI.VevaiometricShowPoints
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = FeedbackErr;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = DV(ErrIdx);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = FeedbackCorr;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = DV(CorrIdx);
            else
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = -1;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = 0;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = -1;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = 0;
            end
        end


        %% Trial rate
        if TaskParameters.GUI.ShowTrialRate
            TrialStarts = BpodSystem.Data.TrialStartTimestamp;
            RelativeStartsMinutes = (TrialStarts - min(TrialStarts)) / 60;
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = RelativeStartsMinutes;
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(LeftChoices);
        end

        if TaskParameters.GUI.ShowFix
            %% Stimulus delay
            cla(AxesHandles.HandleFix)

            BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,TDTemp.FixDur(TDTemp.FixBroke)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
            
            BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,TDTemp.FixDur(~TDTemp.FixBroke)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'b';

            BreakP = mean(TDTemp.FixBroke);
            cornertext(AxesHandles.HandleFix,sprintf('P=%1.2f',BreakP))
        end


        %% Sample Length
        if TaskParameters.GUI.ShowSampleLength
            cla(AxesHandles.HandleSampleLength)

            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleSampleLength,TDTemp.SampleLength(TDTemp.EarlyWithdrawal)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';

            BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleSampleLength,TDTemp.SampleLength(~TDTemp.EarlyWithdrawal)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'b';

            EarlyP = sum(TDTemp.EarlyWithdrawal)/sum(~TDTemp.FixBroke);
            cornertext(AxesHandles.HandleSampleLength,sprintf('P=%1.2f',EarlyP))
        end

        %% Feedback delay (exclude catch trials and error trials, if set on catch)
        if TaskParameters.GUI.ShowFeedback
            cla(AxesHandles.HandleFeedback)
            if TaskParameters.GUI.CatchError
                ndxExclude = TDTemp.ChoiceCorrect(1:iTrial) == 0; %exclude error trials if they are set on catch
            else
                ndxExclude = false(1,iTrial);
            end
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,TDTemp.FeedbackTime(~TDTemp.Feedback(1:iTrial)&~TDTemp.CatchTrial(1:iTrial)&~ndxExclude)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 100;
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
            %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';

            BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleFeedback,TDTemp.FeedbackTime(TDTemp.Feedback(1:iTrial)&~TDTemp.CatchTrial(1:iTrial)&~ndxExclude)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'b';
            %BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';

            LeftSkip = sum(~TDTemp.Feedback(1:iTrial)&~TDTemp.CatchTrial(1:iTrial)&~ndxExclude&LeftChoices(1:iTrial)==1)/sum(~TDTemp.CatchTrial(1:iTrial)&~ndxExclude&LeftChoices(1:iTrial)==1);
            RightSkip = sum(~TDTemp.Feedback(1:iTrial)&~TDTemp.CatchTrial(1:iTrial)&~ndxExclude&LeftChoices(1:iTrial)==0)/sum(~TDTemp.CatchTrial(1:iTrial)&~ndxExclude&LeftChoices(1:iTrial)==0);
            cornertext(AxesHandles.HandleFeedback,{sprintf('L=%1.2f',LeftSkip),sprintf('R=%1.2f',RightSkip)})
        end
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end

