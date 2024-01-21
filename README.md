# veracrypt-cli-script

## Description

This Bash script presents a menu to the user with various options for decrypting and mounting VeraCrypt encrypted drives and containers, while on the back-end utilizing the Bitwarden and VeraCrypt command line tools.

Thus it has quite a specific use case, but modify it to your content, i.e. so that it works with your own kind of password manager, and so forth.

Please also be aware that this script is rudimentary and handles sensitive information such as your Bitwarden master password. Do not just trust the script but review it and tailor it to your needs (also read the security section below). 

I don't consider it as completed and it for sure may have problems and bugs. 

The bulk of it was written somewhere during the summer of 2023 so I also can't guarantee the command line tools utilized works exactly the same anymore.

Actually, I don't even use it myself anymore and have defaulted back to using the (more?) intuitive and easy to use GUI versions of the applications instead :)

## Requirements

 In order for the script to work the user will need to: 
 - Have VeraCrypt installed as well as bitwarden-cli.
 - Already be logged in with the terminal command: 'bw login' (thus the user is already 2FA verified and 'bw get password MYPASS' can be used by the script).
 - Enter her/his Bitwarden master password.                         
 - Know the name in Bitwarden of the password entry for the VeraCrypt device/container (e.g. "myencryptedcontainer1" or such).
 - Know the name of the device/container on her/his local machine (the user will get a list of possible suggestions).

## Security

The Bitwarden master password will be entered silently by the user.

In the main menu the user is also given the choice (option number 4) to store the Bitwarden master password as a global variable for the duration that the rest of the script is running. This is convenient as it won't have to be entered again if many decryptions are to be performed, but hypothetically would give more time for an attacker to extract the password from memory.

If this option is used it also would be more important to remember to exit the script after working with it so that the value gets cleared from memory.

If the user omits this option, the variable holding the password will be requested from the user and stored more closely to where it's actually used (the decryption operation), and will then manually be unset by the script immediately after it has been used.

Again please review the script and tailor it to your needs.

## Future improvements

- Review the script and make sure it still even works.
- Improve regex to include ~/'container'
- Implement timeout for password memory storage 
- Clean up possibly redundant echo statements
- Implement unmount function
- Finish and implement the commented out hidden container function
