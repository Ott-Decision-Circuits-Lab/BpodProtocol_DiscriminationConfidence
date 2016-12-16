%User Kill Script
%this script, when saved in the current protocol folder, will be executed
%at Bpod termination.
%Serves for custom and protocol specific action at session end.

global BpodSystem
global TaskParameters

MailAddress = 'olrin.f6cfd9@m.evernote.com';

%save figure
FigureFolder = fullfile(fileparts(fileparts(BpodSystem.DataPath)),'Session Figures');
FigureHandle = BpodSystem.GUIHandles.OutcomePlot.HandleOutcome.Parent;
FigureString = get(FigureHandle,'Name');
[~, FigureName] = fileparts(BpodSystem.DataPath);
if ~isdir(FigureFolder)
    mkdir(FigureFolder);
end

FigurePath = fullfile(FigureFolder,[FigureName,'.png']);
saveas(FigureHandle,FigurePath,'png');

%Analysis
try
    FigAnalysis = User();
    FigurePathAnalysis = fullfile(FigureFolder,[FigureName,'Analysis.png']);
    saveas(FigAnalysis,FigurePathAnalysis,'png');
    s=close(FigAnalysis);
    DidAnalysis = true;
catch
    DidAnalysis = false;
end

%send email if wished
if TaskParameters.GUI.SendFigure
    [x,sessionfile] = fileparts(BpodSystem.DataPath);
    [~,animal] = fileparts(fileparts(fileparts(x)));
    
    Subject = strcat(sessionfile,'@',animal);
    Body = sessionfile;
    
    if DidAnalysis
        Attachment = {FigurePath,FigurePathAnalysis};
    else
        Attachment = {FigurePath};
    end
    
    sent = SendMyMail(MailAddress,Subject,Body,Attachment);
    
    if sent
        fprintf('Figure "%s" sent to %s.\n',FigureString,MailAddress);
    else
        fprintf('Error:SendFigureTo:Mail could not be sent to %s.\n',MailAddress);
    end
    
end

