function [OlfIP BankPairOffset Carrier hostname]= olfactometerIP_JH

hostname=strtrim(evalc('system(''hostname'');'));
switch hostname
% Start hostname cases
    case 'cnmc15-PC'  %rig1/recording rig
       OlfIP = [192 168 1 110];
       BankPairOffset = 2;  
       Carrier=1;

    case 'cnmc13'  %rig2
       OlfIP = [192 168 1 110];
       BankPairOffset = 0;   %note that it uses bank1/2 (downstairs rig)
              Carrier=2;     % but using carrier 2.
      
    case 'cnmc17'   %rig 3
       OlfIP = [192 168 0 104];
       BankPairOffset = 0; 
       Carrier=1;
               
    case 'cnmc18'   %rig 4
       OlfIP = [192 168 0 104];
       BankPairOffset = 2; 
       Carrier=2;
               
    case 'HAL9000'   %rig5
       OlfIP = [192 168 1 100];
       BankPairOffset = 0;     
       Carrier=1;
       
    case 'bpodrig4'  %rig6
       OlfIP = [192 168 1 100];
       BankPairOffset = 2;     
       Carrier=2;
              
    case 'ratcortex'
      OlfIP = [192 168 1 110];
      BankPairOffset = 0;  
      Carrier=1;
      
    case 'cnmc17-PC'
      OlfIP = [192 168 1 110];
      BankPairOffset = 0;  
      Carrier=2;
      
 case 'galaxy' %temp replacement for rig3
      OlfIP = [192 168 1 103];
      BankPairOffset = 0;  
      Carrier=1;
      
 case 'kepecslab-PC' %temp replacement for rig3
      OlfIP = [192 168 1 100];
      BankPairOffset = 0;  
      Carrier=1;
      
      
      
%##%
% End hostname cases
    otherwise
            error('Olf IP address NotFound. Please register manually')
        thishost=evalc('system(''hostname'');')
       OlfIp = FindOlfactometer
end