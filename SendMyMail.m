% sends mail from Torben's cshl gmail account
% 3 or  4 inputs: address,subject,message,cell with attachment paths
% (each as string)
function sent = SendMyMail(varargin)

setpref('Internet','E_mail','torben.cshl@gmail.com')
setpref('Internet','SMTP_Server','smtp.gmail.com')
setpref('Internet','SMTP_Username','torben.cshl@gmail.com')
setpref('Internet','SMTP_Password','cshl2358')
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

sent = false;
if length(varargin)==3
    try
        sendmail(varargin{1},varargin{2},varargin{3});
        sent = true;
    catch
        display('Error:SendMyMail:E-Mail could not be sent.');
    end
elseif length(varargin)==4
    try
        sendmail(varargin{1},varargin{2},varargin{3},varargin{4});
        sent = true;
    catch
        display('Error:SendMyMail:E-Mail could not be sent.');
    end
else
    display('Error:SendMyMail:Number of input arguments wrong.');
end