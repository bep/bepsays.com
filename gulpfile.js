var gulp = require('gulp');
var less = require('gulp-less');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var revall = require('gulp-rev-all');
var rename = require('gulp-rename');
var path = require('path');
var gutil = require('gulp-util');
var clean = require('gulp-clean');
var awspublish = require('gulp-awspublish');
var fs = require('fs');
var run = require('gulp-run');
var parallelize = require("concurrent-transform");
var awspublishRouter = require("gulp-awspublish-router");


function copyPartials() {
    return gulp.src('layouts/partials/head_master.html').pipe(rename('head.html'))
        .pipe(gulp.dest('layouts/partials'))
        .on('error', gutil.log)
}

gulp.task('less', function () {
    return gulp.src('assets/less/bs.less')
        .pipe(less({compress: true}))
        .pipe(gulp.dest('static/assets/css'));
});

gulp.task('scripts', function () {
    return gulp.src(['assets/js/vendor/socialite.js', 'assets/js/**/*.js'])
        .pipe(concat('bs.js'))
        .pipe(uglify())
        .pipe(gulp.dest('static/assets/js'));
});


gulp.task('clean-static', function () {
    return gulp.src(["static/assets/css/*.css", "static/assets/js/*.js"], {read: false})
        .pipe(clean());
});


gulp.task('clean-dist', function () {
    return gulp.src(["dist"], {read: false})
        .pipe(clean());
});

/* There may be more elegant ways to do this, but we need to work with unversioned resources with Hugo's livereload running. */
gulp.task('copy', [], function () {
    return copyPartials();
});

gulp.task('build-static', ['clean-static', 'less', 'scripts', 'copy'], function () {
    return gulp.src(['static/assets/js/bs.js', 'static/assets/css/bs.css', 'layouts/partials/head.html'], {base: path.join(process.cwd(), 'static')})
        .pipe(revall({
            ignore: [/^\/favicon.ico$/g, '.png', '.html', /.*vendor.*/, /.*nano.*/, /.*favicon.*/]

        }))
        .pipe(gulp.dest('static/assets'))
});

gulp.task('build', ['build-static', 'clean-dist'], function (cb) {
    run('hugo --source=. --destination=dist').exec(cb);

});


gulp.task('aws-publish', ['build'], function () {

    var publisher = awspublish.create(JSON.parse(fs.readFileSync(process.env.HOME + '/.aws/bepsays.json')));

    return gulp.src('./dist/**')
        .pipe(awspublishRouter({
            cache: {
                // cache for 5 minutes by default
                cacheTime: 300
            },

            routes: {
                "^assets/(?:.+)\\.(?:js|css|svg|ttf)$": {
                    // don't modify original key. this is the default
                    key: "$&",
                    // use gzip for assets that benefit from it
                    gzip: true,
                    // cache static assets for 2 years
                    cacheTime: 630720000
                },

                "^assets/.+$": {
                    // cache static assets for 2 years
                    cacheTime: 630720000
                },


                "^README$": {
                    // specify extra headers
                    headers: {
                        "Content-Type": "text/plain"
                    }
                },

                // pass-through for anything that wasn't matched by routes above, to be uploaded with default options
                "^.+$": "$&"
            }
        }))
        .pipe(parallelize(publisher.publish(), 10))
        .pipe(publisher.sync())
        .pipe(publisher.cache())
        .pipe(awspublish.reporter({
            states: ['create', 'update', 'delete']
        }));
});


gulp.task('deploy', ['aws-publish'], function () {

    // get it back into dev shape again
    return copyPartials();

});


gulp.task('watch', ['copy', 'less', 'scripts'], function () {
    gulp.watch('assets/less/*.less', ['less']);
    gulp.watch('assets/js/**/*.js', ['scripts']);
});

/* This is all we need for dev. */
gulp.task('default', ['watch']);