import Alpine from 'alpinejs';
import persist from '@alpinejs/persist';
import focus from '@alpinejs/focus';

var debug = 0 ? console.log.bind(console, '[index]') : function () {};

// Set up and start Alpine.
(function () {
	// Register AlpineJS plugins.
	Alpine.plugin(focus);
	Alpine.plugin(persist);

	// Start AlpineJS.
	Alpine.start();
})();
