#!/bin/bash

echo "🔍 Monitoring Console logs for ClipFlow debug output..."
echo "Start the ClipFlow app and try double-clicking on clipboard items."
echo "Press Ctrl+C to stop monitoring."
echo ""

# Monitor system logs for ClipFlow debug messages
log stream --predicate 'process CONTAINS "ClipFlow"' --style compact | grep -E "(🔥|📋|🖱️|✅|❌|📜|🔧|⌨️|🔄|🔍)"