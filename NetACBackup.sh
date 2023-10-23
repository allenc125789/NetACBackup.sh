#!/bin/bash
trap "" SIGTERM SIGINT && clear

#   ####: README/Summary.
    #: "NetACBackup". Created by Allen Carson.

    #: "REQUIRED" Packages: rsync; gpg; tar

    #: Optional: for use as a NAS: sshfs (or) samba

    #: A one-click script using basic bash commands and minimal external packages, for file/folder specific backups.\
    #: After copying, it creates an ecrypted archive of its contents. Can be started automatically with crontab, or\
    #: by starting this program manually.

    #: Script must have a first time run to create necessary files and profiles.

    #: No root access needed for functionality.

    #: "WARNING": Passwords stored inside this program are in "PLAIN-TEXT", located in their profile folders. Despite\
    #: the security aspects, I chose this for a few benefits: I want the program's admin to be able to manage\
    #: their own passwords as they see fit, without being locked down to my program. And to distribute that password\
    #: to the appropriate user. Passwords may be updated in the future to support keys instead in order to have\
    #: a middle ground between Security and Accessibility.



#   ####: Instructions.
    #: (1) Installation: Place file in desired location on your system. That's it!

    #: (2) Configuartion: Below you will find the Configuration section. Go through it and edit it as needed.

    #: (3) Start: Launch the program using bash. You will be prompted with an options menu. Select Create-User and follow\
    #: the prompts to create a profile.

    #: (3a) After a profile is created, you will need to edit it's Backup.list file manually outside the program. This\
    #: file can contain the paths to desired files/folders to backup.

    #: (4) Finished: After setting Backup.list, you may start the program.

    #: (NOTE) If you set your profile as a Mapped Drive, you set the start your root (/) at the derictory you are mapped to.\
    #: (EXAMPLE) if you backup a remote directory that has a local path of /home/John, and all the directories inside /John/,\
    #: then you just need to list / in your Backup(NET).list file.


    #: [fstab Example (sshfs)]: sshfs#Hostname@192.168.0.1:/Example/Dir /your/sNETPATH/ProfileName fuse uid=1000,gid=1000,default_permissions,allow_other,reconnect,x-systemd.automount,defaults,_netdev 0 0



#   ####: Configuration

    #: Comment out below to turn off logo.
echo -e "  _   _      _        _    ____   ____             _                \n | \ | | ___| |_     / \  / ___| | __ )  __ _  ___| | ___   _ _ __  \n |  \| |/ _ \ __|   / _ \| |     |  _ \ / _' |/ __| |/ / | | | '_ \ \n | |\  |  __/ |_   / ___ \ |___  | |_) | (_| | (__|   <| |_| | |_) |\n |_| \_|\___|\__| /_/   \_\____| |____/ \__,_|\___|_|\_\\__,__| .__/ \n                                                             |_|    \n\n\n\n\n"

    #: Mapped drive/files to backup. (NO DEFAULT, please set and uncomment and set your Mapped Drive path!! (Example: /media/shares/PC-Home-JohnDoeExample))
#sNETPATHS=

    #: Backup cache Directory. (Default is: $HOME)
sBACKUPDIR=$HOME

    #: Configuration Directory. (Default is: $HOME"/.local/share/NetACBackup")
sCONFIGDIR=$HOME"/.local/share/NetACBackup"

    #: User Files Directory.
mkdir -p  $sCONFIGDIR"/Users"
sUSERFILES=$sCONFIGDIR"/Users"

    #: Encryption Directory
mkdir -p $sCONFIGDIR"/Encrypted-Files"
sENCRYPTEDDIR=$sCONFIGDIR"/Encrypted-Files"

    #: Timer before fAUTOBACKUP starts processing. (Change as needed. (Default is: 20))
iBACKUPTIMER="20"

    #: Timer before the Menu and Program exits. (Change as needed. (Default is: 20))
iMENUTIMER="20"

    #: Colored Text for Event messages.
sSUCCESS=" ((\033[0;32mSUCCESS\033[0m)) "
sWARNING=" ((\033[1;33mWARNING\033[0m)) "
sERROR=" ((\033[0;31mERROR\033[0m)) "

    #: Value to determine when to break the script bodies loop. (DO NOT CHANGE.)
iEXIT="0"


#   ####: Functions.
    #: Variable (ls) for User Profile reference
