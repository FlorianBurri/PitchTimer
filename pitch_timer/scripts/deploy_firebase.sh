#!/bin/sh
set -e
flutter clean
flutter build web --web-renderer canvaskit
firebase deploy --only hosting