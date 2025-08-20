#!/bin/bash

set -e  # Exit on any error

APP_NAME="Layerbase"
VERSION="1.0.0"
ARCH="arm64"
DEB_DIR="${APP_NAME}_deb"
BUILD_DIR="build/linux/$ARCH/release/bundle"
DEB_FILE="${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "🛠️ Building Flutter app for $ARCH..."
flutter build linux --release --target-platform=linux-$ARCH

echo "📁 Setting up package structure..."
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/opt/$APP_NAME"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"

echo "📦 Creating control file..."
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: graphics
Priority: optional
Architecture: $ARCH
Depends: libgtk-3-0, libglib2.0-0
Maintainer: Bishavjeet Singh <bishavjeet.digisoft@gmail.com>
Description: Layer-based image editor built with Flutter
 A high-resolution, layer-based image editor with export, stickers, and drawing support.
EOF

echo "📁 Copying Flutter build files..."
cp -r "$BUILD_DIR"/* "$DEB_DIR/opt/$APP_NAME/"

echo "⚙️ Creating launcher script..."
cat > "$DEB_DIR/usr/bin/$APP_NAME" <<EOF
#!/bin/bash
export LD_LIBRARY_PATH=/opt/$APP_NAME/lib:\$LD_LIBRARY_PATH
exec /opt/$APP_NAME/$APP_NAME "\$@"
EOF

chmod +x "$DEB_DIR/usr/bin/$APP_NAME"

echo "🖼️ Creating desktop entry..."
cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=Layerbase
Exec=/opt/$APP_NAME/$APP_NAME
Icon=/opt/$APP_NAME/data/icon.png
Type=Application
Categories=Graphics;
StartupNotify=true
EOF

echo "📦 Building .deb package..."
dpkg-deb --build --root-owner-group "$DEB_DIR"
mv "$DEB_DIR.deb" "$DEB_FILE"

echo "✅ Done! Installer created: $DEB_FILE"
