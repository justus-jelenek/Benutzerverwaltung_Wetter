#!/bin/bash

while true; do
clear
echo "
                  Menüpunkte von 0 bis 10 auswählen:

0.Programm beenden
1.Festplattenaufteilung anzeigen
2.Prozessliste anzeigen
3.Dateien mit gesetzten SUID-Bit anzeigen
4.IPv4-Adressen aller Schnittstellen anzeigen
5.Benutzer anlegen
6.Kernel Release-Number anzeigen
7.Uhrzeit und Zeitzone anzeigen
8.Freien und verwendeten Festplattenspeicher des Wurzelverzeichnisses anzeigen 
9.Platzbedarf jedes einzelnen Benutzerverzeichnisses unter /home anzeigen
10.Benutzer entfernen
"
read -p "Bitte die gewünschte Funktion (Zeilennummer) eingeben [1-10] > "

festplatte=$(lsblk)
prozessliste=$(ps aux)
suid_bit=$(find / \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o -perm -u+s -print)
kernel=$(uname -r)
uhrzeit_zeitzone=$(date)
wurzelverzeichnis=$(df -h /)
FILE=/etc/passwd
tail_passwd=$(tail -n 3 -v $FILE)
platzbedarf=$(du -sh /home/*)

declare -A benutzer
benutzer[user1]="alfa"
benutzer[user2]="alfa"
benutzer[user3]="alfa"

case "$REPLY" in
   0)    echo "Programm beendet"
         exit
         ;;
   1)    echo "$festplatte";
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;
   2)    echo "$prozessliste";
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;
   3)    echo "$suid_bit";
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;      
   4)    ip -4 addr show | awk '/inet / {print $2 " " $NF}' | while read -r ip iface; do
    	   echo "Die Schnittstelle $iface hat momentan die Adresse $ip"
         done
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;            
   5)    for name in "${!benutzer[@]}"; do
         if ! grep -q "^$name:" "$FILE"; then
         password="${benutzer[$name]}"
         sudo useradd -m -p "$(openssl passwd -crypt "$password")" "$name"
         echo "User $name added"
         chage -d 0 "$name"
         echo "Password for user $name will expire immediately after the first login."
         else
         echo "User $name already exists"
         fi
         done
         ;;  
   6)    echo "$kernel";
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;    
   7)    echo "$uhrzeit_zeitzone" 
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;
   8)    echo "$wurzelverzeichnis"
	   used=$(echo "$wurzelverzeichnis" | awk 'NR==2 {print $3}')
	   total=$(echo "$wurzelverzeichnis" | awk 'NR==2 {print $2}')
	   avail=$(echo "$wurzelverzeichnis" | awk 'NR==2 {print $4}')
	   percentage=$(echo "$wurzelverzeichnis" | awk 'NR==2 {print $5}')
	   echo "Auf / sind $used von $total belegt. Dies entspricht einer Belegung von $percentage, es sind noch $avail verfügbar."
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;
    9)   echo "$platzbedarf";
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;   
   10)   echo "$tail_passwd"
         read -p "Bitte tragen Sie den Namen ein" username
         read -p "Bist du sicher dass du den Benutzer löschen möchtest $username? (y/n): " confirm
         if [ "$confirm" == "y" ]; then
         sudo userdel -r "$username"
         if [ $? -eq 0 ]; then
         echo "Benutzer $username wurde entfernt"
         else
         echo "Das löschen des Benutzers $username ist fehlgeschlagen"
         fi
         else
         echo "Das löschen des Benutzers $username wurde abgebrochen."
         fi
         ;; 
   *)    echo "Falsche Eingabe. Bitte geben Sie eine Nummer zw. 1 und 10 ein." >&2
         read -p "Zurück zum Hauptmenü. Drücken Sie Enter. "
         ;;
esac                
done

 

