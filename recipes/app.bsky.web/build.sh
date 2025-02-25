export PACKAGE="app.bsky.web"
export NAME="Bluesky"
export NAME_CN="Bluesky"
export VERSION="1.0.0"
export ARCH="all"
export URL="icon.png::https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Bluesky_Logo.svg/600px-Bluesky_Logo.svg.png"
export DO_NOT_UNARCHIVE=1
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export HOMEPAGE="https://bsky.app/"
# export DEPENDS="libgconf-2-4, libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, deepin-elf-verify"
export DEPENDS="com.electron"
export BUILD_DEPENDS="npm"
export SECTION="misc"
export PROVIDE=""
export DESC1="Electron wrapper for $HOMEPAGE"
export DESC2=""

export INGREDIENTS=(nodejs)

function build() {
    cp "$ROOT_DIR/templates/index.js" "$SRC_DIR/index.js"
    cp "$ROOT_DIR/templates/run.sh" "$APP_DIR/files/run.sh"
    cat "$ROOT_DIR/templates/package.json" | envsubst >"$SRC_DIR/package.json"

    pushd "$SRC_DIR"

#    export ELECTRON_MIRROR=https://registry.npmmirror.com/
    pnpm install 
    pnpm run build
    cp -RT out/linux-unpacked/resources $APP_DIR/files/resources
    mkdir -p "$APP_DIR/files/userscripts"
    cp "$ROOT_DIR"/*.js "$APP_DIR/files/userscripts/"

    popd

    utils.icon.collect $SRC_DIR "-maxdepth 1"
    rm -rf $APP_DIR/entries/icons/hicolor/**/apps/icon.png

    mkdir -p "$APP_DIR/entries/applications"
    cat <<EOF >$APP_DIR/entries/applications/$PACKAGE.desktop
[Desktop Entry]
Name=$NAME
Name[zh_CN]=$NAME_CN
Exec=env PACKAGE=$PACKAGE /opt/apps/$PACKAGE/files/run.sh %U
Terminal=false
Type=Application
Icon=$PACKAGE
StartupWMClass=$PACKAGE
Categories=Games;
EOF
    return 0
}
