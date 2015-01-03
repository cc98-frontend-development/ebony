/* Following code is used with PEG.js v0.8.
 * The PEG.js is not considered stable for now.
 * We need to follow its progression, and change the
 * code correspondingly to newer version of PEG.js
 * James Ruan<ruanbeihong@gmail.com>
*/
{
    /* Initializer */
    var _DEBUG_ = false;
    var TAGS = (function (){
            var tag_define = [
            /*	[tagname, html_tag, prefix, suffix] */
            ["article", "article"],
            ["h1", "h1"],
            ["h2", "h2"],
            ["h3", "h3"],
            ["h4", "h4"],
            ["h5", "h5"],
            ["h6", "h6"],
            ["subh", "small"],
            ["p", "p"],
            ["bq", "blockquote"],
            ["bq+", "blockquote"],
            ["code", "code"],
            ["pre", "pre"],
            ["abbr", "abbr"],
            ["strong", "strong"],
            ["emphasis", "em"],
            ["mark", "mark"],
            ["insert", "ins"],
            ["delete", "del"],
            ["i", "i"],
            ["cite", "cite"],
            ["alert", "div"],
            ["code_@", "code"],
            ["math_$", "span", "\\(", "\\)"],
            ["pre", "pre"],
            ["list*", "ul"],
            ["list#", "ol"],
            ["*", "li"],
            ["href", "a"],
            ["table", "table"],
            ["table_cap", "caption"],
            ["table_body", "tbody"],
            ["tr", "tr"],
            ["th", "th"],
            ["td", "td"],
            ["figure", "figure"],
            ["img", "img"],
            ["math", "div", "\\[", "\\]"],
            /* primitives */
            ["size", "span"],
            ["color", "span"],
            ["bgcolor", "span"],
            ["shadow", "span"],
            ["emoji", "span"]
                ];

    var full_tag_def = function (old, item){
        old[item[0]]={"tag": item[1], "prefix": item[2], "suffix":item[3]};
        return old;
    }

    return tag_define.reduce(full_tag_def, {});
    }).call(this);

    function mkInt(string_arr)
    {
        return parseInt(string_arr.join(""), 10);
    }

    function mkStr(text)
    {
        return text
            .replace(/&/g, '&amp;' )
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    function merge_array(to, from){
        var not_empty = function (t){
            return t?true:false;
        };
        return to.concat(from.filter(not_empty));
    }

    function gen_tag(child, tag, attr){
        /*
         * (child, tag ,attr, sibling) => [tag {attr} child]
         */
        if(_DEBUG_){
            var log = "[";
            if(tag)
                log += "TAG: ";
            log += JSON.stringify(tag);
            if(attr)
                log += "\n\tATTR: ";
            log += JSON.stringify(attr);
            if(child)
                log += "\n\tCHILD: ";
            log += JSON.stringify(child);
            log += "]";
            console.log(log);
        }
        var arr=[TAGS[tag].tag];

        if(attr)
            arr.push(attr);

        child.unshift(TAGS[tag].prefix);
        child.push(TAGS[tag].suffix);

        return merge_array(arr, child);
    };
}

start
= Blocks
/ isEof

Blocks
= a:Block+
{return gen_tag(a,"article",{"class":"row"});}

Block
= Blank_line BLSP
{return undefined;}
/(Figure
 /BQuote
 /Table
 /BQCite
 /Alert
 /Code
 /Math
 /Image
 /List
 /HRule
 /Heading
 /Para
 /Plain)


/* Block Elements */

Figure
= BBC_Figure / TeX_Figure

BBC_Figure
=t:BBC_Figure_start a:BBC_Figure_content BBC_Figure_end
{
	var attr;
	if(t === ".")
		attr = {"class":"text-center"};
	else if(t === ">")
		attr = {"class":"text-right"};
	else
		attr = {"class":"text-left"};

	return gen_tag(a, "figure", attr);
}

BBC_Figure_start
= "[" Figure_tag t:[<\.>]? "]" BLSP
{return t;}

BBC_Figure_content
= a:(!BBC_Figure_end a:Block {return a;})+
{return a;}

BBC_Figure_end
= BLSP "[/" Figure_tag [<\.>]? "]" BLSP

TeX_Figure
= t:TeX_Figure_start a:TeX_Figure_content TeX_Figure_end
{
	var attr;
	if(t === ".")
		attr = {"class":"text-center"};
	else if(t === ">")
		attr = {"class":"text-right"};
	else
		attr = {"class":"text-left"};
	return gen_tag(a, "figure", attr);
}

TeX_Figure_start
= "\\" Figure_tag t:[<\.>]? BLSP "{begin}" BLSP
{return t;}

TeX_Figure_content
= a:(!TeX_Figure_end a:Block {return a;})+
{return a;}

TeX_Figure_end
= BLSP "\\" Figure_tag [<\.>]? BLSP "{end}" BLSP

Figure_tag
= "fig"


Image
= BBC_Image / TeX_Image

BBC_Image
= f:BBC_Image_start a:BBC_Image_content BBC_Image_end
{
	var attr;
	if(f === "<")
		attr={"src":a, "class":"left"};
	else if(f === ">")
		attr={"src":a, "class":"right"};
	else
		attr={"src":a, "class":"centered"};
	return gen_tag([], "img", attr);
}

BBC_Image_start
= "[" Image_tag f:[<>]? "]" _
{return f;}

BBC_Image_content
= !BBC_Image_end a:Image_link
{return a;}

BBC_Image_end
= _ "[/" Image_tag [<>]? "]" BLSP

TeX_Image
= f:TeX_Image_start a:TeX_Image_content TeX_Image_end
{
	var attr;
	if(f === "<")
		attr={"src":a, "class":"left"};
	else if(f === ">")
		attr={"src":a, "class":"right"};
	else
		attr={"src":a, "class":"centered"};
	return gen_tag([], "img", attr);
}

TeX_Image_start
= "\\" Image_tag f:[<>]? BLSP "{" _
{return f;}

TeX_Image_content
= !TeX_Image_end a:Image_link
{return a;}

TeX_Image_end
= _ "}" BLSP

Image_link = URL

Image_tag
= "img"


Table
= BBC_Table / TeX_Table

BBC_Table
= c:BBC_Table_start r:BBC_Table_Rows BBC_Table_end
{
    var arr;
	if(c){
		arr = gen_tag([gen_tag(c, "table_cap")], "table");
		arr.push(r);
	}
	else
		arr = gen_tag([r], "table");
	return arr;
}

BBC_Table_start
= "[" _ Table_tag c:BBC_Table_start_option? "]" BLSP
{return c;}

BBC_Table_start_option
= "{" _ a:(!(_ "}") a:Inline{return a;})+ _ "}" {return a;}

BBC_Table_Rows
= a:(!BBC_Table_end a:BBC_Table_Row{return a;})+
{return gen_tag(a, "table_body");}

BBC_Table_Row
= "[r]" BLSP
c:(!"[/r]" a:BBC_Table_Cell{return a;})+
 "[/r]" BLSP
{return gen_tag(c, "tr");}

BBC_Table_Cell
= !Inline
a:(&"[h" a:BBC_Table_Header {return a;}
/ &"[d" a:BBC_Table_Data {return a;})
{return a;}

BBC_Table_Header
= "[h" attr:Table_Cell_span? "]"
  h:(!BBC_Table_Cell a:Inline{return a;})+ BLSP
{
	return gen_tag(h, "th", attr);
}

BBC_Table_Data
= "[d" attr:Table_Cell_span? "]"
  d:(!BBC_Table_Cell a:Inline{return a;})+ BLSP
{
	return gen_tag(d, "td", attr);
}

BBC_Table_end
= BLSP "[/" Table_tag "]" BLSP

TeX_Table
= c:TeX_Table_start r:TeX_Table_Rows TeX_Table_end
{
    var arr;
	if(c)
	{
		arr = gen_tag([gen_tag(c, "table_cap")], "table");
		arr.push(r);
	}
	else
		arr = gen_tag([r], "table");
	return arr;
}

TeX_Table_start
= "\\" Table_tag c:TeX_Table_start_option? BLSP "{begin}" BLSP
{return c;}

TeX_Table_start_option
= "[" _ a:(!(_ "]") a:Inline{return a;})+ _ "]" {return a;}

TeX_Table_Rows
= a:(!TeX_Table_end a:TeX_Table_Row{return a;})+
{return gen_tag(a, "table_body");}

TeX_Table_Row
= "\\r" BLSP "{" BLSP
c:(!"}" a:TeX_Table_Cell{return a;})+
 "}" BLSP
{return gen_tag(c, "tr");}

TeX_Table_Cell
= !Inline
a:(&"\\h" a:TeX_Table_Header {return a;}
/ &"\\d" a:TeX_Table_Data {return a;})
{return a;}


TeX_Table_Header
= "\\h" attr:Table_Cell_span?
  h:(!TeX_Table_Cell a:Inline{return a;})+ BLSP
{
	return gen_tag(h, "th", attr);
}

TeX_Table_Data
= "\\d" attr:Table_Cell_span?
  d:(!TeX_Table_Cell a:Inline{return a;})+ BLSP
{
	return gen_tag(d, "td", attr);
}

TeX_Table_end
= BLSP "\\" Table_tag BLSP "{end}" BLSP

Table_Cell_span
= (r:Table_Cell_row_span c:Table_Cell_col_span{
	return {"rowSpan":r, "colSpan":c};}
 / c:Table_Cell_col_span r:Table_Cell_row_span{
	return {"rowSpan":r, "colSpan":c};})
/ (r:Table_Cell_row_span {return {"rowSpan":r};}
 / c:Table_Cell_col_span {return {"colSpan":c};})

Table_Cell_row_span
= "r" n:[0-9]+
{return mkInt(n);}

Table_Cell_col_span
= "c" n:[0-9]+
{return mkInt(n);}

Table_tag
= "table"


Code
= BBC_Code / TeX_Code

BBC_Code
= h:BBC_Code_start a:BBC_Code_content BBC_Code_end
{
	if(h === "+")
		return gen_tag([gen_tag([a], "code")], "pre");
    else if(h)
		return gen_tag([gen_tag([a], "code", {"class":"language-"+h})], "pre");
	else
		return gen_tag([gen_tag([a], "code", {"class":"no-highlight"})], "pre");
}

BBC_Code_start
= "[" Code_tag
 h:("+"
 a:("{" _ a:Code_option _ "}" {return a;})?
{if(a)
    return a;
 else
    return "+";}
 )?
 "]" Blank_line*
{return h;}

BBC_Code_content
=a:(!BBC_Code_end !BBC_Code_start a:. {return a;})+
{return mkStr(a.join(""));};

BBC_Code_end
= BLSP "[/" Code_tag "+"? "]" BLSP

TeX_Code
= h:TeX_Code_start a:TeX_Code_content TeX_Code_end
{
	if(h === "+")
		return gen_tag([gen_tag([a], "code")], "pre");
    else if(h)
		return gen_tag([gen_tag([a], "code", {"class":"language-"+h})], "pre");
	else
		return gen_tag([gen_tag([a], "code", {"class":"no-highlight"})], "pre");
}

TeX_Code_start
= "\\" Code_tag
 h:("+"
 a:("[" _ a:Code_option _ "]" {return a;})?
{if(a)
    return a;
 else
    return "+";}
 )?
 BLSP "{begin}" Blank_line*
{return h;}

TeX_Code_content
= a:(!TeX_Code_end !TeX_Code_start a:. {return a;})+
{return mkStr(a.join(""));};

TeX_Code_end
= BLSP "\\" Code_tag "+"? BLSP "{end}" BLSP

Code_option
="css"i {return "css";}
/("cs"i /"c#"i) {return "cs";}
/("cv"i /"py"i /"python"i) {return "python";}
/("cl"i /"el"i /"lisp"i /"lsp"i /"scm"i /"ss"i /"rkt"i) {return "lisp";}
/"coffee"i {return "coffeescript";}
/("c"i /"cxx"i /"cc"i /"cpp"i / "c++"i) {return "cpp";}
/("erlang"i /"erl") {return "erlang";}
/"go"i {return "go";}
/("htm"i /"html"i) {return "html";}
/"lua"i {return "lua";}
/("m"i /"matlab"i) {return "matlab";}
/"http"i {return "http";}
/("haskell"i /"hs"i) {return "haskell";}
/"json"i {return "json";}
/("js"i /"javascript"i) {return "javascript";}
/"java"i {return "java";}
/"php"i {return "php";}
/("pm"i /"pl"i /"perl"i) {return "perl";}
/("rb"i /"ruby"i) {return "ruby";}
/("r"i /"s"i/ "splus"i) {return "r";}
/"scala"i {return "scala";}
/"swift"i {return "swift";}
/"sql"i {return "sql";}
/"tex"i {return "tex";}
/"xhtml"i {return "xhtml";}
/"xml"i {return "xml";}



Code_tag
= "code"


Alert
= BBC_Alert / TeX_Alert

BBC_Alert
= o:BBC_Alert_start a:Alert_content BBC_Alert_end
{
	var attr;
	if(o)
		attr={"class":"alert"+" "+o};
	else
		attr={"class":"alert"};
	return gen_tag(a, "alert", attr);
}

BBC_Alert_start
= "[" Alert_tag o:BBC_Alert_option? "]" BLSP
{return o;}

BBC_Alert_option
= "{" _ !(_ "}") a:Alert_option _ "}"
{return a;}

BBC_Alert_end
= BLSP "[/" Alert_tag "]" BLSP

TeX_Alert
= o:TeX_Alert_start a:Alert_content TeX_Alert_end
{
	var attr;
	if(o)
		attr={"class":"alert"+" "+o};
	else
		attr={"class":"alert"};
	return gen_tag(a, "alert", attr);
}

TeX_Alert_start
= "\\" Alert_tag o:TeX_Alert_option? "{" BLSP
{return o;}

TeX_Alert_option
= "[" _ !(_ "]") a:Alert_option _ "]"
{return a;}

TeX_Alert_end
= BLSP "}" BLSP

Alert_content
= a:(!BBC_Alert_end !TeX_Alert_end !Alert a:Inline{return a;})+
{
	return a;
}

Alert_tag
= "alert"

Alert_option
= "info"
/ "success"
/ "error"


Math
= BBC_Math / TeX_Math

BBC_Math
= BBC_Math_start a:BBC_Math_content BBC_Math_end
{
	return gen_tag([a], "math");
}

BBC_Math_start
= "[" Math_tag "]" BLSP

BBC_Math_content
= a:( !BBC_Math_end !BBC_Math a:. {return a;})+
{return mkStr(a.join(""));}

BBC_Math_end
= BLSP "[/" Math_tag "]" BLSP

TeX_Math
= TeX_Math_start a:TeX_Math_content TeX_Math_end
{
	return gen_tag([a], "math");
}

TeX_Math_start
= "\\" Math_tag BLSP "{begin}" BLSP

TeX_Math_content
= a:( !TeX_Math_end !TeX_Math a:. {return a;})+
{return mkStr(a.join(""));}

TeX_Math_end
= BLSP "\\" Math_tag BLSP "{end}" BLSP

Math_tag
= "math"


BQuote
= BBC_BQuote / TeX_BQuote

BBC_BQuote
=t:BBC_BQuote_start a:BBC_BQuote_content BBC_BQuote_end BLSP
{
	var attr = {"class":"pull-quote"};
	if(t)
		return gen_tag(a, "bq+", attr);
	else
		return gen_tag(a, "bq");
}

BBC_BQuote_start
= "[" BQuote_tag t:"+"? "]" BLSP
{return t;}

BBC_BQuote_content
= a:(!BBC_BQuote_end a:Block{return a;})+
{return a;}

BBC_BQuote_end
= BLSP "[/" BQuote_tag "+"? "]" BLSP


TeX_BQuote
= t:TeX_BQuote_start a:TeX_BQuote_content TeX_BQuote_end BLSP
{
	var attr = {"class":"pull-quote"};
	if(t)
		return gen_tag(a, "bq+", attr);
	else
		return gen_tag(a, "bq");
}

TeX_BQuote_start
= "\\" BQuote_tag t:"+"? BLSP "{begin}" BLSP
{return t;}

TeX_BQuote_content
= a:(!TeX_BQuote_end a:Block{return a;})+
{return a;}

TeX_BQuote_end
= BLSP "\\" BQuote_tag "+"? BLSP "{end}" BLSP

BQuote_tag
= "bq"


BQCite
= BBC_BQCite / TeX_BQCite

BBC_BQCite
= BBC_BQCite_start a:( !BBC_BQCite_end !BQCite a:Inline {return a;})+ BBC_BQCite_end
{
	return gen_tag(a, "cite", {"class":"bq-cite"});
}

BBC_BQCite_start
= "[" Cite_tag "+]"

BBC_BQCite_end
="[/" Cite_tag "+]" BLSP

TeX_BQCite
= TeX_BQCite_start a:( !TeX_BQCite_end !BQCite a:Inline {return a;})+ TeX_BQCite_end
{
	return gen_tag(a, "cite", {"class":"bq-cite"});
}

TeX_BQCite_start
= "\\" Cite_tag "+" BLSP "{"

TeX_BQCite_end
= BLSP "}" BLSP


List
= BBC_List / TeX_List

BBC_List
= BBC_OL_start a:BBC_List_Items BBC_OL_end
{return gen_tag(a,"list#");}
/ BBC_UL_start a:BBC_List_Items BBC_UL_end
{return gen_tag(a,"list*");}

BBC_OL_start
= "[" OL_tag "]" BLSP

BBC_OL_end
= BLSP "[/" OL_tag "]" BLSP

BBC_UL_start
= "[" UL_tag "]" BLSP

BBC_UL_end
= BLSP "[/" UL_tag "]" BLSP

TeX_List
= TeX_OL_start a:TeX_List_Items TeX_OL_end
{return gen_tag(a,"list#");}
/ TeX_UL_start a:TeX_List_Items TeX_UL_end
{return gen_tag(a,"list*");}

TeX_OL_start
= "\\" OL_tag BLSP "{" BLSP

TeX_OL_end
= BLSP "}" BLSP

TeX_UL_start
= "\\" UL_tag BLSP "{" BLSP

TeX_UL_end
= BLSP "}" BLSP

OL_tag
= "list#"

UL_tag
= "list*"

BBC_List_Items
= a:(!BBC_OL_end !BBC_UL_end a:BBC_List_Item{return a;})+
{return a;}

BBC_List_Item
= "[*]" BLSP a:BBC_List_Inline_Item b:BBC_List? BLSP
{
	if(b)
		return gen_tag(merge_array(a,[b]),"*");
	else
		return gen_tag(a,"*");
}

BBC_List_Inline_Item
= a:(!("[*]" BBC_List_Inline_Item) !"[*]" a:Inline{return a;})+ BLSP
{return a;}

TeX_List_Items
= a:(!TeX_OL_end !TeX_UL_end a:TeX_List_Item{return a;})+
{return a;}

TeX_List_Item
= "\\*" BLSP a:TeX_List_Inline_Item b:TeX_List? BLSP
{
	if(b)
		return gen_tag(merge_array(a,[b]),"*");
	else
		return gen_tag(a,"*");
}

TeX_List_Inline_Item
= a:(!("\\*" TeX_List_Item) !"\\*" a:Inline{return a;})+ BLSP
{return a;}


HRule
= ("[hline]" BLSP / "\\hline" BLSP)
{return ["hr"];}


Heading
= BBC_Heading / TeX_Heading

BBC_Heading
= t:BBC_Heading_start a:Heading_content BBC_Heading_end
{
	return [gen_tag(a, t)];
}

BBC_Heading_start
= "[" t:Heading_tag "]" BLSP
{return t;}

BBC_Heading_end
= BLSP "[/" Heading_tag "]" BLSP

TeX_Heading
= t:TeX_Heading_start a:Heading_content TeX_Heading_end
{
	return gen_tag(a, t);
}

TeX_Heading_start
= "\\" t:Heading_tag BLSP "{" BLSP
{return t;}

TeX_Heading_end
= BLSP "}" BLSP

Heading_tag
= a:"h" b:[1-6]
{
 	return a+b;
}

Heading_content
= a:(!BBC_Heading_end !TeX_Heading_end !Heading a:(Subheading/ Inline){return a;})+
{
	return a;
}

Subheading
= BBC_Subheading / TeX_Subheading

BBC_Subheading
= t:BBC_Subheading_start a:Subheading_content BBC_Subheading_end
{
	return gen_tag(a, t);
}

BBC_Subheading_start
= "[" t:Subheading_tag "]" BLSP
{return t;}

BBC_Subheading_end
= "[/" Subheading_tag "]" BLSP

TeX_Subheading
= t:TeX_Subheading_start a:Subheading_content TeX_Subheading_end
{
	return gen_tag(a, t);
}

TeX_Subheading_start
= "\\" t:Subheading_tag BLSP "{" BLSP
{return t;}

TeX_Subheading_end
= "}" BLSP

Subheading_tag
= "subh"

Subheading_content
= a:(!Heading !Subheading a:Inline{return a;})+
{
	return a;
}


Para
= a:(!Block_end a:Inline{return a;})+ Block_end
{return gen_tag(a, "p");}

Plain
= a:Inlines Block_end
{
	return gen_tag(a, "p");
}

/* Inline: span level element */
Inlines
= c:(!Endline a:Inline
 {return a;}
 / b:Endline !Endline
 {return b;})+
{return c;}

Inline
= Anchor
/ Toanchor
/ HRef
/ Abbr
/ Strong
/ Emphasis
/ Mark
/ Insert
/ Delete
/ Latin
/ Cite
/ Code_inline
/ Math_inline
/ Primitive_inline
/ Str
/ Endline
/ Space
/ Escape


Anchor = BBC_Anchor / TeX_Anchor

BBC_Anchor
= BBC_Anchor_start a:BBC_Anchor_content BBC_Anchor_end
{
	var attr={"id":"inpage-anchor-"+a};
	return gen_tag([], "href", attr);
}

BBC_Anchor_start
= "["Anchor_tag"]" _

BBC_Anchor_content
= a:(!BBC_Anchor_end a:(Str/Space){return a;})+
{return a.join("");}

BBC_Anchor_end
= _ "[/"Anchor_tag"]"

TeX_Anchor
= TeX_Anchor_start a:TeX_Anchor_content TeX_Anchor_end
{
	var attr={"id":"inpage-anchor-"+a};
	return gen_tag([], "href", attr);
}

TeX_Anchor_start
= "\\"Anchor_tag BLSP "{" _

TeX_Anchor_content
= a:(!TeX_Anchor_end a:(Str/Space){return a;})+
{return a.join("");}

TeX_Anchor_end
= _ "}"

Anchor_tag
= "anchor"


Toanchor = BBC_Toanchor / TeX_Toanchor

BBC_Toanchor
= o:BBC_Toanchor_start a:BBC_Toanchor_content BBC_Toanchor_end
{
	var attr={"href":"#inpage-anchor-"+a};
	if(o)
		return gen_tag(o, "href", attr);
	else
		return gen_tag([a], "href", attr);
}

BBC_Toanchor_start
= "["Toanchor_tag o:BBC_Toanchor_optional_text? "]" _
{return o;}

BBC_Toanchor_optional_text
= "{" _ a:(!(_ "}") a:Inline{return a;})+ _ "}"
{return a;}

BBC_Toanchor_content
= a:(!BBC_Anchor_end a:(Str/Space){return a;})+
{return a.join("");}

BBC_Toanchor_end
= _ "[/"Toanchor_tag"]"

TeX_Toanchor
= o:TeX_Toanchor_start a:TeX_Toanchor_content TeX_Toanchor_end
{
	var attr={"href":"#inpage-anchor-"+a};
	if(o)
		return gen_tag(o, "href", attr);
	else
		return gen_tag([a], "href", attr);
}

TeX_Toanchor_start
= "\\"Toanchor_tag o:TeX_Toanchor_optional_text? BLSP "{" _
{return o;}

TeX_Toanchor_optional_text
= "[" _ a:(!(_ "]") a:Inline{return a;})+ _ "]"
{return a;}

TeX_Toanchor_content
= a:(!TeX_Toanchor_end a:(Str/Space){return a;})+
{return a.join("");}

TeX_Toanchor_end
= _ "}"

Toanchor_tag
= "toanchor"


HRef = BBC_HRef / TeX_HRef

BBC_HRef
= to:BBC_HRef_start a:BBC_HRef_content BBC_HRef_end
{
	var attr={"href":a};
	var attrb={"href":a, "class":"new-window", "target":"blank"};
	if(to.t){
		if(to.o)
			return gen_tag(to.o, "href", attrb);
		else
			return gen_tag(a, "href", attrb);
	}
	else{
		if(to.o)
			return gen_tag(to.o, "href", attr);
		else
			return gen_tag(a, "href", attr);
	}
}

BBC_HRef_start
= "[" HRef_tag t:"+"? o:BBC_HRef_optional_text? "]"
{return {"t":t ,"o":o};}

BBC_HRef_optional_text
= "{" _ o:(!HRef !(_ "}") a:Inline{return a;})+ _ "}"
{return o;}

BBC_HRef_content
= !HRef a:HRef_link
{return a;}

BBC_HRef_end
= "[/" HRef_tag "+"? "]"

TeX_HRef
= to:TeX_HRef_start a:TeX_HRef_content TeX_HRef_end
{
	var attr={"href":a};
	var attrb={"href":a, "class":"new-window", "target":"blank"};
	if(to.t){
		if(to.o)
			return gen_tag(to.o, "href", attrb);
		else
			return gen_tag([a], "href", attrb);
	}
	else{
		if(to.o)
			return gen_tag(to.o, "href", attr);
		else
			return gen_tag([a], "href", attr);
	}
}

TeX_HRef_start
= "\\" HRef_tag t:"+"? o:TeX_HRef_optional_text? BLSP "{"
{return {"t":t, "o":o};}

TeX_HRef_optional_text
= "[" _ o:(!HRef !(_ "]") a:Inline{return a;})+ _ "]"
{return o;}

TeX_HRef_content
= !HRef a:HRef_link
{return a;}

TeX_HRef_end
= "}"

HRef_tag
= "link"

HRef_link = URL

/* TODO: URL is potentially buggy */
URL = _ a:URL_Scheme ":" b:URL_Str _ {return a+":"+b;}
/_ b:URL_Str _ {return b;}

URL_Scheme
= !":" a:URL_Scheme_allowed
{return a.toLowerCase();}

URL_Scheme_allowed
= "ftp"i
/ "http"i
/ "https"i
/ "mailto"i

URL_Possible_End
= _ (BBC_HRef_end
   / TeX_HRef_end
   / BBC_Image_end
   / TeX_Image_end)

URL_Str = a:(!URL_Possible_End a:.{return a;})+
{return encodeURI(a.join(""));}

Escape
= '\\' !Newline a:Special_char
{return a;}

Str = a:Normal_char+
{return mkStr(a.join(""));}

Endline =  a:Line_break {return a;}/ Newline {return undefined;}

Line_break = ("  " _ Newline / ( _ "\\newline" / "[newline]" ) _ Newline?)
{return ["br"];}


Abbr
= BBC_Abbr / TeX_Abbr

BBC_Abbr
= title:BBC_Abbr_start
a:( !BBC_Abbr_end !Abbr a:Inline {return a;})+
BBC_Abbr_end
{
	var attr = {"data-title":title};
	return gen_tag(a, "abbr", attr);
}

BBC_Abbr_start
= "[" Abbr_tag "{" _ title:( !(_ "}") a:. {return a;})+ _ "}" "]" BLSP
{return mkStr(title.join(""));}

BBC_Abbr_end
= BLSP "[/" Abbr_tag "]"

TeX_Abbr
= title:TeX_Abbr_start
a:( !TeX_Abbr_end !Abbr a:Inline {return a;})+
TeX_Abbr_end
{
	var attr = {"data-title":title};
	return gen_tag(a, "abbr", attr);
}

TeX_Abbr_start
= "\\" Abbr_tag "[" _ title:( !(_ "]") a:. {return a;})+ _ "]" BLSP "{" BLSP
{return mkStr(title.join(""));}

TeX_Abbr_end
= BLSP "}"

Abbr_tag
= "abbr"


Strong
= BBC_Strong / TeX_Strong

BBC_Strong
= BBC_Strong_start a:(!BBC_Strong_end !Strong a:Inline {return a;})+ BBC_Strong_end
{return gen_tag(a, "strong");}

BBC_Strong_start
= "[" Strong_tag "]" BLSP

BBC_Strong_end
= BLSP "[/" Strong_tag "]"

TeX_Strong
= TeX_Strong_start a:(!TeX_Strong_end !Strong a:Inline {return a;})+ TeX_Strong_end
{return gen_tag(a, "strong");}

TeX_Strong_start
= "\\" Strong_tag BLSP "{" BLSP

TeX_Strong_end
= BLSP "}"

Strong_tag
= "strong"


Emphasis
= BBC_Emphasis / TeX_Emphasis

BBC_Emphasis
= BBC_Emphasis_start a:(!BBC_Emphasis_end !Emphasis a:Inline {return a;})+ BBC_Emphasis_end
{return gen_tag(a, "emphasis");}

BBC_Emphasis_start
= "[" Emphasis_tag "]" BLSP

BBC_Emphasis_end
= BLSP "[/" Emphasis_tag "]"

TeX_Emphasis
= TeX_Emphasis_start a:(!TeX_Emphasis_end !Emphasis a:Inline {return a;})+ TeX_Emphasis_end
{return gen_tag(a, "emphasis");}

TeX_Emphasis_start
= "\\" Emphasis_tag BLSP "{" BLSP

TeX_Emphasis_end
= BLSP "}"

Emphasis_tag
= "emphasis"


Mark
= BBC_Mark / TeX_Mark

BBC_Mark
= BBC_Mark_start a:(!BBC_Mark_end !Mark a:Inline {return a;})+ BBC_Mark_end
{return gen_tag(a, "mark");}

BBC_Mark_start
= "[" Mark_tag "]" BLSP

BBC_Mark_end
= BLSP "[/" Mark_tag "]"

TeX_Mark
= TeX_Mark_start a:(!TeX_Mark_end !Mark a:Inline {return a;})+ TeX_Mark_end
{return gen_tag(a, "mark");}

TeX_Mark_start
= "\\" Mark_tag BLSP "{" BLSP

TeX_Mark_end
= BLSP "}"

Mark_tag
= "mark"


Insert
= BBC_Insert / TeX_Insert

BBC_Insert
= BBC_Insert_start a:(!BBC_Insert_end !Insert a:Inline {return a;})+ BBC_Insert_end
{return gen_tag(a, "insert");}

BBC_Insert_start
= "[" Insert_tag "]" BLSP

BBC_Insert_end
= BLSP "[/" Insert_tag "]"

TeX_Insert
= TeX_Insert_start a:(!TeX_Insert_end !Insert a:Inline {return a;})+ TeX_Insert_end
{return gen_tag(a, "insert");}

TeX_Insert_start
= "\\" Insert_tag BLSP "{" BLSP

TeX_Insert_end
= BLSP "}"

Insert_tag
= "insert"


Delete
= BBC_Delete / TeX_Delete

BBC_Delete
= BBC_Delete_start a:(!BBC_Delete_end !Delete a:Inline {return a;})+ BBC_Delete_end
{return gen_tag(a, "delete");}

BBC_Delete_start
= "[" Delete_tag "]" BLSP

BBC_Delete_end
= BLSP "[/" Delete_tag "]"

TeX_Delete
= TeX_Delete_start a:(!TeX_Delete_end !Delete a:Inline {return a;})+ TeX_Delete_end
{return gen_tag(a, "delete");}

TeX_Delete_start
= "\\" Delete_tag BLSP "{" BLSP

TeX_Delete_end
= BLSP "}"

Delete_tag
= "delete"


Cite
= BBC_Cite / TeX_Cite

BBC_Cite
= BBC_Cite_start a:(!BBC_Cite_end !Cite a:Inline {return a;})+ BBC_Cite_end
{return gen_tag(a, "cite");}

BBC_Cite_start
= "[" Cite_tag "]" BLSP

BBC_Cite_end
= BLSP "[/" Cite_tag "]"

TeX_Cite
= TeX_Cite_start a:(!TeX_Cite_end !Cite a:Inline {return a;})+ TeX_Cite_end
{return gen_tag(a, "cite");}

TeX_Cite_start
= "\\" Cite_tag BLSP "{" BLSP

TeX_Cite_end
= BLSP "}"

Cite_tag
= "cite"


Latin
= BBC_Latin / TeX_Latin

BBC_Latin
= BBC_Latin_start a:(!BBC_Latin_end !Latin a:Inline {return a;})+ BBC_Latin_end
{return gen_tag(a, "i");}

BBC_Latin_start
= "[" Latin_tag "]" BLSP

BBC_Latin_end
= BLSP "[/" Latin_tag "]"

TeX_Latin
= TeX_Latin_start a:(!TeX_Latin_end !Latin a:Inline {return a;})+ TeX_Latin_end
{return gen_tag(a, "i");}

TeX_Latin_start
= "\\" Latin_tag BLSP "{" BLSP

TeX_Latin_end
= BLSP "}"

Latin_tag
= "i"


Code_inline
= BBC_Code_inline / TeX_Code_inline

BBC_Code_inline
= BBC_Code_inline_start a:BBC_Code_inline_content BBC_Code_inline_end
{
	return gen_tag([a], "code_@", {"class": "code-inline"});
}

BBC_Code_inline_start
= "[" Code_inline_tag "]" _

BBC_Code_inline_content
= a:( !BBC_Code_inline_end !BBC_Code_inline a:. {return a;})+
{return mkStr(a.join(""));}

BBC_Code_inline_end
= _ "[/" Code_inline_tag "]"

TeX_Code_inline
= TeX_Code_inline_start a:TeX_Code_inline_content TeX_Code_inline_end
{
	return gen_tag([a], "code_@", {"class": "code-inline"});
}

TeX_Code_inline_start
= "\\" Code_inline_tag _

TeX_Code_inline_content
= a:( !TeX_Code_inline_end !TeX_Code_inline a:. {return a;})+
{return mkStr(a.join(""));}

TeX_Code_inline_end
= _ "\\" Code_inline_tag

Code_inline_tag
= "@"


Math_inline
= BBC_Math_inline / TeX_Math_inline

BBC_Math_inline
= BBC_Math_inline_start a:BBC_Math_inline_content BBC_Math_inline_end
{
	return gen_tag([a], "math_$");
}

BBC_Math_inline_start
= "[" Math_inline_tag "]" _

BBC_Math_inline_content
= a:( !BBC_Math_inline_end !BBC_Math_inline a:. {return a;})+
{return mkStr(a.join(""));}

BBC_Math_inline_end
= _ "[/" Math_inline_tag "]"

TeX_Math_inline
= TeX_Math_inline_start a:TeX_Math_inline_content TeX_Math_inline_end
{
	return gen_tag([a], "math_$");
}

TeX_Math_inline_start
= "\\" Math_inline_tag _

TeX_Math_inline_content
= a:( !TeX_Math_inline_end !TeX_Math_inline a:. {return a;})+
{return mkStr(a.join(""));}

TeX_Math_inline_end
= _ "\\" Math_inline_tag

Math_inline_tag
= "$"


Primitive_inline
= Size
/ Color
/ Shadow

Size
= BBC_Size / TeX_Size

BBC_Size
= o:BBC_Size_start a:(!BBC_Size_end !Size a:Inline {return a;})+ BBC_Size_end
{
    var attr={"style":"font-size: " + o};
    return gen_tag(a, "size", attr);
}

BBC_Size_start
= "[" Size_tag o:BBC_Size_option "]" BLSP
{return o;}

BBC_Size_option
= "{" _ o:Size_option _ "}"
{return o;}

BBC_Size_end
= BLSP "[/" Size_tag "]"

TeX_Size
= o:TeX_Size_start a:(!TeX_Size_end !Size a:Inline {return a;})+ TeX_Size_end
{
    var attr={"style":"font-size: " + o};
    return gen_tag(a, "size", attr);
}

TeX_Size_start
= "\\" Size_tag o:TeX_Size_option BLSP "{" BLSP
{return o;}

TeX_Size_option
= "[" _ o:Size_option _ "]"
{return o;}

TeX_Size_end
= BLSP "}"

Size_option
= "smaller"
/ "xx-small"
/ "x-small"
/ "small"
/ "medium"
/ "large"
/ "x-large"
/ "xx-large"
/ "larger"

Size_tag
= "size"


Color
= BBC_Color / TeX_Color

BBC_Color
= o:BBC_Color_start a:(!BBC_Color_end !Color a:Inline {return a;})+ BBC_Color_end
{
    var attr;
    if(o.t === "color")
        attr={"style":"color: " + o.c};
    else
        attr={"style":"background-color: " + o.c};

    return gen_tag(a, o.t, attr);
}

BBC_Color_start
= "[" t:Color_tag o:BBC_Color_option "]" BLSP
{return {"t": t, "c":o};}

BBC_Color_option
= "{" _ o:Color_option _ "}"
{return o;}

BBC_Color_end
= BLSP "[/" Color_tag "]"

TeX_Color
= o:TeX_Color_start a:(!TeX_Color_end !Color a:Inline {return a;})+ TeX_Color_end
{
    var attr;
    if(o.t === "color")
        attr={"style":"color: " + o.c};
    else
        attr={"style":"background-color: " + o.c};

    return gen_tag(a, o.t, attr);
}

TeX_Color_start
= "\\" t:Color_tag o:TeX_Color_option BLSP "{" BLSP
{return {"t": t, "c":o};}

TeX_Color_option
= "[" _ o:Color_option _ "]"
{return o;}

TeX_Color_end
= BLSP "}"

Color_option
= "#" r:_HEX2 g:_HEX2 b:_HEX2
{
    return "#"+r.concat(g).concat(b).join("");
}

_HEX2
= [0-9a-f]i [0-9a-f]i

Color_tag
= "color" / "bgcolor"

Shadow
= BBC_Shadow / TeX_Shadow

BBC_Shadow
= o:BBC_Shadow_start a:(!BBC_Shadow_end !Shadow a:Inline {return a;})+ BBC_Shadow_end
{
    var attr={"style":"text-shadow: " + o};
    return gen_tag(a, "shadow", attr);
}

BBC_Shadow_start
= "[" Shadow_tag o:BBC_Shadow_option "]" BLSP
{return o;}

BBC_Shadow_option
= "{" _ o:Shadow_option _ "}"
{return o;}

BBC_Shadow_end
= BLSP "[/" Shadow_tag "]"

TeX_Shadow
= o:TeX_Shadow_start a:(!TeX_Shadow_end !Shadow a:Inline {return a;})+ TeX_Shadow_end
{
    var attr={"style":"text-shadow: " + o};
    return gen_tag(a, "shadow", attr);
}

TeX_Shadow_start
= "\\" Shadow_tag o:TeX_Shadow_option BLSP "{" BLSP
{return o;}

TeX_Shadow_option
= "[" _ o:Shadow_option _ "]"
{return o;}

TeX_Shadow_end
= BLSP "}"

Shadow_option
= x:[0-9]+ _ "," _ y:[0-9]+ _ "," _ z:[0-9]+ _ "," _ c:Color_option
{return x.join("")+"px "+y.join("")+"px "+z.join("")+"px "+c;}

Shadow_tag
= "shadow"

Normal_char
= !(Special_char/ Space_char / Newline) a:.
{return a;}

Space = Space_char+
{return " ";}

/*Combinations*/
Block_end
= Blank_line Blank_line
/ Blank_line !Para !Plain &Block
/ Blank_line isEof
/isEof

Blank_line "blank line"
= _ Newline _

/* for matching leading spacechar before tag */
BLSP
= _ Blank_line* _

_ "whitespace"
= Space_char*

/*Constants*/

Space_char = [\t ]

Newline = "\r\n" / "\n"


Special_char
= "\\"
/ '['
/ ']'
/ '{'
/ '}'
/ '\"'

/*Predicates*/

isEof
= !.

isEol
= &Newline
