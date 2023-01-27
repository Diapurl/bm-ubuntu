#!/bin/bash

# nach root-Passwort fragen
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# aktualisiere der Paketquellen und des Systems
sudo apt update && sudo apt upgrade -y

# lade installationsdateien vom Webserver in "/tmp/" hreunter
wget -P /tmp/ https://download.diapurl.com/zoom_amd64.deb
wget -P /tmp/ https://download.diapurl.com/zoomcitrixplugin-ubuntu_5.13.1.deb
wget -P /tmp/ https://download.diapurl.com/teams_1.5.00.23861_amd64.deb
wget -P /tmp/ https://download.diapurl.com/icaclient_22.12.0.12_amd64.deb

# fürt die Installationsdateien aus
sudo dpkg -i /tmp/*.deb

# räumt auf
sudo apt autoremove

# erstellt den Nutzer "babymarktnutzer" mit dem Passwort "Babymarkt"
sudo useradd -m babymarktnutzer -p Babymarkt

# füge dem Nutzer die Gruppe "netdev" hinzu, um sich ohne root Rechte mit einem unbekannten Netzwerk verbinden zu können
sudo usermod -a -G netdev babymarktnutzer

# automatische Installation von Sicherheitsupdates durch ändern der Konfigurationsdatei
sudo sed -i 's/^.*"${distro_id} ${distro_codename}-updates";.*$/" "${distro_id} ${distro_codename}-updates";/' /etc/apt/apt.conf.d/50unattended-upgrades

sudo echo "Unattended-Upgrade::Origins-Pattern {
    \"origin=*\";
};" >> /etc/apt/apt.conf.d/50unattended-upgrades

# so kann auch der Nutzer "babymarktnutzer" updates ohne root rechte installieren
sed -i "s/Identity=unix-group:sudo/Identity=unix-group:sudo;unix-user:babymarktnutzer/" /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
