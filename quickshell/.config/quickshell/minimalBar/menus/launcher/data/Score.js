.pragma library

// Weighted match scoring, ported from bjarneo/quickshell's OmniMenu.
/* Each indexed item carries three lowercased fields: _t (title), _k (keywords +
 generic name + comment) and _c (categories). Every query token must match at
 least one field or the whole item is rejected (return 0). Scores stack per
 token so more specific matches float to the top:
 title prefix 100 · title substring 60 · keyword 20 · category 10 */   

var PREFIX = 100;
var TITLE = 60;
var KEYWORD = 20;
var CATEGORY = 10;

function scoreItem(item, tokens) {
    var total = 0;
    for (var i = 0; i < tokens.length; i++) {
        var t = tokens[i];
        var sub = 0;
        if (item._t.indexOf(t) === 0)
            sub += PREFIX;
        else if (item._t.indexOf(t) >= 0)
            sub += TITLE;
        if (item._k.indexOf(t) >= 0)
            sub += KEYWORD;
        if (item._c.indexOf(t) >= 0)
            sub += CATEGORY;
        if (sub === 0)
            return 0; // a token matched to nothing -> drop the item
        total += sub;
    }
    return total;
}

function compare(a, b) {
    if (b.score !== a.score)
        return b.score - a.score;
    return a.item._t < b.item._t ? -1 : (a.item._t > b.item._t ? 1 : 0);
}
