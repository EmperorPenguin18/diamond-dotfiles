# diamond-dotfiles

**NOT READY FOR USE**

Desktop dotfiles plus script to set it up

Designed to completely automate setting up the computer, so that it can be deployed on a new system without any interaction from the user. This way there is no need to fiddle around in graphical settings menus everytime you want to setup your workflow

### Features:
- Connect any cloud storage
- Automated updates and backups
- Supports all three GPU brands (Nvidia, AMD, Intel)
- Keyboard-centric workflow
- Spotifyd controlled with media keys
- Privacy focused Firefox setup

### How to use:
1. Must be run on a fresh Arch install created by my linux-installer script.
2. Run this command as root user:
```
curl -sL https://raw.github.com/EmperorPenguin18/diamond-dotfiles/master/setup.sh | sh
```
4. Answer prompts. Not designed to be user friendly.
5. Wait for installation to complete.
6. Make sure to reboot when the script finishes so everything is set properly.
7. Press Super+s once in spectrwm to see all shortcuts.
8. Use `help` in the terminal to learn how to use the terminal.
9. Run `rclonewrapper {service file}` substituting the provided rclone.service file (if you want cloud storage).

### Future:
- Multiple rices to choose from
- User-agnostic dotfiles
- Dash as script shell
- Multi-monitor
- Gaming from the couch
- Support more distros
- More minimal

Yes this is a JoJo reference.
