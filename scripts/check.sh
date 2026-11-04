#!/bin/sh
set -e
cd "$(dirname "$0")/../apps/mobile"
flutter analyze
flutter test