faUSERFILES()
{
aFILES=$( ls $sUSERFILES )
for i in "${aFILES}"; do
    echo "$i"
done
}



    #: Provides at the moment Date and Time.
fDATENOW()
{
date "+%D|%T"
}

fDATENOW2()
{
date "+%m-%d-%Y"
}



    #: Detects profiles in the Users folder
fUSERDETECT()
{
aUSERFILES=$( (faUSERFILES) )
if [[ "" =~ ^"$aUSERFILES"$ ]]; then
    sNEWUSER=("PC-Home-JohnDoeExample")
    mkdir -p $sUSERFILES/$sNEWUSER
    touch $sUSERFILES/$sNEWUSER/.$sNEWUSER"credentials"
    echo "ExamplePassword12345" > $sUSERFILES/$sNEWUSER/.$sNEWUSER"credentials" && sCREDS=$() && sVCREDS=()
    touch $sUSERFILES/$sNEWUSER/Backup.list
    echo -e "- "$sWARNING" No User profiles detected!! Please create one via the options menu. An example of a profile has been made in ("$sUSERFILES") for reference. Please use this, or create a User profile in the Options Menu. The program will now boot directly into the Automatic Backup-Process when launched. \n"
    echo -e "\n- "$sSUCCESS $sNEWUSER" created!\n"
    echo -e "/Paths/to/Files-or-Folders/go/here/like/this.jpg (Do not add trailing forward slashes (/))" > $sUSERFILES/$sNEWUSER/Backup.list
    echo -e "\n- Please replace the contents of the file at "$sUSERFILES"/"$sNEWUSER"/Backup.list with desired file paths.\n"
else
    fDATENOW && echo -e "(__Backup__)" && fAUTOBACKUP
fi
}



    #: Menu for program options.
fMENULIST()
{
echo -e "\n\n\n\n"
fDATENOW
echo -e "(__Menu__)\n"
echo -e "- Please select an option. Program will automatically Exit in "$iMENUTIMER" seconds...\n"
echo -e "1)Start-Backup-Process\n2)Create-User\n3)Delete-User\n4)Help\n5)Exit\n"
read -r -s -n 1 -t $iMENUTIMER sMENUITEM || sMENUITEM="5"
if [[ $sMENUITEM == "1" ]]; then
    echo -e "\n\n\n\n"
    fDATENOW
    echo -e "(__Backup__)"
    fAUTOBACKUP
elif [[ $sMENUITEM == "2" ]]; then
    echo -e "\n\n\n\n"
    fDATENOW
    echo -e "(__Create-User__)"
    fCREATEUSER
elif [[ $sMENUITEM == "3" ]]; then
    echo -e "\n\n\n\n"
    fDATENOW
    echo -e "(__Delete-User__)"
    fDELETEUSER
elif [[ $sMENUITEM == "4" ]]; then
    echo -e "\n\n\n\n"
    fDATENOW
    echo -e "(__Help__)"
    fHELP
elif [[ $sMENUITEM == "5" ]]; then
    echo -e "\n\n\n\n"
    fDATENOW
    fEXIT
else
    echo -e "\n\n\n\n"
    fDATENOW
    fEXIT
fi
}



    #: Backup Process.
