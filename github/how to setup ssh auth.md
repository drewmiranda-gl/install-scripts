# Adding SSH key to Github profile

This is needed in order to obtain source files from private github repos.

1. Generate key:
    * ssh-keygen -t ed25519 -C "\<github account email address\>"
    * `ssh-add ~/.ssh/id_ed25519`
        * NOTE: your filename may differ. The step above asks to name the file and suggests this filename as a default. However you may have chosen a different name. Be sure to use the filename of the key you created.
        * If you receive error “Could not open a connection to your authentication agent”:
            * <code>eval \`ssh-agent -s\`</code>
2. Obtain public key:
    * `cat ~/.ssh/id_ed25519.pub`
        * NOTE: your filename may differ. The step above asks to name the file and suggests this filename as a default. However you may have chosen a different name. Be sure to use the filename of the key you created.
3. Add key via [https://github.com/settings/keys](https://github.com/settings/keys) using **New SSH key** button
    * Add a key title and paste public key into the Key text box