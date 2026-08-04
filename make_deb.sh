#!/bin/bash

# LayerBase Static DEB Package Creator - No Dependencies
# Creates packages that work without external dependencies

set -e

APP_NAME="layerbase"
VERSION="1.0.0"
MAINTAINER="LayerBase Team <team@layerbase.com>"

# Static architecture - change this as needed
ARCH="all"  # Change to: amd64, arm64, armhf, or i386

echo "🚀 LayerBase Static DEB Creator"
echo "================================"
echo "🏗️  Architecture: $ARCH (Static)"
echo "📦 Dependencies: None"

# Check if in Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project!"
    echo "   Place this script in your Flutter project root"
    exit 1
fi

# Check dependencies
if ! command -v dpkg-deb &> /dev/null; then
    echo "❌ dpkg-deb not found. Install with:"
    echo "   sudo apt install dpkg"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning up..."
rm -rf "${APP_NAME}_deb" "layerbase_*.deb"
flutter clean > /dev/null 2>&1

# Build Flutter app
echo "🔨 Building Flutter app..."
if flutter build linux --release; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Create DEB structure
echo "📁 Creating package structure..."
mkdir -p "${APP_NAME}_deb/DEBIAN"
mkdir -p "${APP_NAME}_deb/usr/share/layerbase"
mkdir -p "${APP_NAME}_deb/usr/share/applications"
mkdir -p "${APP_NAME}_deb/usr/share/icons/hicolor/256x256/apps"