fBACKUPPROC()
{
sDATENOW=$(fDATENOW2)
aUSERFILES=$(faUSERFILES)
for sUSER in ${aUSERFILES[@]}; do
    echo $sUSER
    mkdir $sUSER
    while IFS= read -r sLINE0; do
        rsync -a -r -v -d -P "$sLINE0" "$sBACKUPDIR/$sUSER" --mkpath --ignore-errors
        cp "$sUSERFILES"/"$sUSER"/Backup.list "$sBACKUPDIR"/"$sUSER"
    done < $sUSERFILES/$sUSER/Backup.list
done
for sUSER in ${aUSERFILES[@]}; do
    echo $sUSER
    mkdir $sUSER
    while IFS= read -r sLINE0; do
        rsync -a -r -v -d -P "$sNETPATHS/$sUSER""$sLINE0" "$sBACKUPDIR/$sUSER" --mkpath --ignore-errors
        cp "$sUSERFILES"/"$sUSER"/Backup.list "$sBACKUPDIR"/"$sUSER"
    done < $sUSERFILES/$sUSER/BackupNET.list
done
    #: Archive/Compress Folders.
for sUSER in ${aUSERFILES[@]}; do
    fDATENOW
    echo -e "\n- Compressing $sUSER Backups...\n"
    if tar -c -f "$sUSERFILES"/"$sUSER"/"$sUSER-$sDATENOW.tar.gz" "$sBACKUPDIR"/"$sUSER"; then
        echo -e "\n"
        fDATENOW
        echo -e "\n- "$sSUCCESS"\n"
     else
        echo -e "\n"
        fDATENOW
        echo -e "\n- "$sERROR"Compression failed...\n"
        break
    fi

    #: Remove old gpg files.
    rm "$sENCRYPTEDDIR/$sUSER/"*.gpg

    #: Create new gpg file.
    echo -e "\n"
    fDATENOW
    echo -e "\n- Encrypting Backups with $sUSER password...\n"
    if gpg --batch --passphrase-file "$sUSERFILES/$sUSER/.$sUSER.creds" --output "$sENCRYPTEDDIR/$sUSER/$sUSER-$sDATENOW.tar.gz.gpg" --symmetric "$sUSERFILES/$sUSER/$sUSER-$sDATENOW.tar.gz"; then
        rm "$sUSERFILES"/"$sUSER"/"$sUSER"*.gz
        echo -e "\n"
        fDATENOW
        echo -e "\n- "$sSUCCESS"\n"
    else
        echo -e "\n"
        fDATENOW
        echo -e "\n- "$sERROR"Encryption failed...\n"
        continue
    fi
done
}



    #: Backup Countdown.
fAUTOBACKUP()
{
echo -e "\n- Backup-Automation active.\n- Counting down from "$iBACKUPTIMER", press any key to interrupt... (Goes to Options before Exit.)\n"
read -r -s -n 1 -t $iBACKUPTIMER sINPUT || sINPUT="START"
if [[ $sINPUT == "START" ]]; then
    fDATENOW && echo -e "\n- Starting Backup-Process...\n"
    fBACKUPPROC
else
    fDATENOW && echo -e "\n- Stopped.\n"
fi
}



    #: Create User Option.
fCREATEUSER()
{
while true; do
    aUSERFILES=$(faUSERFILES)
    iNETPROFILE=0
    sSTOP=false
    echo $aUSERFILES
    echo -e "\n\n- Creating a new user. Please type in your Name/User/Drive to label your backup profile. (Or type Exit to exit to the Menu): "
    IFS= read sNEWUSER

    #: Filtering for acceptable Profle Names.
    case $sNEWUSER in
    *[[:space:]]* | *[[:blank:]]* | *[[:cntrl:]]* | *['!&()`[]{}<>?/\|'@#$%^*_+.]* |\
    *[['?^[[A']]* | *[['?^[[B']]* | *[['?^[[C']]* | *[['?^[[D']]*)
        echo -e "\n- "$sWARNING" Uh oh, Spaghetti-Os!! User already exists or is invalid. Please select a different name.\n"
        continue
        ;;
    "exit" | "Exit")
        break
        ;;
    *)
        for sPROFILE in ${aUSERFILES[@]}; do
            case $sPROFILE in
            $sNEWUSER)
                echo -e "\n- "$sWARNING" Uh oh, Spaghetti-Os!! User already exists or is invalid. Please select a different name.\n"
                sSTOP=true
                ;;
            *)
                :
                ;;
            esac
        done
        if [[ $sSTOP == true ]]; then
            continue
        else

    #: Check if user is on a Mapped Drive
            read -n 2 -p $'Set '$sNEWUSER' as a Mapped Drive? (Y/N):' sCONFIRMATION
            case $sCONFIRMATION in
                y|Y)
                    iNETPROFILE=1
                ;;
                n|N)
                ;;
            esac



    #: Create Password.
            IFS= read -s -p $'\n- Password for '$sNEWUSER$': \n' sCREDS && echo -e "\n"

    #: Verify Pass and create profile.
            IFS= read -s -p $'\n- Please retype to verify the password: \n' sVCREDS && echo -e "\n"
            if [[ $sCREDS == $sVCREDS && $iNETPROFILE == "0" ]]; then
                mkdir -p $sUSERFILES/$sNEWUSER
                mkdir -p $sENCRYPTEDDIR/$sNEWUSER
                mkdir -p $sBACKUPDIR/$sNEWUSER
                touch $sUSERFILES/$sNEWUSER/.$sNEWUSER".creds"
                echo $sVCREDS > $sUSERFILES/$sNEWUSER/.$sNEWUSER".creds" && sCREDS=$() && sVCREDS=()
                touch $sUSERFILES/$sNEWUSER/Backup.list
                echo -e "#/Paths/to/Files-or-Folders/go/here/like/this.jpg (Do not add trailing forward slashes (/))\n" > $sUSERFILES/$sNEWUSER/Backup.list
                nano $sUSERFILES/$sNEWUSER/Backup.list
                echo -e "\n- "$sSUCCESS $sNEWUSER" created!\n"
            elif [[ $sCREDS == $sVCREDS && $iNETPROFILE == "1" ]]; then
                mkdir -p $sNETPATHs/$sNEWUSER
                mkdir -p $sUSERFILES/$sNEWUSER
                mkdir -p $sENCRYPTEDDIR/$sNEWUSER
                mkdir -p $sBACKUPDIR/$sNEWUSER
                touch $sUSERFILES/$sNEWUSER/.$sNEWUSER".creds"
                echo $sVCREDS > $sUSERFILES/$sNEWUSER/.$sNEWUSER".creds" && sCREDS=$() && sVCREDS=()
                echo -e "#/Paths/to/Files-or-Folders/go/here/like/this.jpg (Do not add trailing forward slashes (/))\n" > $sUSERFILES/$sNEWUSER/BackupNET.list
                nano $sUSERFILES/$sNEWUSER/Backup.list
                echo -e "\n- "$sSUCCESS $sNEWUSER" created!\n"
            else
                echo -e "\n"$sWARNING"- Passwords did not match.\n" && sCREDS=$() && sVCREDS=()
                continue
            fi
            continue
        fi
        ;;
    esac
