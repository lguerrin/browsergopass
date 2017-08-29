'use strict';

var m = require('mithril');
var app = 'com.lguerrin.browsergopass';
var activeTab;
var searching = false;
var logins = null;
var domain, urlDuringSearch;


console.log("Launch plugin...");
m.mount(document.getElementById('mount'), { "view": view });

chrome.browserAction.setIcon({ path: 'icon-lock.svg' });
chrome.tabs.onActivated.addListener(init);
chrome.tabs.query({ currentWindow: true, active: true }, function (tabs) {
    init(tabs[0]);
});

function view() {
    var results = '';

    if( searching ) {
        results = m('div.loader');
    } else if( logins !== null ) {
        if( typeof(logins) === "undefined" ) {
            results = m('div.status-text', "Cannot find host application");
        } else if( logins.length === 0 ) {
            results = m('div.status-text',  m.trust(`No passwords found for <strong>${domain}</strong>.`));
        } else if( logins.length > 0 ) {
            results = logins.map(function(l) {
                var faviconUrl = getFaviconUrl(domain);
                return m('button.login', {
                        "onclick": getLoginData.bind(l),
                        "style": `background-image: url('${faviconUrl}')`
                    },
                    l)
            });
        }
    }

    return [
        // search form
        m('div.search', [
            m('form', {
                "onsubmit": submitSearchForm
            }, [
                m('input', {
                    "type": "text",
                    "name": "s",
                    "placeholder": "Search password..",
                    "autocomplete": "off",
                    "autofocus": "on"
                }),
                m('input', {
                    "type": "submit",
                    "value": "Search",
                    "style": "display: none;"
                })
            ])
        ]),

        // results
        m('div.results', results)
    ];
}

function submitSearchForm(e) {
    e.preventDefault();

    // don't search without input.
    if( ! this.s.value.length ) {
        return;
    }

    searchPassword(this.s.value);
}

function init(tab) {
    // do nothing if called from a non-tab context
    if( ! tab || ! tab.url ) {
        return;
    }

    if(tab.url.startsWith("about:")) {
        //Handle firefox tabs
        return;
    }

    console.log(tab.url);

    activeTab = tab;
    var activeDomain = parseDomainFromUrl(tab.url);
    searchPassword(activeDomain);
}

function searchPassword(_domain) {
    searching = true;
    logins = null;
    domain = _domain;
    urlDuringSearch = activeTab.url;
    m.redraw();

    console.log("Send message");
    chrome.runtime.sendNativeMessage(app, { "action": "search", "domain": _domain }, function(response) {
        console.log("Receive response");
        console.log(response)
        if( chrome.runtime.lastError ) {
            console.log("Error");
            console.log(chrome.runtime.lastError);
        }

        searching = false;
        logins = response;
        console.log("Logins: " + logins);
        m.redraw();
    });
}

function parseDomainFromUrl(url) {
    var a = document.createElement('a');
    a.href = url;
    return a.hostname;
}

function getFaviconUrl(domain){

    // use current favicon when searching for current tab
    if(activeTab && activeTab.favIconUrl && activeTab.favIconUrl.indexOf(domain) > -1) {
        return activeTab.favIconUrl;
    }

    return 'icon-key.svg';
}

function getLoginData() {
    searching = true;
    logins = null;
    m.redraw();

    chrome.runtime.sendNativeMessage(app, { "action": "get", "entry": this }, function(response) {
        if( chrome.runtime.lastError) {
            console.log(chrome.runtime.lastError);
        }

        searching = false;
        fillLoginForm(response);
    });
}

// fill login form & submit
function fillLoginForm(login) {
    // do not send login data to page if URL changed during search.
    if( activeTab.url != urlDuringSearch ) {
        return false;
    }

    var code = `
  (function(d) {
	function queryAllVisible(parent, selector, form) {
	  var result = [];
	  var elems = parent.querySelectorAll(selector);
	  for (var i=0; i < elems.length; i++) {
		// Elem or its parent has a style 'display: none',
		// or it is just too narrow to be a real field (a trap for spammers?).
		if (elems[i].offsetWidth < 50 || elems[i].offsetHeight < 10) { continue; }
		// Select only elements from specified form
		if (form && form != elems[i].form) { continue; }

		var style = window.getComputedStyle(elems[i]);
		// Elem takes space on the screen, but it or its parent is hidden with a visibility style.
		if (style.visibility == 'hidden') { continue; }

		// This element is visible, will use it.
		result.push(elems[i]);
	  }
	  return result;
	}

	function queryFirstVisible(parent, selector, form) {
	  var elems = queryAllVisible(parent, selector, form);
	  return (elems.length > 0) ? elems[0] : undefined;
	}

	function form() {
	  var passwordField = queryFirstVisible(d, 'input[type=password]', undefined);
	  return (passwordField && passwordField.form) ? passwordField.form : undefined;
	}

	function field(selector) {
	  return queryFirstVisible(d, selector, form()) || document.createElement('input');
	}

	function update(el, value) {
	  if( ! value.length ) {
		return false;
	  }

	  el.setAttribute('value', value);
	  el.value = value;

	  var eventNames = [ 'click', 'focus', 'keypress', 'keydown', 'keyup', 'input', 'blur', 'change' ];
	  eventNames.forEach(function(eventName) {
		el.dispatchEvent(new Event(eventName, {"bubbles":true}));
	  });
	  return true;
	}

	if (typeof form() === 'undefined') {
	  return;
	}

	update(field('input[type=password]'), ${JSON.stringify(login.p)});
	update(field('input[type=email], input[type=text], input:first-of-type'), ${JSON.stringify(login.u)});

	var password_inputs = queryAllVisible(form(), 'input[type=password]');
	if (password_inputs.length > 1) {
	  password_inputs[1].select();
	} else {
		window.requestAnimationFrame(function() {
 field('[type=submit]').click(); 
		});
	 }
  })(document);
  `;
    chrome.tabs.executeScript({ code: code, allFrames: true });
    window.close();
}
