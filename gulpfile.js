var requireDir = require('require-dir');
var env = require('gulp-env');

env({
    vars: {
        site: "bepsays"
    }
});


// Require all tasks in gulp, including subfolders
requireDir('./gulp', {recurse: true});