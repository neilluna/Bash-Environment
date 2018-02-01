# Change log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 2.0.0 - 2018-02-01
### Added
- Shebang headers to all scripts.
- Command line switches to install.sh to control which scripts get added.
### Changed
- cygwin-vagrant-helper.sh only gets added if the environment is Cygwin.
- Python virtual environment variables are set for Python 3. 
### Fixed
- Previously, the profile script would call the ~/.bash_profile.d/ scripts unconditionally. Now, the profile script calls the ~/.bash_profile.d/ scripts only if the shell is Bash. This was added to avoid calling the ~/.bash_profile.d/ scripts from other shells.
- Previously, the installation script would not handle spaces in the profile script path. Now it does.   
 
## 1.0.0 - 2017-12-12
### Added
- Initial files and installation script.
- Change log and License file.
