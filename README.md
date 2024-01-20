# veracrypt-cli-script

## Description

This script presents a menu to the user with various options for decrypting and mounting VeraCrypt encrypted drives and containers, while on the back-end utilizing the Bitwarden and VeraCrypt command line tools.

Thus it has quite a specific use case, but modify it to your content.

Altough, I don't even use it myself anymore and have defaulted to using the (more?) intuitive and easy to use GUI versions of the applications instead :)

## Requirements

 In order for the script to work the user will need to: 
 - Have VeraCrypt installed as well as the bitwarden-cli.                                                                                                                          
 - Already be logged in with the terminal command: 'bw login' (thus the user is already 2FA verified and 'bw get password MYPASS' can be used by the script).
 - Enter her/his Bitwarden master password.                                                                                                                                        
 - Know the name in Bitwarden of the password entry for the VeraCrypt device/container (e.g. "myencryptedcontainer1" or such).
 - Know the name of the device/container on her/his local machine (the user will get a list of possible suggestions).                                                           

## Future improvements

- Improve regex to include ~/'container'
- Implement timeout for password memory storage 
- Clean up reduntant echo statements
- Implement unmount function
- Finish the hidden container function
