# OpenSnitch Installation

Repository: https://github.com/evilsocket/opensnitch
Release: https://github.com/evilsocket/opensnitch/releases

## Installation Process

The `install_opensnitch.sh` script handles the installation of OpenSnitch by:
1. Checking and installing required dependencies (curl and jq)
2. Using the known working versions:
   - OpenSnitch daemon: v1.6.6
   - OpenSnitch UI: v1.6.7
3. Downloading both packages from their respective GitHub release tags
4. Installing the packages using dpkg
5. Fixing any dependency issues automatically

### Design Decisions

- We use specific version numbers for both components since there is an intentional version mismatch between the daemon and UI
- The script creates a temporary directory for downloads to keep the workspace clean
- Dependencies are automatically fixed using `apt-get install -f`

### Notes

- There is a known version difference between the daemon (1.6.6) and UI (1.6.7)
- This version combination has been tested and works correctly
- The script handles the cleanup of downloaded files automatically
- Using `dpkg` for installation allows us to install local .deb files directly
- The script is idempotent and can be run multiple times safely

### Version History

- Initially, we tried using the latest GitHub release version for both components, but discovered that the daemon and UI intentionally have different versions
- The current approach uses specific versions that are known to work together