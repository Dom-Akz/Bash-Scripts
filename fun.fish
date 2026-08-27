function clg
    set filename Wallpapers-(date +%d-%m-%y).log 
    tail -n 50 $argv[1] /home/soufiane/.local/share/chwall/$filename | bat -l log --file-name /home/soufiane/.local/share/chwall/$filename
end

# show the password of the current network connection
# -s : show the secret password (hiiddne)
function psk
   nmcli conn show $argv[1] -s | grep -m 1 "802-11-wireless-security.psk" | awk '{print $NF}' 
end

# long du 
# go the directory and get all disque usage of all the files or sub-dirctorys
function ldu --description "print disque usage of all files and sub-dirctorys"  
    du -cha $argv[1] | sort -h
end

# remove a path from the global PATH 
function rmp
    set PATH (string match -v $argv[1] $PATH)
end

# add path to $PATH
function adp
   set -U fish_user_paths $argv[1]
end

# search process
function p 
    ps aux | grep $argv[1]
end

# dir owner
function own
    ls -ld $argv[1] | awk '{print $3}'
end

# find all process (by name) and kill all instance
function rkill
    pgrep -f $argv[1] && pkill -USR2 -f $argv[1] &&  systemctl --user stop Wallpapers.service 
end

# largest file with it a directory (TODO: or sub-dirctorys)
function bdu
    du -ah $argv[1] | sort -h | tail -n 2 | head -n 1
end


# if don't want to permanently delete folder
function dl
    mv $argv[1] ~/Trash/
end

# list content sort by last changed
function lsc
    ls -r -s=changed $argv[1]
end

# convert to pdf
function topdf
    libreoffice --headless --convert-to pdf $argv[1] --outdir $argv[2]
end


function enc
     openssl enc -aes-256-cbc -pbkdf2 -in $argv[1] -out $argv[2] 
end

function dec
     openssl enc -d -aes-256-cbc -pbkdf2 -in $argv[1] -out $argv[2] 
end

function errg
    rkill "Wallpapers.sh" && caelestia Wallpapers -f "/home/soufiane/Pictures/WALL/walls/astronaut.png"
end
