
function clg
    set filename Wallpapers-(date +%d-%m-%y).log 
    tail -n 50 $argv[1] /home/soufiane/.local/share/chwall/$filename | bat -l log --file-name "$filename"
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

function rkill
    pgrep -x $argv[1] && pkill -USR2 $argv[1]
end

# largest file with it a directory (TODO: or sub-dirctorys)
function bdu
    du -ah $argv[1] | sort -h | tail -n 2 | head -n 1
end

# wipe all disk 
function format
    sudo umount $argv[1] && dd bs=4M if=/dev/zero of=$argv[1] status=progress oflag=sync
end

# if don't want to permanently delete folder
function dl
    mv $argv[1] ~/Trash/
end



if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls

    alias ls 'eza --icons'
    # Aliases
    alias q 'qs -c ii'
    alias c 'clear;fish_greeting'
    alias C 'clear;fish_greeting'
    alias nv 'nvim'
    alias l 'ls --color=auto'
    alias h 'cd ~'
    alias mv 'mv -i' # confirmation
    alias k 'killall -i'
    alias mem 'free -h | bat -l cpuinfo -p'
    #alias clean 'find ~/.local/share/chwall// -type f ! -name "Wallpapers-$(date +%d-%m-%y).log" -delete'
    alias dcn 'sudo systemctl stop iwd && sudo systemctl stop NetworkManager'
    alias upcn 'sudo systemctl start iwd && sudo systemctl start NetworkManager'
    #alias clt 'rm -rI ~/Trash/*'

    # pacman and yay : 
    alias update 'sudo pacman -Syu'
    alias addp 'sudo pacman -S'
    alias addy 'yay -S'
      
    alias delp 'sudo pacman -R'
    alias ddelp 'sudo pacman -Rns'
    alias dely 'yay -R'
    alias ddely 'yay -Rns'

    # weahter alias :  
    alias met 'curl https://wttr.in?format=3'
    alias meta 'curl https://wttr.in/'
    alias suns 'curl wttr.in\?format="%s"' # sunset

    
    # yt-dlp : 
    alias ytvd 'yt-dlp -t mp4 -o "Videos/%(title)s.%(ext)s" --no-keep-video'
    alias ytad 'yt-dlp -x --audio-format mp3 --audio-quality 0'
    alias yt 'yt-dlp -t mp4 --remote-components ejs:npm -o "Videos/%(title)s.%(ext)s" --no-keep-video'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'
    abbr zn 'zen-browser'
    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'
    abbr clear 'c' 
    abbr sw 'swappy -f'
    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
    
    # Custom fish config
    source ~/.config/caelestia/user-config.fish 2> /dev/null
end
