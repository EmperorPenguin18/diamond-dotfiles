#!/bin/bash

eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS="--style full --reverse"
export FZF_CTRL_T_OPTS="--style minimal"
export FZF_CTRL_R_OPTS="--style minimal"
export FZF_ALT_C_OPTS="--style minimal"

_mime-open () #TODO
{
    case "$(file -b --mime-type "$1")" in
        text/plain)
            vim "$1"
            ;;
        *)
            ;;
    esac
}

_mime-preview () #TODO
{
    echo $@
}
export -f _mime-preview

fzf-files ()
{
    local path='.'
    while true; do
        local result="$(find "$path" -depth -maxdepth 1 ! -name "$path" -printf "%f\n" | \
	fzf --preview 'bash -c "_mime-preview {}"')"
	[ -z "$result" ] && break
        case "$(file -b --mime-type "$result")" in
            inode/directory)
                path="$result"
                ;;
            *)
                _mime-open "$result"
                ;;
        esac
    done
}

fzf-apps () #TODO
{
    local list=""
    for file in $(find /usr/share/applications -type f -printf "%p "); do
	local old_ifs="$IFS"
	IFS=$'\n'
	set -- $(sed -n '/^Name=/p;/^Exec=/p;/^Categories=/p' $file | sort -r | cut -f2 -d'=')
	local name="$1"
	local exe="$2"
	local categ="$3"
	[ -z "$categ" ] && categ="None"
	[ -n "$name" ] && [ -n "$exe" ] && \
	list=$(printf "%s\n%s\n%s\n%s" "$list" "$name" "$exe" "$categ")
	IFS="$old_ifs"
    done
    echo "$list" | tail -c+2 | paste -d',' - - - | \
        fzf -d',' --with-nth 1 --accept-nth 2
}
