#!/bin/bash
date_formatted=$(date +"%d-%m-%Y-%H:%M")
# enregistrement des actions dans un fichier log
echo "Ajout Utilisateur le :"$date_formatted >> /var/log/accessrights.log
#fichier csv utilisateurs
userfile="Shell_Userlist.csv"
# je supprime les espaces dans le fichier csv
sed -i "s/ //g" $userfile
# lexture fichier ( en sautant la 1ere ligne )
while IFS=',' read -r Id prenom nom password role; do
        username=$nom-$prenom           # Création de l'utilisateur .
        # Vérifie utilisateur existe déjà ( nom )
        user=$(getent passwd "$username") 
        if [[ -n "$user" ]]; then
                echo "L'utilisateur $username/$uid existe déjà." >> /var/log/accessrights.log
                continue # on saute et on passe au suivant
        fi
        # Vérifie utilisateur existe déjà ( uid )
        uid=$(id "$username")
        if [[ -n "$uid" ]]; then
                echo "L'utilisateur $username/$uid existe déjà." >> /var/log/accessrights.log
                continue  # on saute et on passe au suivant
        fi
        # creation de l'utilisateur , avec con groupe par défaut , et mot de passe chiffré en MD5
        useradd -m -s /bin/bash "$username" -c "$nom $prenom" -u $Id -p "$(echo "$password" | openssl passwd -1 -stdin)"
        echo "Création Utilisateur $username avec mot de passe : $password" >> /var/log/accessrights.log

        # Ajoutez l'utilisateur au groupe sudo si le rôle est "Admin"
        if [ "$role" == "Admin" ]; then
                usermod -aG sudo "$username"
                echo "$username est Admin(sudo)" >> /var/log/accessrights.log
        fi
done < <(tail -n +2 $userfile)
echo "#####" >>/var/log/accessrights.log
echo "" >>/var/log/accessrights.log

