# ensure set user variables are defined
uid="${uid:-}"
user="${user:-}"
gecos="${gecos:-}"
gid="${gid:-}"
group="${group:-}"

#
# Tries to set empty uid and gid values using the owner and group of the
# specified filename. uid will not be set if the file is owned by "uid=0(root)",
# gid will not be set if the file group is "gid=0(root)" or "gid=10(wheel)".
#
# @param $1 filename
#
set_user_vars_from_path () {
    local filename=$1
    local conf_uid_gid=$(ls -dn "$filename" 2>/dev/null | awk '{ print $3, $4 }')
    local conf_uid=$(echo $conf_uid_gid | tr ' ' $'\n' | head -n1)
    local conf_gid=$(echo $conf_uid_gid | tr ' ' $'\n' | tail -n1)

    if [[ "${conf_uid:-0}" -gt 0 ]]; then
        uid="${uid:-$conf_uid}"
    fi

    if [[ "${conf_gid:-0}" -gt 0 ]] && [[ "$conf_gid" -ne 10 ]]; then
        gid="${gid:-$conf_gid}"
    fi
}

set_user_vars_from_home () {
    # detect the home folder, mac os path /Users has priority
    local home_path=$(ls -d1 /Users/* 2>/dev/null; ls -d1 /home/* 2>/dev/null | grep -vE '/www-data$' | head -n1)
    if [[ "$home_path" == "" ]]; then
        return
    fi

    # set empty user and group from the detected home directory name
    set_user_vars_from_path "$home_path"

    # set empty user from the detected home directory name
    user="${user:-$(basename "$home_path")}"
}

#
# Tries to set empty uid and gid values using the guessed host os
# defaults. This assumption is made by querying for the existence of
# "docker.for.mac.localhost" and that the user has the default uid and gid
# for their respective OS.
#
# group will be set if empty and Mac OS is detected.
#
# Mac OS:  uid=501(andrew) gid=20(staff)
# Default: uid=1000(andrew) gid=1000(andrew)
#
set_user_vars_from_host () {
    local is_docker_for_mac=$(nslookup docker.for.mac.localhost >/dev/null 2>&1; expr 1 - $?)

    if [[ "$is_docker_for_mac" -eq 1 ]]; then
        uid="${uid:-501}"
        gid="${gid:-20}"
        group="${group:-staff}"
    else
        uid="${uid:-1000}"
        gid="${gid:-1000}"
    fi
}

#
# Renames or creates a group based on the gid.
#
rename_or_create_group () {
    local current_group=$(awk -F ':' "\$3 == $gid { print \$1 }" /etc/group)
    local current_user=$(awk -F ':' "\$3 == $uid { print \$1 }" /etc/passwd)

    group=${group:-${current_group:-${user:-${current_user:-alpine}}}}

    if [[ "$current_group" != "" ]]; then
        if [[ "$current_group" != "$group" ]]; then
            sed -i -E "s/^[a-z0-9_]+:x:$gid:/$group:x:$gid:/" /etc/group
            sed -i -E "s/([:,])$current_group\b/\1$group/" /etc/group
        fi
    else
        addgroup -g $gid $group
    fi
}

#
# Creates a user and assigns them to the wheel group. The home directory will
# not be created if it's been added as a volume or a mount for /Users/$user
# exists. In the latter case a symlink is created at /home/$user.
#
create_user_if_not_exists () {
    local current_user=$(awk -F ':' "\$3 == $uid { print \$1 }" /etc/passwd)

    user=${user:-${current_user:-alpine}}

    if [[ "$current_user" != "" ]]; then
        if [[ "$current_user" != "$user" ]]; then
            echo "Cannot create user $user, conflict: uid=$uid($current_user)" >&2
            exit 1
        fi
        return
    fi

    local skip_create_home_dir=""

    if [[ -d "/Users/$user" ]] || [[ -d "/home/$user" ]]; then
        skip_create_home_dir="-H"
    fi

    adduser -g "$gecos" -s /bin/sh -G $group -D $skip_create_home_dir -u $uid $user
    adduser $user wheel

    # "unlock" the account or ssh won't work
    echo "$user:" | chpasswd 2>&1 >/dev/null

    if [[ -d "/Users/$user" ]] && [[ ! -d "/home/$user" ]]; then
        ln -s "/Users/$user" "/home/$user"
    fi
}

#
# Detects osxfs local volume mounts within the container and modifies the user
# and group of each one. If a home directory is detected each parent directory
# will be chowned.
#
fix_osxfs_local_volume_permissions () {
    local OFS=$IFS
    local path

    IFS=$'\n'

    for path in $(mount | sed -E 's/^osxfs on (.+?) type fuse.osxfs.+/\1/;t;d'); do
        chown -h $user:$group "$path" >/dev/null

        while `echo "$path" | grep -q -E "^/home/.+?/."`; do
            path=$(echo "$path" | sed -E 's#/[^/]+$##')
            chown -h $user:$group "$path"
        done
    done

    IFS=$OFS
}

# try to create a user with the same uid and gid as the host
{
    # sets empty uid, user and gid by scanning home dirs
    set_user_vars_from_home

    # sets empty uid and gid from /opt/project if not owned by root:wheel
    set_user_vars_from_path "/opt/project"

    # sets empty uid, gid (and group on mac os) by guessing the host
    set_user_vars_from_host

    # create the user and add them to the wheel group to grant sudo access
    rename_or_create_group
    create_user_if_not_exists

    # osxfs local volumes may require owner:group changes
    fix_osxfs_local_volume_permissions
} \
    >/dev/null

# cleanup environment variables
export user

unset uid gid group
