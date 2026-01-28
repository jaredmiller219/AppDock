#!/bin/bash

# Test script to verify sidebar expansion fix
# This script runs the key regression tests for Help and Release Notes sidebar behavior

echo "🧪 Testing Sidebar Expansion Fix..."
echo "=================================="

# Test Help sidebar doesn't expand all sections (regression test)
echo "📋 Running Help sidebar regression test..."
xcodebuild test -scheme AppDock \
    -destination 'platform=macOS' \
    -only-testing:AppDockUITests/HelpAndReleaseNotesUITests/testHelpSidebarDoesNotExpandAllSections \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ Help sidebar regression test PASSED"
else
    echo "❌ Help sidebar regression test FAILED"
    exit 1
fi

# Test Release Notes sidebar doesn't expand all versions (regression test)
echo "📋 Running Release Notes sidebar regression test..."
xcodebuild test -scheme AppDock \
    -destination 'platform=macOS' \
    -only-testing:AppDockUITests/HelpAndReleaseNotesUITests/testReleaseNotesSidebarDoesNotExpandAllVersions \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ Release Notes sidebar regression test PASSED"
else
    echo "❌ Release Notes sidebar regression test FAILED"
    exit 1
fi

# Test Help sidebar expansion behavior
echo "📋 Running Help sidebar expansion behavior test..."
xcodebuild test -scheme AppDock \
    -destination 'platform=macOS' \
    -only-testing:AppDockUITests/HelpAndReleaseNotesUITests/testHelpSidebarExpansionBehavior \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ Help sidebar expansion behavior test PASSED"
else
    echo "❌ Help sidebar expansion behavior test FAILED"
    exit 1
fi

# Test Release Notes sidebar expansion behavior
echo "📋 Running Release Notes sidebar expansion behavior test..."
xcodebuild test -scheme AppDock \
    -destination 'platform=macOS' \
    -only-testing:AppDockUITests/HelpAndReleaseNotesUITests/testReleaseNotesSidebarExpansionBehavior \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ Release Notes sidebar expansion behavior test PASSED"
else
    echo "❌ Release Notes sidebar expansion behavior test FAILED"
    exit 1
fi

echo ""
echo "🎉 All sidebar expansion tests PASSED!"
echo "The fix is working correctly - sidebars no longer expand all items at once."
