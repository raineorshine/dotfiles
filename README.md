Store your dotfiles in a repo and symlink them to your home directory.

This repo also contains my personal dotfiles.

**Note:** The gulp app is a legacy project requiring node `v10.15.0` for gulp `v3`. The dotfiles themselves however are up-to-date and quite usable.

## Usage

Setup:

```
gulp setup
```

Add new dotfiles to the repo:

1. `cp ~/.zprofile .`
2. `gulp setup`

## Gulp Tasks
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
