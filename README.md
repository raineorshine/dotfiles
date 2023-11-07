Raine's personal dotfiles and editor settings.

Files are stored in the repo and then symlinked to their respective system directories.

## Usage

Add new files to the repo:

1. `cd ~/projects/dotfiles`
2. `mv ~/.zprofile .`
3. `ln -s .zprofile ~/.zprofile`

## Gulp

This repo also contains a legacy gulp app that handles setup, backup, and restoration of root dotfiles.

<table>
	<tr>
		<td><code>gulp&nbsp;setup</code></td>
		<td>Backup and link the dotfiles from this repo into your user directory.</td>
	</tr>
	<tr>
		<td><code>gulp&nbsp;restore</code></td>
		<td>Remove all dotfiles from the user directory that came from this repo and rename backups to originals. <b>Do not run before gulp backup or <code>gulp&nbsp;setup</code> or your dotfiles will be deleted without backups!</b></td>
	</tr>
	<tr>
		<td><code>gulp&nbsp;backup</code> (internal)</td>
		<td>Backup all user dotfiles that would get overwritten by <code>gulp&nbsp;setup</code> adding a '_backup' extension</td>
	</tr>
	<tr>
		<td><code>gulp&nbsp;link</code> (internal)</td>
		<td>Create symlinks from user root dotfiles to repo dotfiles. Part of setup</td>
	</tr>
	<tr>
		<td><code>gulp&nbsp;remove</code> (internal)</td>
		<td>Remove all dotfiles from the user directory that came from this repo. <b>Do not run before gulp backup or <code>gulp&nbsp;setup</code> or your dotfiles will be deleted without backups!</b></td>
	</tr>
</table>
