function InitiatePsychtoolbox(iTrial)
global BpodSystem
if BpodSystem.Data.Custom.AuditoryTrial(iTrial) && ~BpodSystem.Data.Custom.ClickTask(iTrial) && ~BpodSystem.Data.Custom.PsychtoolboxStartup
    PsychToolboxSoundServer('init');
    BpodSystem.Data.Custom.PsychtoolboxStartup=true;
end