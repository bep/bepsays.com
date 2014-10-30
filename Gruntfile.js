module.exports = function (grunt) {

    // load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    // Project configuration.
    grunt.initConfig({

        less: {
            dev: {
                options: {
                    paths: ['assets/less'],
                    cleancss: true
                },
                files: {
                    'static/css/bs.css': 'assets/less/bs.less'
                }
            }
        },
        filerev: {
            options: {
                encoding: 'utf8',
                algorithm: 'md5',
                length: 8
            },
            source: {
                files: [
                    {
                        src: [
                            'static/css/bs.css',
                            'static/js/bs.min.js'
                        ]
                    }
                ]
            }
        },
        filerev_apply: {
            options: {
                prefix: 'static'
            },
            your_target: {
                files: {
                    'layouts/partials/head.html': 'layouts/partials/head_master.html',
                    'layouts/partials/footer.html': 'layouts/partials/footer_master.html'
                }
            }
        },
        watch: {
            options: {
                livereload: false
            },
            less: {
                files: ['assets/less/*.less'],
                tasks: ['less']
            }
        },
        clean: {
            static: ["static/css/*.css", "static/js/*.js"]
        },
        copy: {
            dev: { files: [
                { src: 'layouts/partials/head_master.html', dest: 'layouts/partials/head.html' },
                { src: 'layouts/partials/footer_master.html', dest: 'layouts/partials/footer.html' }

            ]
            }
        },
        concat: {
            options: {
                // define a string to put between each file in the concatenated output
                separator: ';'
            },
            dist: {
                // the files to concatenate
                src: ['assets/js/vendor/socialite.js', 'assets/js/**/*.js'],
                // the location of the resulting JS file
                dest: 'static/js/bs.js'
            }
        },
        uglify: {
            options: {
            },
            dist: {
                files: {
                    'static/js/bs.min.js': ['<%= concat.dist.dest %>']
                }
            }
        }
    });


    grunt.registerTask('build', [
        'clean:static',
        'less:dev',
        'concat',
        'uglify',
        'filerev',
        'filerev_apply'

    ]);

    grunt.registerTask('dev', [
        'less:dev',
        'copy:dev',
        'concat',
        'uglify'
    ]);

    grunt.registerTask('default', [
        'dev',
        'watch'
    ]);


};
