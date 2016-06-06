function  S = JHOverride_bpodV05 (S)

global BpodSystem

if S.currentTrial==1
[s] = listdlg('PromptString','Select a task:',...
                'SelectionMode','single',...
                'ListString',{'Practice task', 'Odor discrimination task', 'Bias task', 'confidence task'});
        if  ~isempty(s)          
                switch s    
                    case 1
                        def = {'10000','1', '1', '1', '0', '0', '3', '100', '1', '0', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum
                    case 2
                        def = {'40','1', '1', '1', '0', '0', '3', '100', '1', '0', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum
                    case 3
                        def = {'[60 60]','0', '1', '.3', '0', '60:80', '4', '30', '1', '0', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum
                    case 4
                        def = {'0','1', '1', '1', '0', '0', '3', '30', '1', '0.1', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum

                end
        else
                def = {'0','1', '1', '1', '0', '0', '3', '40', '1', '0', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum     
        end

TE.nTrials=1;
TE.rigname=strtrim(evalc('system(''hostname'');')) %130506

pause(0.1)
prompt = {'Correction procedure','BiasProb','BiasProb_Op', 'RewSize', 'BiasSchock', 'TrialNum/Block', 'BlockRepeat', 'EasyTrialNum', 'StartTrial', 'CatchTrialProb', 'Weight', 'Comment'};
dlg_title = 'Input variables';
num_lines = 1;
% def = {'0','1', '1', '1', '0', '80', '3', '40', '1', '0', '', ''}; %JH cp, bias, sizeOrProb,BiasSchock, trialnum, blockrepeat, EasyTrialNum
answer = inputdlg(prompt,dlg_title,num_lines,def);

CorPro=str2num(answer{1});
BiasProb=str2num(answer{2}); % determin bias trial probability for smaller reward side (1 for 0%, 0 for 100% bias trials)
BiasProb_Op=str2num(answer{3}); % determin bias trial probability for bigger reward side (1 for 0%, 0 for 100% bias trials)
RewSize=str2num(answer{4}); %1 for default size and X times
BiasSchock=str2num(answer{5}); %0 for default (no shock) 1 for schock
BkNum=str2num(answer{6});
repeat=str2num(answer{7});
EasyTrialNum=str2num(answer{8});
StartTrial=str2num(answer{9});
CatchTrialProb=str2num(answer{10});
Weight=str2num(answer{11});
Comment=answer{12};

TE.CorPro=CorPro(1);
if length(CorPro)>1
TE.CorPro2=CorPro(2);
else
TE.CorPro2=0;
end
TE.BiasProb=BiasProb;
TE.BiasProb_Op=BiasProb_Op;
TE.RewSize=RewSize;
TE.BiasSchock=BiasSchock;
TE.BkNum=BkNum;
TE.repeat=repeat;
TE.EasyTrialNum=EasyTrialNum;
TE.StartTrial=StartTrial;
TE.CatchTrialProb=CatchTrialProb;
TE.Weight=Weight;
TE.Comment=Comment;

    
%%%%

%    %JH 140605_temporarily hack
%    try  startup_rewardsignal
%    catch error
%        disp('error! something wrong is pulsepal. Ignore if you dont use pulsepal')
%    end
   %

        if StartTrial~=1
            clear TE;
            pause(1) %necessary to prevent a bag
           dn = fileparts(BpodSystem.DataPath);
            [FileName,PathName] = uigetfile(dn);
            load (fullfile(PathName,FileName))
            S = SessionData; 
            TE = SessionData.TE;
            [TE] = trialPlusOne (TE); %JH130526
            S.currentTrial = TE.nTrials+1;
            S.nStartedTrials = TE.nTrials+1;
            TE.nTrials = TE.nTrials+1;
             TE.StartTrial=StartTrial;
        end
        
else %non first trial
    TE=S.TE;
    TE.nTrials=S.currentTrial;
end

         TrialParams = S.TrialParams;
         TrialParams.TrialTypes = S.TrialParams.StimulusID1;

        % for bias block task
          [TE,TrialParams] = BiasBlockSetUp_BpodV05(TE,TrialParams);
          
        % for easy trial start
          [TE,TrialParams] = EasyTrialStart_BpodV05(TE,TrialParams);
        
        % repeat same stimulus until animal answers correctly
        if TE.CorPro~=0
          [TE,TrialParams] = RepeatedTrial_BpodV05(TE,TrialParams);
        end
                    
        % For implimenting catchtrials
           [TE,TrialParams] = SUB_WaitingTimeTask_BpodV05 (TE,TrialParams);

    S.TE = TE;
    S.TrialParams = TrialParams;

    S.ProtocolSettings.CorPro= TE.CorPro;
    S.ProtocolSettings.BiasProb= TE.BiasProb;
    S.ProtocolSettings.BiasProb_Op= TE.BiasProb_Op;
    S.ProtocolSettings.RewSize= TE.RewSize;
    S.ProtocolSettings.BiasSchock= TE.BiasSchock;
    S.ProtocolSettings.BkNum= TE.BkNum;
    S.ProtocolSettings.repeat= TE.repeat;
     S.ProtocolSettings.StartTrial = TE.StartTrial;
    S.ProtocolSettings.CatchTrialProb= TE.CatchTrialProb;
    S.ProtocolSettings.EasyTrialNum = TE.EasyTrialNum;
    S.ProtocolSettings.Weight= TE.Weight;     
    S.ProtocolSettings.Comment  = TE.Comment;

end