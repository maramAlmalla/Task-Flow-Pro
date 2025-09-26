#!/usr/bin/env bash

echo "Setting up Flutter Todo App..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter..."
    
    # Download and setup Flutter (for Replit environment)
    if [ ! -d "flutter" ]; then
        echo "Downloading Flutter SDK..."
        git clone -b stable --depth 1 https://github.com/flutter/flutter.git
    fi
    
    # Add Flutter to PATH
    export PATH="$PATH:$(pwd)/flutter/bin"
    echo 'export PATH="$PATH:$(pwd)/flutter/bin"' >> ~/.bashrc
fi

# Verify Flutter installation
echo "Checking Flutter installation..."
flutter --version

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "Building for web..."
flutter build web --release

echo "Setup complete!"
echo ""
echo "To run the app:"
echo "  Development: flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000"
echo "  Production: Serve the build/web directory"
echo ""