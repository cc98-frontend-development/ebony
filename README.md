ebony
=====

  EBONY is a responsive grid framework that derives from IVORY.
It provides basic stylesheets for the new CC98.org front-end.

Ebony is composed of:

A responsive grid framework modified from [ivory](http://weice.in/ivory/);
A CSS normalization forked from [normalize.css](http://necolas.github.io/normalize.css/);
A newly developed [Markup Language](http://cc98-frontend-development.github.io/ebony/ml.html);
A syntax highlighter from [highlight.js](http://highlightjs.org/);
A MVVC library from [knockout](http://knockoutjs.com/);
A evented js library from [Sammy.js](http://www.sammyjs.org/);
An icon font type from [glyphicons](http://glyphicons.com/) provided as a part of [bootstrap](http://getbootstrap.com/);
An emoji font type from [emoji symbols](http://emojisymbols.com/);
Color themes of a white and black style which is example of future color themes.

----

Demo [here](http://cc98-frontend-development.github.io/ebony).

The Markup Language's Tutorial is [here](http://cc98-frontend-development.github.io/ebony/ml_tutorial.html).

Need node.js installed.

	npm install 

if too slow (because of GFW) try this before:

    npm config set registry http://registry.cnpmjs.org 

then (on linux)

    make

or you may need manually build EBONY

use:

    npm test

to run a test server.

----

Usage: 

The \*.less file is complied into css file.

Javascript libraries are bundled and minified into bundle.min.js.

    
    var $ = require('jquery');  //jquery
    var grammar = require('grammar');   //low level ML parser and JSML generator
    require('jsml-jquery');     //load the jquery-plugin, for render JSML into HTML
    var hljs = require('highlight.js'); //stand alone highlight.js

    var ML = require('ML');     //for rendering ML file. And an external MathML js file should be loaded to render Math Symbols.

    var ko = require('knockout');   //MVVC framework

    require('Sammy');   //load the Sammy event driven library.
