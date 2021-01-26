// We're using a global variable to store the number of occurrences
var _AJRSearchResultCount = 0;
var _AJRCurrentSearchResult = 0;

// helper function, recursively searches in elements and their child nodes
function _AJRHighlightAllOccurencesOfStringForElement(element, keyword, addHighlight) {
    if (element) {
        if (element.nodeType == 3) {            // Text node
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.toLowerCase().indexOf(keyword);
                
                if (idx < 0) break;             // not found, abort
                
                var span = document.createElement("span");
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                span.setAttribute("class","__ajrHighlight");
                span.setAttribute("id", "__ajr:" + _AJRSearchResultCount);
                if (addHighlight) {
                    span.style.backgroundColor="yellow";
                    span.style.borderBottom="2px solid orange";
                    span.style.color="black";
                }
                text = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
                _AJRSearchResultCount++;    // update the counter
            }
        } else if (element.nodeType == 1) { // Element node
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                var count = element.childNodes.length;
                for (var i = 0; i < count; i++) {
                    _AJRHighlightAllOccurencesOfStringForElement(element.childNodes[i], keyword, addHighlight);
                }
            }
        }
    }
}

// the main entry point to start the search
function _AJRHighlightAllOccurencesOfString(keyword, addHighlight) {
    _AJRRemoveAllHighlights();
    _AJRHighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase(), addHighlight);
    return true;
}

// helper function, recursively removes the highlights in elements and their childs
function _AJRRemoveAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == "__ajrHighlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i = element.childNodes.length - 1; i >= 0; i--) {
                    if (_AJRRemoveAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}

function _AJRSelectSearchedText(index) {
    if (index >= 0 && index < _AJRSearchResultCount) {
        var startElement = document.getElementById("__ajr:" + index);
        if (startElement) {
            var selection = document.getSelection();
            selection.removeAllRanges();
            var range = document.createRange();
            range.selectNode(startElement);
            selection.addRange(range);
            startElement.scrollIntoViewIfNeeded();
            return true;
        }
    }
    return false;
}

function _AJRSelectNext() {
    if (_AJRSearchResultCount > 0) {
        _AJRCurrentSearchResult = _AJRCurrentSearchResult + 1;
        if (_AJRCurrentSearchResult >= _AJRSearchResultCount) {
            _AJRCurrentSearchResult = 0;
        }
        return _AJRSelectSearchedText(_AJRCurrentSearchResult);
    }
    return false;
}

function _AJRSelectPrevious() {
    if (_AJRSearchResultCount > 0) {
        _AJRCurrentSearchResult = _AJRCurrentSearchResult - 1;
        if (_AJRCurrentSearchResult < 0) {
            _AJRCurrentSearchResult = _AJRSearchResultCount - 1;
        }
        return _AJRSelectSearchedText(_AJRCurrentSearchResult);
    }
    return false;
}

// the main entry point to remove the highlights
function _AJRRemoveAllHighlights() {
    _AJRSearchResultCount = 0;
    _AJRCurrentSearchResult = 0;
    _AJRRemoveAllHighlightsForElement(document.body);
}
