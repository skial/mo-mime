package uhx.mo.mime;

import uhx.mo.Token;
import byte.ByteData;
import hxparse.Ruleset;
import haxe.ds.StringMap;
import hxparse.Lexer as HxparseLexer;

using StringTools;

/**
 * ...
 * @author Skial Bainn
 * @see https://en.wikipedia.org/wiki/Internet_media_type
 * ---
 * top-level type name / subtype name [ ; parameters ]
 * top-level type name / [ tree. ] subtype name [ +suffix ] [ ; parameters ]
 */

enum MimeKeywords {
    Toplevel(name:MimeToplevel);
    Tree(type:MimeTree, subtype:String);
    Subtype(name:String);
    Suffix(name:String);
    Parameter(name:String, value:String);
}

@:enum abstract MimeToplevel(String) from String to String {
    var Text = 'text';
    var Image = 'image';
    var Video = 'video';
    var Audio = 'audio';
    var Application = 'application';
    var Multipart = 'multipart';
    var Font = 'font';
    var Message = 'message';
    var Model = 'model';
    var Example = 'example';
}

@:enum abstract MimeTree(Int) from Int to Int {
    var Standard = 0;
    var Vendor = 1;
    var Personal = 2;
    var Unregistered = 3;
    var Unknown = 4;

    @:to private inline function asString():String {
        return switch this {
            case Vendor: 'vnd.';
            case Personal: 'prs.';
            case Unregistered: 'x.';
            case _: '';
        }
    }
}

@:enum @:forward private abstract Rules(String) to String {
    var Whitespace = ' \r\n\t';
    var az = 'a-z';
    var AZ = 'A-Z';
    var No = '0-9';
    var Marks = '_\\-';
    var Chars = '$az$AZ$No$Marks';
    var Vnd = 'vnd\\.';
    var Prs = 'prs\\.';
    var X = 'x\\.';

    var _Standards = '[$Chars]+';
    var _Tree = '([$Chars]+\\.)+([$Chars]+\\.?)*';
    var _Vnd = '$Vnd[$Chars]*([$Chars]+\\.?)*';
    var _Prs = '$Prs[$Chars]*([$Chars]+\\.?)*';
    var _X = '$X[$Chars]*([$Chars]+\\.?)*';
    var _Suffix = '\\+[$Chars]*';
    var _Parameters = '; +$_Standards=$_Standards';
}

class Lexer extends HxparseLexer {

    public function new(content:ByteData, name:String) {
        super( content, name );
    }

    public static var root:Ruleset<Lexer, Token<MimeKeywords>> = Mo.rules( [
        '[$Whitespace]+' => lexer -> lexer.token( root ),
        '[$Chars]+\\/' => lexer -> Keyword( Toplevel( lexer.current.substring( 0, lexer.current.length-1 ).toLowerCase() ) ),
        '$_Vnd' => lexer -> Keyword( Tree( Vendor, lexer.current.substring( Vnd.length-1, lexer.current.length ) ) ),
        '$_Prs' => lexer -> Keyword( Tree( Personal, lexer.current.substring( Prs.length-1, lexer.current.length ) ) ),
        '$_X' => lexer -> Keyword( Tree( Unregistered, lexer.current.substring( X.length-1, lexer.current.length ) ) ),
        '$_Tree' => lexer -> Keyword( Tree( Unknown, lexer.current ) ),
        '$_Standards' => lexer -> Keyword( Subtype( lexer.current ) ),
        '$_Suffix' => lexer -> Keyword( Suffix( lexer.current.substring(1, lexer.current.length) ) ),
        '$_Parameters' => lexer -> {
            var pair = lexer.current.substring(1, lexer.current.length).trim().split( '=' );
            Keyword( Parameter( pair[0], pair[1] ) );
        },
        '' => _ -> EOF
    ] );
    
}