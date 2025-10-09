function LoadTriggerProfileMatrix(Player)
% global Player

trigger_matrix = Player.TriggerProfiles; %TriggerProfiles should be of 64 x nChannel
trigger_matrix(1, 1:2) = 1; %first trigger profile: white noise (sound index: 1) on both channel
trigger_matrix(2, 1) = 3; %second trigger profile: left sound (sound index:3) on left channel
trigger_matrix(3, 2) = 4; %third trigger profile: right sound (sound index:4) on right channel
trigger_matrix(4, 1:2) = [3 4]; %fourth profile: combination of third and fourth profile
trigger_matrix(5, 1:2) = 2; %fifth trigger profile: white noise (incorrect timeout) (sound index: 2) on both channel
trigger_matrix(6, 1:2) = 5; %sixth trigger profile: pure tone beep (sound index: 5) on both channels
trigger_matrix(7, 3) = 8;  % seventh trigger profile: laser waveform for blue laser
trigger_matrix(8, 4) = 9;  % eighth trigger profile: laser waveform for red laser
trigger_matrix(9, 1:3) = [3 4 8];  % Ninth trigger profile: play clicks and blue laser waveforms
trigger_matrix(10, [1 2 4]) = [3 4 9];  % Tenth trigger profile: play clicks and red laser waveforms
trigger_matrix(11, 3:4) = 10;  % Eleventh trigger profile: stop waveform to stop laser upon state change
trigger_matrix(12, 1:4) = [1 1 10 10];  % Twelfth trigger profile: play early withdrawal white noise and stop laser

Player.TriggerProfiles = trigger_matrix;

end