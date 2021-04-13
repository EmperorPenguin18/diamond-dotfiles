set -x MANPAGER "nvim -c 'set ft=man' -"

function vim --description 'Old habits die hard'
        nvim $argv
end
function unrar --description 'Old habits die hard'
        bsdtar -xvf $argv
end
function unzip --description 'Old habits die hard'
        bsdtar -xvf $argv
end
function zip --description 'Old habits die hard'
        bsdtar -a -cvf $argv
end

function feh --description 'Feh does not have a config file so...'
        command feh -Z -F -B black --conversion-timeout 1 --cache-size 2048 $argv
end
function mpv --description 'Swallow mpv windows'
        command devour mpv $argv
end
function zathura --description 'Swallow zathura windows'
        command devour zathura $argv
end

function ls --description 'Improve directory listing'
        clear
        lsd $argv
end
function chpwd --on-variable PWD --description 'List the directory when changing'
        status --is-command-substitution; and return
        lsd
end

function cp --description 'Make any directories needed when copying'
        set DEST (echo $argv | awk '{print $NF}')
        echo $DEST | grep -o '/' > /dev/null; and mkdir -p (echo $DEST | cut -f -(echo $DEST | grep -o '/' | wc -l) -d '/')
        command cp $argv
end
function mv --description 'Make any directories needed when moving'
        set DEST (echo $argv | awk '{print $NF}')
        echo $DEST | grep -o '/' > /dev/null; and mkdir -p (echo $DEST | cut -f -(echo $DEST | grep -o '/' | wc -l) -d '/')
        command mv $argv
end



function fish_prompt --description 'Write out the prompt'
        set -l last_pipestatus $pipestatus
        set -l normal (set_color normal)
        
        # Color the prompt differently when we're root
        set -l color_cwd $fish_color_cwd
        set -l prefix
        set -l suffix '$'
        if contains -- $USER root toor
                if set -q fish_color_cwd_root
                        set color_cwd $fish_color_cwd_root
                end
                set suffix '#'
        end
        
        # Write pipestatus
        set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)
        
        echo -n -s (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal $prompt_status $suffix " "
end

function help --description 'Teach how to use the terminal'
        command help $argv
end
