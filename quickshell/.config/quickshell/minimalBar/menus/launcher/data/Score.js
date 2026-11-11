.pragma library

/* Launcher ranking: match quality + learned usage.

 Each indexed item carries lowercased fields: _t (title), _w (title words),
 _a (title initials, e.g. "vsc" for Visual Studio Code), _k (keywords + generic
 name + comment), _kw (keyword words), _c (categories) and id (desktop id).

 Per token, the BEST tier wins (tiers no longer stack, so a stray letter in a
 comment can't push a weak match past a strong one). Every token must match
 something or the item is dropped.

 On top of that sit two learned boosts, both read from the usage store:
   - query memory: how often this exact typed query (or a prefix of it) ended in
     launching this app -> after a launch or two, one letter is enough
   - frecency: launch count weighted by recency -> the apps you use most float
     up inside a tier and lead the list on an empty query */

var EXACT = 1000;      // whole query == title
var PREFIX = 800;      // title starts with token
var WORD = 650;        // a title word starts with token
var ACRONYM = 550;     // title initials start with token ("vsc", "lo")
var TITLE = 400;       // substring anywhere in title
var KW_WORD = 250;     // a keyword/generic-name word starts with token
var KW_SUB = 150;      // substring in keywords (3+ chars only, avoids noise)
var CATEGORY = 80;     // category substring (3+ chars only)
var FUZZY = 40;        // in-order subsequence in title (+ compactness bonus)

var QUERY_MAX = 900;   // ceiling for the learned query->app boost
var FREC_MAX = 300;    // ceiling for the frecency boost

function startsAnyWord(words, t) {
    for (var i = 0; i < words.length; i++)
        if (words[i].indexOf(t) === 0)
            return true;
    return false;
}

// in-order subsequence match; returns 0 for none, else a bonus that rewards
// tight matches ("ffx" in "firefox" beats "ffx" spread over a long name)
function fuzzy(hay, t) {
    if (t.length < 2)
        return 0;
    var pos = -1, first = -1;
    for (var i = 0; i < t.length; i++) {
        pos = hay.indexOf(t[i], pos + 1);
        if (pos < 0)
            return 0;
        if (first < 0)
            first = pos;
    }
    var span = pos - first + 1;
    return FUZZY + Math.round(60 * t.length / span);
}

function tokenScore(item, t) {
    if (item._t.indexOf(t) === 0)
        return PREFIX;
    if (startsAnyWord(item._w, t))
        return WORD;
    if (t.length >= 2 && item._a.indexOf(t) === 0)
        return ACRONYM;
    if (item._t.indexOf(t) >= 0)
        return TITLE;
    if (startsAnyWord(item._kw, t))
        return KW_WORD;
    if (t.length >= 3 && item._k.indexOf(t) >= 0)
        return KW_SUB;
    if (t.length >= 3 && item._c.indexOf(t) >= 0)
        return CATEGORY;
    return fuzzy(item._t, t);
}

function matchScore(item, q, tokens) {
    if (q === item._t)
        return EXACT + PREFIX * (tokens.length - 1);
    var total = 0;
    for (var i = 0; i < tokens.length; i++) {
        var s = tokenScore(item, tokens[i]);
        if (s === 0)
            return 0;
        total += s;
    }
    return total;
}

// launches decay with age: today counts 4x, this week 2x, this month 1x, older 0.4x
function frecency(rec, now) {
    if (!rec || !rec.count)
        return 0;
    var age = (now - (rec.last || 0)) / 86400000;
    var w = age < 1 ? 4 : age < 7 ? 2 : age < 30 ? 1 : 0.4;
    return rec.count * w;
}

function frecencyBoost(rec, now) {
    var f = frecency(rec, now);
    return f > 0 ? Math.min(FREC_MAX, Math.round(70 * Math.log(1 + f))) : 0;
}

// hits recorded for this exact query, falling back to the longest recorded
// prefix of it (typing past a learned query keeps the association alive)
function queryBoost(queries, q, id) {
    for (var len = q.length; len > 0; len--) {
        var bucket = queries[q.slice(0, len)];
        if (bucket && bucket[id]) {
            var b = Math.round(400 * Math.log(1 + bucket[id]));
            // a prefix association is weaker than an exact one
            if (len < q.length)
                b = Math.round(b * 0.5);
            return Math.min(QUERY_MAX, b);
        }
    }
    return 0;
}

// usage = { apps: { id: {count, last} }, queries: { q: { id: hits } } }
function scoreItem(item, q, tokens, usage, now) {
    var rec = usage.apps[item.id];
    if (!tokens.length)
        return 1 + frecency(rec, now);
    var m = matchScore(item, q, tokens);
    if (m === 0)
        return 0;
    return m + frecencyBoost(rec, now) + queryBoost(usage.queries, q, item.id);
}

function alpha(a, b) {
    return a.item._t < b.item._t ? -1 : (a.item._t > b.item._t ? 1 : 0);
}

// empty query: most used first, then alphabetical
function compareBrowse(a, b) {
    return b.score !== a.score ? b.score - a.score : alpha(a, b);
}

// typed query: shorter titles win ties ("Code" before "Code - OSS Insiders")
function compare(a, b) {
    if (b.score !== a.score)
        return b.score - a.score;
    if (a.item._t.length !== b.item._t.length)
        return a.item._t.length - b.item._t.length;
    return alpha(a, b);
}

// record a launch: bump the app and every prefix of the query that found it
function record(usage, id, q, now) {
    var rec = usage.apps[id] || { count: 0, last: 0 };
    rec.count += 1;
    rec.last = now;
    usage.apps[id] = rec;
    for (var len = 1; len <= Math.min(q.length, 12); len++) {
        var key = q.slice(0, len);
        var bucket = usage.queries[key] || {};
        bucket[id] = (bucket[id] || 0) + 1;
        usage.queries[key] = bucket;
    }
    return usage;
}
