#!/usr/bin/bash

# Script to generate foamut executable and create backward compatibility symlink

set -e

echo "Generating foamut executable with bashly..."
bashly generate

echo "Creating Alltest symlink for backward compatibility..."
ln -sf foamut Alltest

echo "Done! Run ./foamut --help or ./Alltest --help to test"
