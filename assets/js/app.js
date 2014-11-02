// init popovers
//$('#fake-menu').popover();


window.log = function () {
    log.history = log.history || [];   // store logs to an array for reference
    log.history.push(arguments);
    if (console) {
        console.log(Array.prototype.slice.call(arguments));
    }
};


(function () {
    var config = {
        kitId: 'xdf4dqg',
        scriptTimeout: 3000
    };
    var h = document.getElementsByTagName('html')[0];
    h.className += ' wf-loading';
    var t = setTimeout(function () {
        h.className = h.className.replace(/(\s|^)wf-loading(\s|$)/g, ' ');
        h.className += ' wf-inactive';
    }, config.scriptTimeout);
    var d = false;
    var tk = document.createElement('script');
    tk.src = '//use.typekit.net/' + config.kitId + '.js';
    tk.type = 'text/javascript';
    tk.async = 'true';
    tk.onload = tk.onreadystatechange = function () {
        var rs = this.readyState;
        if (d || rs && rs != 'complete' && rs != 'loaded') return;
        d = true;
        clearTimeout(t);
        try {
            Typekit.load(config);
        } catch (e) {
        }
    };
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(tk, s);
})();


