function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting
    hyfetch
    # Use starship
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    alias c 'clear'
    alias C 'clear'
    alias nv 'nvim'
    alias l 'ls'

    # pacman and yay : 
    alias addp 'sudo pacman -S'
    alias addy 'yay -S'
    alias delp 'sudo pacman -R'
    alias dely 'yay -R'

    # weahter alias :
    
    alias met 'curl wttr.in?format=3'
    alias meta 'curl wttr.in/'
    alias suns 'curl wttr.in\?format="%s"' # sunset


    # yt-dlp : 
    alias ytvd 'yt-dlp -t mp4 -o "Videos/%(title)s.%(ext)s" --no-keep-video'
    alias ytad 'yt-dlp -x --audio-format mp3 --audio-quality 0'
    alias yt 'yt-dlp -t mp4 --remote-components ejs:npm -o "Videos/%(title)s.%(ext)s" --no-keep-video'

end



