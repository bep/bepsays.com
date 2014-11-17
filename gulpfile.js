var gulp = require('gulp');
var less = require('gulp-less');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var revall = require('gulp-rev-all');
var rename = require('gulp-rename');
var path = require('path');
var gutil = require('gulp-util');
var clean = require('gulp-clean')

gulp.task('less', function () {
    return gulp.src('assets/less/bs.less')
        .pipe(less({compress: true}))
        .pipe(gulp.dest('static/css'));
});

gulp.task('scripts', function () {
    return gulp.src(['assets/js/vendor/socialite.js', 'assets/js/**/*.js'])
        .pipe(concat('bs.js'))
        .pipe(uglify())
        .pipe(gulp.dest('static/js'));
});


gulp.task('clean', function () {
    return gulp.src(["static/css/*.css", "static/js/*.js"], {read: false})
        .pipe(clean());
});

/* There may be more elegant ways to do this, but we need to work with unversioned resources with Hugo's livereload running. */
gulp.task('copy', [], function () {
    return gulp.src('layouts/partials/head_master.html').pipe(rename('head.html'))
        .pipe(gulp.dest('layouts/partials'))
        .on('error', gutil.log)
});

gulp.task('build', ['clean', 'less', 'scripts', 'copy'], function () {
    return gulp.src(['static/js/bs.js', 'static/css/bs.css', 'layouts/partials/head.html'], {base: path.join(process.cwd(), 'static')})
        .pipe(revall({
            ignore: [/^\/favicon.ico$/g, '.png', '.html', /.*vendor.*/, /.*nano.*/, /.*favicon.*/]

        }))
        .pipe(gulp.dest('static'))
});

gulp.task('watch', ['copy', 'less', 'scripts'], function () {
    gulp.watch('assets/less/*.less', ['less']);
    gulp.watch('assets/js/**/*.js', ['scripts']);
});

/* This is all we need for dev. */
gulp.task('default', ['watch']);