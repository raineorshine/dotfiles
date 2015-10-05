var gulp = require('gulp');
var rename = require('gulp-rename');
var shell = require('gulp-shell');
var filter = require('gulp-filter');
var clean = require('gulp-clean');
var untildify = require('untildify');
var _ = require('underscore');
var cint = require('cint');
var glob = require('glob');

var getUserDotfiles = function(cb) {
	// get a list of all dotfiles we want to copy
	glob('.*', function(err, repoDotfiles) {

		// map the paths to ~/ and convert to absolute paths with untildify
		userDotfiles = repoDotfiles.map(
			cint.arritize(
				_.compose(
					untildify,
					''.concat.bind('~/')
				), 1)
		);

		cb(err, userDotfiles);

	});
};

// backup user's dotfiles
gulp.task('backup', function() {

	getUserDotfiles(function(err, dotfiles) {

		// backup user's dotfiles
		gulp.src(dotfiles)
			.pipe(filter(['!.git', '!.gitignore']))
			.pipe(rename({suffix: '_backup'}))
			.pipe(gulp.dest(untildify('~/')))

	});

});

// delete user dotfiles
gulp.task('remove', function() {

	getUserDotfiles(function(err, dotfiles) {

		// remove user dotfiles that were added from repo dotfiles
		gulp.src(dotfiles, {read:false})
			.pipe(filter(['!.git', '!.gitignore']))
			.pipe(clean({force:true}))

	});

});

gulp.task('restore', ['remove'], function() {
	// restore backups
	gulp.src(untildify('~/.*_backup'))
		.pipe(clean({force:true}))
		.pipe(rename(function(path) {
			path.basename = path.basename.replace('_backup', '');
		}))
		.pipe(gulp.dest(untildify('~/')))
})


// link repo dotfiles to user dotfiles
gulp.task('link', function() {

	// source repo dotfiles
	gulp.src('.*')
		// TODO: put dotfiles in subfolder so user .gitignore is not confused with repo .gitignore
		.pipe(filter(['!.git', '!.gitignore']))

		// create links in repo dotfiles that point to user root so user can edit as normal
		// TODO: This should just be straight dotfiles mapped to child_process.exec, not gulp.src
		.pipe(shell([
			'ln -sf <%= file.path %> ~/<%= file.path.split("/").pop() %>'
		]))
});

gulp.task('setup', ['backup', 'link']);
