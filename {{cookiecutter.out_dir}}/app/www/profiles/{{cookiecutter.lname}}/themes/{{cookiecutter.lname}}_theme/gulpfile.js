var gulp = require('gulp');
var less = require('gulp-less');
var minifyCSS = require('gulp-csso');
var concat = require('gulp-concat');
var sourcemaps = require('gulp-sourcemaps');
/*var watch = require('gulp-watch');*/

gulp.task('css', function () {
    return gulp
        .src('less/styles.less')
        .pipe(less())
        .pipe(minifyCSS())
        .pipe(gulp.dest('dist/css'))
});

gulp.task('js', function () {
    return gulp
        .src('js/*.js')
        .pipe(sourcemaps.init())
        .pipe(concat('script.min.js'))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('dist/js'))
});

gulp.task('default', ['css', 'js']);

/*gulp.task('watch', function () {
    return gulp.watch('less/styles.less', ['css']);
});*/

