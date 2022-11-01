function LoadTriggerProfileMatrix(Player)
% global Player

trigger_matrix = Player.TriggerProfiles; %TriggerProfiles should be of 64 x nChannel
trigger_matrix(1, 1:2) = 1; %first trigger profile: white noise (sound index: 1) on both channel
trigger_matrix(2, 1) = 3; %second trigger profile: left sound (sound index:2) on left channel
trigger_matrix(3, 2) = 4; %third trigger profile: right sound (sound index:3) on right channel
trigger_matrix(4, 1:2) = [3 4]; %fourth profile: combination of second and third profile
Player.TriggerProfiles = trigger_matrix;

end