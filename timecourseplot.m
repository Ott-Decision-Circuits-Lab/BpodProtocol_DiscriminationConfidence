function timecourseplot(TE, handle)


% AttemptedTrialList = find(TE.ResponseAttempted);
AttemptedTrialList = find(TE.ResponseAttempted==1 & TE.Corrpara==0);

OutcomeList = TE.Rewarded(AttemptedTrialList);
try TrialTypeList = TE.TrialTypes(AttemptedTrialList);

catch error
    TE.TrialTypes = TE.Stimulus1ID;
    TrialTypeList = TE.Stimulus1ID(AttemptedTrialList);
end

    LeftTrial = find(mod(TrialTypeList, 2)==1); %odd number should be left; stim==1,3,5 -->1, 
RightTrial = find(mod(TrialTypeList, 2)==0);

LeftRew=double(OutcomeList(LeftTrial));
RightRew=double(OutcomeList(RightTrial));
% LeftRew=double(TE.WT(LeftTrial));
% RightRew=double(TE.WT(RightTrial));

   

if isempty(LeftRew) | (LeftRew==0)
else
%     LLC=smoothed_psth(LeftRew, 1, 3, 1);
     LLC=smoothX(LeftRew,3);
    plot(LeftTrial, LLC, 'ob');
hold on
end

if isempty(RightRew) | (RightRew==0)
else
%    RLC=smoothed_psth(RightRew, 1, 3, 1);
     RLC=smoothX(RightRew,3);
    plot(RightTrial, RLC, 'or');
    hold on
end

   if isempty(LeftRew)&isempty(RightRew) 
       return
   end
   
   if isfield(TE, 'RewardOmissionBlock')
       plot((diff(TE.RewardOmissionBlock(1:length(TE.TrialTypes)))~=0), '--', 'color', [0.9 0.9 0.9])
   end
   
set(handle,'Box','off');
set(handle,'Tickdir','out'); 
Plot1Attribs = get(handle);
set(Plot1Attribs.XLabel, 'String', 'Trials');
set(Plot1Attribs.YLabel, 'String', 'Rewarded trials (%)');

% comment
    if isfield(TE, 'Comment')
    title(TE.Comment)
    end
    
l=legend( 'Left', 'Right');
set(l,'FontSize',12,'Color','w','XColor','w','YColor','w');
set(l,'location', 'best','fontsize',14); 
ylim([0 1])
hold off


%----- 






