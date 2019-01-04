# Change log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 5.0.0 - 2019-01-04
### Added
- xdg-dirs-vars.sh to handle XDG_DATA_HOME, XDG_CONFIG_HOME, and XDG_CACHE_HOME.

## 4.0.0 - 2019-01-03
### Added
- git-update.sh to ease Git repository updates.

## 3.0.0 - 2018-09-26
### Changed
- create-ssh-key.sh usage. It is now more flexible about key names and comment.

## 2.0.0 - 2018-04-12
### Added
- Shebang headers to all scripts.
- Command line switches to install.sh to control which scripts get added.
- ~/bin files.
- create-gitconfig.sh to ease SSH key creation.
- create-hgrc.sh to ease SSH key creation.
- create-ssh-key.sh to ease SSH key creation.
- git-clone.sh to ease Git clone operations.
### Changed
- cygwin-vagrant-helper.sh only gets added if the environment is Cygwin.
- Python virtual environment variables are set for Python 3.
- install.sh now only adds or replaces scripts. It does not remove them.
### Fixed
- Previously, the profile script would call the ~/.bash_profile.d/ scripts unconditionally. Now, the profile script calls the ~/.bash_profile.d/ scripts only if the shell is Bash. This was added to avoid calling the ~/.bash_profile.d/ scripts from other shells.
- Previously, the installation script would not handle spaces in the profile script path. Now it does.
- Fixed cygwin-vagrant-helper.sh to fix Vagrant SSH.

## 1.0.0 - 2017-12-12
### Added
- Initial files and installation script.
- Change log and License file.