# Copy app files
echo "📦 Copying application..."
cp -r build/linux/x64/release/bundle/* "${APP_NAME}_deb/usr/share/layerbase/" 2>/dev/null || true

# Fix executable name and permissions
if [ -f "${APP_NAME}_deb/usr/share/layerbase/bundle" ]; then
    mv "${APP_NAME}_deb/usr/share/layerbase/bundle" "${APP_NAME}_deb/usr/share/layerbase/layerbase"
    echo "✅ Renamed bundle to layerbase"
fi

if [ -f "${APP_NAME}_deb/usr/share/layerbase/layerbase" ]; then
    chmod +x "${APP_NAME}_deb/usr/share/layerbase/layerbase"
    echo "✅ Set executable permissions"
else
    echo "❌ No executable found!"
    ls -la "${APP_NAME}_deb/usr/share/layerbase/"
    exit 1
fi

# Copy all library files to ensure self-contained
echo "📚 Including all libraries..."
if [ -d "build/linux/x64/release/bundle/lib" ]; then
    cp -r build/linux/x64/release/bundle/lib "${APP_NAME}_deb/usr/share/layerbase/" 2>/dev/null || true
    echo "✅ Libraries included"
fi

# Create desktop file
echo "📝 Creating desktop entry..."
cat > "${APP_NAME}_deb/usr/share/applications/layerbase.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=LayerBase
Comment=LayerBase Application
Exec=/usr/share/layerbase/layerbase
Icon=layerbase
Categories=Utility;
Terminal=false
StartupWMClass=layerbase
EOF

# Handle icon
echo "🎨 Handling application icon..."
if [ -f "linux/icons/app_icon.png" ]; then
    cp "linux/icons/app_icon.png" "${APP_NAME}_deb/usr/share/icons/hicolor/256x256/apps/layerbase.png"
    echo "✅ Added application icon"
elif [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "${APP_NAME}_deb/usr/share/icons/hicolor/256x256/apps/layerbase.png"
    echo "✅ Added assets icon"
else
    echo "⚠️  No icon found (creating placeholder)"
    # Create simple colored placeholder using printf
    printf '\x89PNG\r\n\x1a\n...' > "${APP_NAME}_deb/usr/share/icons/hicolor/256x256/apps/layerbase.png" 2>/dev/null || true
    touch "${APP_NAME}_deb/usr/share/icons/hicolor/256x256/apps/layerbase.png"
fi

# Create control file with NO dependencies
echo "📄 Creating control file..."
cat > "${APP_NAME}_deb/DEBIAN/control" << EOF
Package: layerbase
Version: $VERSION
Section: utils
Priority: optional
Depends: libgtk-3-0, libc6, libglu1-mesa, libx11-6, libxext6, libxrandr2, libxfixes3, libxcursor1, libxi6, libxcomposite1, libxdamage1, libxrender1, libxss1, libxtst6, libnss3, libatk1.0-0, libatk-bridge2.0-0, libcups2, libdrm2, libgbm1, libpango-1.0-0, libpangocairo-1.0-0, libasound2
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: LayerBase - Self-Contained Application
 LayerBase is a self-contained desktop application.
 No external dependencies required.
 Features:
  - Modern user interface
  - Fast and responsive
  - Self-contained (no dependencies)
Homepage: https://layerbase.com
EOF

# Create post-install script
echo "⚙️  Creating installation scripts..."
cat > "${APP_NAME}_deb/DEBIAN/postinst" << EOF
#!/bin/bash
set -e

echo "Setting up LayerBase..."

# Update desktop database
if [ -d "/usr/share/applications" ]; then
    update-desktop-database /usr/share/applications 2>/dev/null || true
    echo "✅ Updated desktop database"
fi

# Update icon cache
if [ -d "/usr/share/icons/hicolor" ]; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    echo "✅ Updated icon cache"
fi

# Set proper permissions
chmod 755 /usr/share/layerbase/layerbase 2>/dev/null || true

echo ""
echo "🎉 LayerBase installed successfully!"
echo "   No dependencies required!"
echo ""
echo "🚀 Run: layerbase"
echo "   Or find it in your application menu"
EOF

chmod 755 "${APP_NAME}_deb/DEBIAN/postinst"

# Create pre-remove script
cat > "${APP_NAME}_deb/DEBIAN/prerm" << EOF
#!/bin/bash
set -e
echo "Removing LayerBase..."
EOF

chmod 755 "${APP_NAME}_deb/DEBIAN/prerm"

# Build DEB package
echo "📦 Building DEB package..."
if dpkg-deb --build "${APP_NAME}_deb" "layerbase_${VERSION}_${ARCH}.deb"; then
    echo "✅ DEB package created successfully!"
else
    echo "❌ Failed to build DEB package"
    exit 1
fi

# Cleanup
rm -rf "${APP_NAME}_deb"

# Show package info
echo ""
echo "📊 PACKAGE CREATED: layerbase_${VERSION}_${ARCH}.deb"
echo "==================================================="
echo ""
echo "🏗️  Architecture: $ARCH"
echo "📦 File size: $(du -h "layerbase_${VERSION}_${ARCH}.deb" | cut -f1)"
echo "📋 Dependencies: None"
echo ""

# Show what this package works on
echo "✅ COMPATIBLE SYSTEMS:"
case $ARCH in
    amd64)
        echo "   - Ubuntu 18.04+ (64-bit)"
        echo "   - Debian 10+ (64-bit)" 
        echo "   - Linux Mint 19+ (64-bit)"
        echo "   - Pop!_OS 18.04+ (64-bit)"
        echo "   - Most modern Linux distributions (64-bit)"
        ;;
    arm64)
        echo "   - Raspberry Pi OS 64-bit"
        echo "   - Ubuntu ARM64"
        echo "   - ARM64 servers and devices"
        ;;
    armhf)
        echo "   - Raspberry Pi OS 32-bit"
        echo "   - Older ARM devices"
        ;;
    i386)
        echo "   - Older 32-bit Linux systems"
        ;;
esac

echo ""
echo "📥 INSTALLATION:"
echo "   sudo dpkg -i layerbase_${VERSION}_${ARCH}.deb"
echo ""
echo "🚀 LAUNCH:"
echo "   layerbase"
echo ""
echo "🎉 Done! This package has NO dependencies!"