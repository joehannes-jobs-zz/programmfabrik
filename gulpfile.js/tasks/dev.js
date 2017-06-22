/*
 * Development tasks
 * =================
 */

'use strict';

const merge = require('merge-stream');
const server = require('browser-sync').create();
const watch = require('../lib/bundler').watch;
const gwatch = require('gulp-watch');
const getNamedBuffer = require('../lib/get-named-buffer');
const sourcemaps = require('gulp-sourcemaps');
const coffee = require('gulp-coffeescript');

module.exports = function (gulp, $, config) {
  const dirs = config.dirs;
  const files = config.files;

  // Compile the application code for development, actively observing for
  // changes and triggering rebuilds on demand.
  gulp.task('bundleDev', ['caffeeine'], () => {
    const devBuffer = getNamedBuffer('game.js');
    const notifyError = $.notify.onError('<%= error.message %>');
    const watcher = watch(config.bundle)
      .on('log', $.util.log)
      .on('update', rebuild);
    return rebuild();

    function rebuild() {
      return watcher
        .bundle()
        .on('error', notifyError)
        .pipe(devBuffer())
        .pipe(gulp.dest(dirs.build))
        .pipe(server.stream());
    }
  });


  gulp.task('caffeeine', () => coffeec());
  gulp.task('watchcaffeeine', () => gwatch('literature/**/*.litcoffee', coffeec));
  gulp.task('server', () => server.init(config.server.dev))
  // Starts the Web Server for testing.
  gulp.task('serve', ['bundleDev', 'server', 'watchcaffeeine']);


  // Check syntax and style of scripts and warn about potential issues.
  function coffeec() {
    return gulp.src(files.coffees)
      .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('src/'));
  }

  // The main development task.
  gulp.task('default', ['serve']);
};
