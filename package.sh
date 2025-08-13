#!/bin/bash
# This script is designed to work with Git-Bash only.

# --- SCRIPT DESCRIPTION ---
# This script automates:
# 1) Creating the MyFileServer/libs folder (fresh)
# 2) Building the frontend (dist folder)
# 3) Moving dist to MyFileServer
# 4) Copying backend python code files and requirements.txt
# 5) Installing backend dependencies into libs
# 6) Removing requirements.txt file
# 7) Verifying the final structure


# --- SCRIPT SETUP ---
set -e  # Exit immediately on error

MY_FILE_SERVER_DIR="MyFileServer"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
DIST_DIR="dist"
REQUIREMENTS_FILE="requirements.txt"
LIBS_DIR="libs"
SERVICES_DIR="services"

# --- MAIN LOGIC ---

# 1) Create MyFileServer/libs structure (delete old one if exists)
echo "Step 1: Preparing $MY_FILE_SERVER_DIR folder..."
if [ -d "$MY_FILE_SERVER_DIR" ]; then
    echo "Removing existing $MY_FILE_SERVER_DIR..."
    rm -rf "$MY_FILE_SERVER_DIR"
fi
mkdir -p "$MY_FILE_SERVER_DIR/$LIBS_DIR"
mkdir -p "$MY_FILE_SERVER_DIR/$SERVICES_DIR"

# 2) Build frontend dist
echo "Step 2: Building frontend..."
cd "$FRONTEND_DIR"
npm run build

# Back to root
cd ..

# 3) Move dist to MyFileServer
echo "Step 3: Moving $FRONTEND_DIR/$DIST_DIR to $MY_FILE_SERVER_DIR..."
mv "$FRONTEND_DIR/$DIST_DIR" "$MY_FILE_SERVER_DIR/"

# 4) Copy backend files (only .py from services)
echo "Step 4: Copying backend files..."
cp "$BACKEND_DIR/server.py" "$MY_FILE_SERVER_DIR/"
cp "$BACKEND_DIR/$REQUIREMENTS_FILE" "$MY_FILE_SERVER_DIR/"
find "$BACKEND_DIR/$SERVICES_DIR" -maxdepth 1 -name "*.py" -exec cp {} "$MY_FILE_SERVER_DIR/$SERVICES_DIR/" \;

# 5) Install backend dependencies into libs
echo "Step 5: Installing Python dependencies in libs..."
cd "$MY_FILE_SERVER_DIR"
pip install --target=$LIBS_DIR -r $REQUIREMENTS_FILE

# 6) Delete requirements.txt from MyFileServer
echo "Step 6: Removing $REQUIREMENTS_FILE..."
rm "$REQUIREMENTS_FILE"

# 7) Verify structure
echo "Step 7: Verifying final structure..."
if [ -d $SERVICES_DIR ] && \
   [ -d $DIST_DIR ] && \
   [ -d $LIBS_DIR ] && \
   [ -f server.py ]; then
    echo ""
    echo "✅ Successfully packaged MyFileServer!"
else
    echo "❌ Packaging failed! final structure not as expected"
    exit 1
fi
