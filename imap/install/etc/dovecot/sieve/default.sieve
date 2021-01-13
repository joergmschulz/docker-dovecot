require "fileinto";

if anyof(
    header :contains ["X-Spam-Flag"] "YES",
    header :contains ["X-Spam"] "Yes",
    header :contains ["Subject"] "*** SPAM ***",
    header :contains "X-Spam_bar" "+++++"
    )
{
  fileinto :create "Junk";
  stop; 
}