done
}



    #: Delete User Option.
fDELETEUSER()
{
iEXIT=1
while [ $iEXIT == "1" ]; do
    aUSERFILES=$(faUSERFILES)
    echo -e "\n- Please select the profile you would like to DELETE (or select .Exit to exit to menu)\n"
    select sUSER in ".Exit" $aUSERFILES; do
        sSTOP=false
        case $sUSER in
            ".Exit")
                iEXIT=0
                break
                ;;
            *)
                case $sUSER in
                    $aUSERFILES)
                        :
                        ;;
                    "")
                            echo -e "\n- "$sWARNING" No profile selected. Select an available name or select .Exit\n"
                            sSTOP=true
                        ;;
                    esac
            if [[ $sSTOP == true ]]; then
                continue
            else
                sCURRENTUSER=($sUSER)
                read -n 2 -p $sCURRENTUSER" selected... Are you sure You want to delete this User profile? (Y/N)" sCONFIRMATION
                case $sCONFIRMATION in
                    y|Y)
                        rm -r $sUSERFILES/$sCURRENTUSER
                        rm -r $sENCRYPTEDDIR/$sCURRENTUSER
                        rm -r $sBACKUPDIR/$sCURRENTUSER
                        echo -e "\n- "$sSUCCESS", "$sCURRENTUSER" profile was deleted.\n"
                        break
                    ;;
                    n|N)
                    ;;
                esac
            fi
            ;;
        esac
    done
done
}



    #: Help/Info Option.
fHELP()
{
echo -e "\n- You'll find most information on this program in it's README/Summary and Instructions section of the scriptat the beginning of the file. To report issues, commits, and other ways this program can be improved, please refer to my git at XXX.\n\n"\
"- Configuration Directory: ("$sCONFIGDIR"). You'll find the config files for individual Users here, including their directory list files, and gpg credentials. To change the Configuration Directory, edit this program, change the 'sCONFIGDIR' variable to the desired path.\n\n"\
"- Backup Directory: ("$sBACKUPDIR"). You'll find all the files selected for the backup list, and their encrypted gpg archive categorized here. To change the Backup Directory, edit this program, change the 'sBACKUPDIR' variable to the desired path.\n\n"\
"- To change the Countdown Timer Delay for the Auto-Backup function, edit this program, and change the 'iBACKUPTIMER' variable.\n\n"
}



    #: Cleanup and Exit.
fEXIT()
{
iEXIT=$((1))
echo -e "\n- Finished and exiting.\n"
}



#   ####: Basic loop for summoning the menu and keeping user files updated. -
#         Starts the backup sequence. If canceled, it will exit to an options menu with a timeout.
fUSERDETECT
while [[ "0" = $iEXIT ]]; do
    fMENULIST
done
