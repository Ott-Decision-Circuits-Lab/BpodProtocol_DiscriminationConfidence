%User Kill Script
%this script, when saved in the current protocol folder, will be executed
%at Bpod termination.
%Serves for custom and protocol specific action at session end.

global TaskParameters

%add user specific scripts here

switch TaskParameters.GUI.UserKillScript 
    case 1 %none
    case 2 %
        UserKillScriptThiago();
    case 3
        UserKillScriptTorben();
    otherwise
        fprintf('Undefined UserKillScript option.\n');
end