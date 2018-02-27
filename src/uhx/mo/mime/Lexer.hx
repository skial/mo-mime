package uhx.mo.mime;

import uhx.mo.Token;
import byte.ByteData;
import hxparse.Lexer;
import haxe.ds.StringMap;

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
	Toplevel(name:String);
	//Tree(name:String);
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
}

/*enum MimeTrees {
	Standard(name:String);
	Vendor(name:String);
	Personal(name:String);
	Unregistered(name:String);
}*/

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
	var _Tree = '([$Chars]+\\.)+';
	var _Vnd = '$Vnd[$Chars]*([$Chars]+\\.?)*';
	var _Prs = '$Prs[$Chars]*([$Chars]+\\.?)*';
	var _X = '$X[$Chars]*([$Chars]+\\.?)*';
	var _Suffix = '\\+[$Chars]*';
	var _Parameters = '; +$_Standards=$_Standards';
}

class Lexer extends hxparse.Lexer {

	public function new(content:ByteData, name:String) {
		super( content, name );
	}
	
	/*public static var root = Mo.rules( [
	'[ \r\n\t]+' => lexer.token( root ),
	'[a-zA-Z\\-_]+\\/' => Keyword( Toplevel( lexer.current.substring(0, lexer.current.length - 1).toLowerCase() ) ),
	'[a-zA-Z\\-_]+' => Keyword( Subtype( lexer.current ) ),
	'([a-zA-Z0-9\\-\\._]+)+\\.' => Keyword( Tree( lexer.current ) ),
	'\\+[a-zA-Z0-9\\-_]+' => Keyword( Suffix( lexer.current.substring(1, lexer.current.length) ) ),
	'; +[a-zA-Z0-9\\-_]+=[a-zA-Z0-9\\-]+' => {
		var pair = lexer.current.substring(1, lexer.current.length).trim().split( '=' );
		Keyword( Parameter( pair[0], pair[1] ) );
	},
	"" => EOF
	] );*/

	public static var root = Mo.rules( [
		'[$Whitespace]+' => lexer.token( root ),
		'[$Chars]+\\/' => Keyword( Toplevel( lexer.current.substring( 0, lexer.current.length-1 ).toLowerCase() ) ),
		'$_Vnd' => Keyword( Tree( Vendor, lexer.current.substring( Vnd.length-1, lexer.current.length ) ) ),
		'$_Prs' => Keyword( Tree( Personal, lexer.current.substring( Prs.length-1, lexer.current.length ) ) ),
		'$_X' => Keyword( Tree( Unregistered, lexer.current.substring( X.length-1, lexer.current.length ) ) ),
		'$_Tree' => Keyword( Tree( Unknown, lexer.current ) ),
		'$_Standards' => Keyword( Subtype( lexer.current ) ),
		'$_Suffix' => Keyword( Suffix( lexer.current.substring(1, lexer.current.length) ) ),
		'$_Parameters' => {
			var pair = lexer.current.substring(1, lexer.current.length).trim().split( '=' );
			Keyword( Parameter( pair[0], pair[1] ) );
		},
		'' => EOF
	] );
	
}