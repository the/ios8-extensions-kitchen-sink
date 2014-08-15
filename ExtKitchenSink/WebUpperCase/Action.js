//
//  Action.js
//  WebUpperCase
//
//  Created by Thomas Eichmann on 15.08.14.
//  Copyright (c) 2014 Thomas Eichmann. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    upperCaseChildNodes: function(node) {
        for (var i = 0; i < node.childNodes.length; i++) {
            var childNode = node.childNodes[i];

            if (childNode.tagName === 'script' || childNode.tagName === 'style') {
                return;
            }

            if (childNode.nodeType === 1 /* element */) {
                this.upperCaseChildNodes(childNode);
            } else if (childNode.nodeType === 3 /* text node */) {
                childNode.nodeValue = childNode.nodeValue.toUpperCase();
            } else {
                // unhandled node
            }
        }
    },

    run: function(arguments) {
        // Here, you can run code that modifies the document and/or prepares
        // things to pass to your action's native code.

        this.upperCaseChildNodes(document.body);
        var documentTitle = document.head.getElementsByTagName('title')[0].textContent;

        arguments.completionFunction({'documentTitle':documentTitle});
    },
    
    finalize: function(arguments) {
        // This method is run after the native code completes.
        
        var newDocumentTitle = arguments['newDocumentTitle'];

        if (newDocumentTitle) {
            document.head.getElementsByTagName('title')[0].textContent = newDocumentTitle;
            alert(newDocumentTitle);
        }
    }
};
    
var ExtensionPreprocessingJS = new Action();
