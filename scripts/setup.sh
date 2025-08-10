#!/bin/bash
set -e

# Installation directory
PIOSK_DIR="/opt/MediaKiosk"

RESET='\033[0m'      # Reset to default
ERROR='\033[1;31m'   # Bold Red
SUCCESS='\033[1;32m' # Bold Green
WARNING='\033[1;33m' # Bold Yellow
INFO='\033[1;34m'    # Bold Blue
CALLOUT='\033[1;35m' # Bold Magenta
DEBUG='\033[1;36m'   # Bold Cyan

echo -e "${INFO}Checking superuser privileges...${RESET}"
if [ "$EUID" -ne 0 ]; then
  echo -e "${DEBUG}Escalating privileges as superuser...${RESET}"

  sudo "$0" "$@" # Re-execute the script as superuser
  exit $?  # Exit with the status of the sudo command
fi

echo -e "${INFO}Configuring autologin...${RESET}"
if grep -q "autologin" "/etc/systemd/system/getty@tty1.service.d/autologin.conf" 2>/dev/null; then
  echo -e "${SUCCESS}\tautologin is already enabled!${RESET}."
else
  if command -v raspi-config >/dev/null 2>&1; then
    echo -e "${DEBUG}Enabling autologin using raspi-config...${RESET}"
    raspi-config nonint do_boot_behaviour B4
  else
    echo -e "${ERROR}Could not enable autologin${RESET}"
    echo -e "${ERROR}Please configure autologin manually and rerun setup.${RESET}"
  fi
  echo -e "${SUCCESS}\tautologin has been enabled!${RESET}"
fi

echo -e "${INFO}Installing dependencies...${RESET}"
apt install -y git wtype apache2 libapache2-mod-php



echo -e "${INFO}Cloning repository...${RESET}"
rm -R "$PIOSK_DIR" || echo "No dir. That's good!"
git clone https://github.com/szymonixo/mediakiosk.git "$PIOSK_DIR"
cd "$PIOSK_DIR"

#git checkout "d586dfa833187df34de8e8345b85c8d27be8bdc9"

# echo -e "${INFO}Checking out latest release...${RESET}"
# git checkout devel
# git checkout $(git describe --tags $(git rev-list --tags --max-count=1))


echo -e "${INFO}Installing MediaKiosk services...${RESET}"
PI_USER="$SUDO_USER"
PI_SUID=$(id -u "$SUDO_USER")
PI_HOME=$(eval echo ~"$SUDO_USER")
sed -e "s|PI_HOME|$PI_HOME|g" \
    -e "s|PI_SUID|$PI_SUID|g" \
    -e "s|PI_USER|$PI_USER|g" \
    "$PIOSK_DIR/services/mediakiosk-runner.template" > "/etc/systemd/system/mediakiosk-runner.service"
sed -e "s|DocumentRoot /var/www/html|DocumentRoot /etc/MediaKiosk|" \
    "/etc/apache2/sites-available/000-default.conf"

sed -e "s|xdg-autostart = lxsession-xdg-autostart|xdg-autostart = lxsession-xdg-autostart|" \
    "/etc/apache2/sites-available/000-default.conf"

chmod +x $PIOSK_DIR/scripts/runner.sh

echo -e "${INFO}Reloading systemd daemons...${RESET}"
systemctl daemon-reload

echo -e "${INFO}Enabling MediaKiosk daemons...${RESET}"
systemctl enable apache2
systemctl enable mediakiosk-runner


echo -e "${INFO}Starting MediaKiosk daemons...${RESET}"
# The runner and switcher services are meant to be started after reboot
# systemctl start piosk-runner
# systemctl start piosk-switcher
systemctl start apache2

echo -e "${INFO}Changing backgrounds..."

rm /usr/share/plymouth/themes/pix/splash.png
cp $PIOSK_DIR/default/sda.png /usr/share/plymouth/themes/pix/splash.png

rm "$SUDO_USER/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"
cp $PIOSK_DIR/default/desktop-items-0.conf "~/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"


echo -e "${CALLOUT}\nMediaKiosk is now installed.${RESET}"
echo -e "Visit either of these links to access PiOSK dashboard:"
echo -e "\t- ${INFO}\033[0;32mhttp://$(hostname)/${RESET} or,"
echo -e "\t- ${INFO}http://$(hostname -I | cut -d " " -f1)/${RESET}"
echo -e "Configure links to shuffle; then apply changes to reboot."
echo -e "${WARNING}\033[0;31mThe kiosk mode will launch on next startup.${RESET}"
