#!/usr/bin/env bash
shopt -s nullglob

QD_DIR=""; QD_UNIT_DIR=""; QD_KEEP=" "

qd_keep() {
    local unit="$1"
    QD_KEEP+="$unit "
}

qd_init() {
    local app_name="$1"
    QD_DIR="$HOME/.config/containers/systemd/$app_name"
    QD_UNIT_DIR="$HOME/.config/systemd/user"
    QD_KEEP=" "
    mkdir -p "$QD_DIR" "$QD_UNIT_DIR"
}

qd_link_dir() {
    local source_dir="$1"
    local quadlet_path target_path quadlet target
    for quadlet_path in "$source_dir"/*.container "$source_dir"/*.network; do
        quadlet="$(basename "$quadlet_path")"
        qd_keep "$quadlet"
        ln -sf "$quadlet_path" "$QD_DIR/$quadlet"
    done
    for target_path in "$source_dir"/*.target; do
        target="$(basename "$target_path")"
        qd_keep "$target"
        ln -sf "$target_path" "$QD_UNIT_DIR/$target"
    done
}

qd_link_instance() {
    local template_unit="$1"
    local instance_unit="$2"
    qd_keep "$instance_unit"
    ln -sf "$template_unit" "$QD_DIR/$instance_unit"
}

qd_link_conf() {
    local conf_path="$1"
    local instance_unit="$2"
    local dropin_dir="$QD_DIR/$instance_unit.d"
    local component_name="${instance_unit%%@*}"
    qd_keep "$instance_unit.d"
    mkdir -p "$dropin_dir"
    ln -sfn "$conf_path" "$dropin_dir/$component_name.conf"
}

qd_sweep() {
    # podman >= 6 (--application): this whole block collapses to
    #   quadlet rm --recursive --force + quadlet install --application=<app>
    local quadlet_path quadlet target_path target
    for quadlet_path in "$QD_DIR"/*; do
        quadlet="$(basename "$quadlet_path")"
        case "$QD_KEEP" in
            *" $quadlet "*) ;;
            *)
                if [ -d "$quadlet_path" ]; then
                    rm -rf "$quadlet_path"
                else
                    if podman quadlet rm --help >/dev/null 2>&1; then
                        podman quadlet rm --force --ignore "$quadlet"
                    fi
                    rm -f "$quadlet_path"
                fi
            ;;
        esac
    done
    for target_path in "$QD_UNIT_DIR"/*.target; do
        target="$(basename "$target_path")"
        case "$QD_KEEP" in
            *" $target "*) ;;
            *) rm -f "$target_path" ;;
        esac
    done
}

qd_apply() {
    local target_unit="$1"
    systemctl --user daemon-reload
    systemctl --user enable "$target_unit"
    systemctl --user restart "$target_unit"
    systemctl --user mask --now podman.socket
    systemctl --user stop podman.service
    systemctl --user enable --now podman-auto-update.timer
}
