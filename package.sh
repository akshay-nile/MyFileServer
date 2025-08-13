#!/bin/bash
# This script is designed to work with Git-Bash only.

# --- SCRIPT DESCRIPTION ---
# This script automates:
# 1) Creating the MyFileServer/libs folder (fresh)
# 2) Building the frontend (dist folder)
# 3) Moving dist to MyFileServer
# 4) Generating requirements.txt from pyproject.toml file
# 5) Copying backend python code files and requirements.txt
# 6) Installing backend dependencies into libs
# 7) Removing requirements.txt file
# 8) Verifying the final structure


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
cd $FRONTEND_DIR
npm run build

# 3) Move dist to MyFileServer
echo "Step 3: Moving $DIST_DIR to $MY_FILE_SERVER_DIR..."
mv $DIST_DIR ../$MY_FILE_SERVER_DIR/

# 4) Generate requirements.txt file
echo "Step 4: Generating requirements.txt file..."
cd ../$BACKEND_DIR
uv pip compile pyproject.toml -o $REQUIREMENTS_FILE --no-deps --no-annotate --no-header

# 5) Copy backend files (only .py from services)
echo "Step 5: Copying backend files..."
mv $REQUIREMENTS_FILE ../$MY_FILE_SERVER_DIR/
cp server.py ../$MY_FILE_SERVER_DIR/
find $SERVICES_DIR -maxdepth 1 -name "*.py" -exec cp {} "../$MY_FILE_SERVER_DIR/$SERVICES_DIR/" \;

# 6) Install backend dependencies into libs
echo "Step 6: Installing Python dependencies in libs..."
cd ../$MY_FILE_SERVER_DIR
uv pip install --target=$LIBS_DIR -r $REQUIREMENTS_FILE

# 7) Delete requirements.txt from MyFileServer
echo "Step 7: Removing $REQUIREMENTS_FILE..."
rm $REQUIREMENTS_FILE

# 8) Verify the final structure
echo "Step 8: Verifying final structure..."
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
