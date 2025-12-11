# Quick Start: Windows Executable Download

This is a quick reference for downloading or building the Trinity Windows executable.

## Option 1: Download Pre-built (When Available)

If someone has already triggered a build:

1. Go to: https://github.com/Sprouts-Network/Trinity/actions/workflows/build-windows-mxe.yml
2. Click on a successful (green checkmark) workflow run
3. Scroll to the bottom "Artifacts" section
4. Download `trinity-windows-x64-package.zip`
5. Extract and run `trinity-qt.exe`

## Option 2: Trigger a New Build

To build a fresh Windows executable:

### Via GitHub Web Interface:

1. Go to: https://github.com/Sprouts-Network/Trinity/actions/workflows/build-windows-mxe.yml
2. Click the "Run workflow" button (on the right side)
3. Select branch: `copilot/compile-windows-qt-exe` (or `main`)
4. Click "Run workflow" (green button)
5. Wait for the workflow to complete:
   - First run: ~2-4 hours (builds all dependencies)
   - Subsequent runs: ~15-30 minutes (uses cache)
6. Download artifacts from the completed run

### Via Command Line (with gh CLI):

```bash
# Install GitHub CLI if not already installed
# See: https://cli.github.com/

# Trigger the workflow
gh workflow run build-windows-mxe.yml

# List runs
gh run list --workflow=build-windows-mxe.yml

# Download artifacts from latest run
gh run download --name trinity-windows-x64-package
```

## What You Get

After downloading, you'll have:

- **trinity-qt.exe** - The Windows executable (ready to run)
- **README.txt** - Quick start guide
- **BUILD_INFO.txt** - Build details and version info

## Running Trinity on Windows

1. Extract the downloaded ZIP file
2. Double-click `trinity-qt.exe` to launch
3. Follow the onboarding wizard to create your wallet
4. **Important**: Save your seed phrase securely!

## Checking Build Status

To see all workflow runs:
https://github.com/Sprouts-Network/Trinity/actions

Look for:
- ✅ Green checkmark = Build succeeded, artifacts available
- ❌ Red X = Build failed, check logs
- 🟡 Yellow circle = Build in progress

## Troubleshooting

### "No artifacts available"
- The workflow is still running, or failed
- Check the workflow status (should be green checkmark)
- If failed, check logs and re-run

### "Workflow run not found"
- No one has triggered a build yet
- Click "Run workflow" to trigger one

### "Download button disabled"
- Artifacts expire after 90 days
- Trigger a new workflow run

### "Executable won't run on Windows"
- Make sure you downloaded from the MXE workflow (not the documentation one)
- Check that you have 64-bit Windows
- Try running as administrator

## Build Times

| Scenario | Duration | Why |
|----------|----------|-----|
| First build | 2-4 hours | Compiles MXE dependencies (Qt, Boost, etc.) |
| With cache | 15-30 min | Uses cached dependencies, only compiles Trinity |
| Cache expired | 2-4 hours | Cache expires after ~7 days of inactivity |

## Alternative: Build Locally

If you don't want to wait for GitHub Actions:

See [WINDOWS-DOWNLOAD-GUIDE.md](WINDOWS-DOWNLOAD-GUIDE.md) for:
- Local MXE installation
- Using pre-built dependencies
- Docker-based builds

## Need Help?

- Check [WINDOWS-DOWNLOAD-GUIDE.md](WINDOWS-DOWNLOAD-GUIDE.md) for detailed instructions
- Open an issue: https://github.com/Sprouts-Network/Trinity/issues
- Review workflow logs for build errors

---

**Quick Links:**
- [Build Windows Executable with MXE](https://github.com/Sprouts-Network/Trinity/actions/workflows/build-windows-mxe.yml)
- [All Workflows](https://github.com/Sprouts-Network/Trinity/actions)
- [Releases](https://github.com/Sprouts-Network/Trinity/releases)
