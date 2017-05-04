package uhx.mo.mime;

import haxe.io.Eof;
import byte.ByteData;
import uhx.mo.mime.Lexer;

/**
 * ...
 * @author Skial Bainn
 * @see https://en.wikipedia.org/wiki/Internet_media_type
 */
class Parser {

	public function new() {
		
	}
	
	public function toTokens(bytes:ByteData, name:String) {
		var lexer = new Lexer( bytes, name );
		var tokens = [];
		
		try while (true) {
			tokens.push( lexer.token( Lexer.root ) );
			
		} catch (e:Eof) { } catch (e:Dynamic) {
			trace( e );
		}
		
		return tokens;
	}
	
}