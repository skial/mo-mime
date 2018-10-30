package ;

import haxe.io.Eof;
import utest.Assert;
import uhx.mo.Token;
import byte.ByteData;
import uhx.mo.mime.Lexer;
import uhx.mo.mime.Parser;

/**
 * ...
 * @author Skial Bainn
 */
@:keep class MimeSpec {

    public function new() {
        
    }
    
    private var parser = new Parser();

    public inline function parse(value:String):Array<Token<MimeKeywords>> {
        return parser.toTokens( ByteData.ofString( value ), 'mime-spec :: $value' );
    }
    
    public function testBasic() {
        var m = parse( 'text/plain' );
        
        Assert.isTrue( m.length == 2 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('text')) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
    }
    
    public function testBasic_withSuffix() {
        var m = parse( 'text/plain+xml' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('text')) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
    }
    
    public function testBasic_withSpacedSuffix() {
        var m = parse( 'text/plain +xml' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('text')) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
    }
    
    public function testBasic_withParameter() {
        var m = parse( 'text/plain; charset=UTF-8' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel(Text)) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
        Assert.isTrue( m[2].match( Keyword(Parameter('charset', 'UTF-8' )) ) );
    }
    
    public function testBasic_withMultiParameter() {
        var m = parse( 'text/plain; charset=UTF-8; NaMe123=vAlUe456' );
        
        Assert.isTrue( m.length == 4 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('text')) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
        Assert.isTrue( m[2].match( Keyword(Parameter('charset', 'UTF-8' )) ) );
        Assert.isTrue( m[3].match( Keyword(Parameter('NaMe123', 'vAlUe456' )) ) );
    }
    
    public function testBasic_withSuffixAndMultiParameter() {
        var m = parse( 'text/plain +xml; charset=UTF-8; NaMe123=vAlUe456' );
        
        Assert.isTrue( m.length == 5 );
        Assert.isTrue( m[0].match( Keyword(Toplevel(Text)) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('plain')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
        Assert.isTrue( m[3].match( Keyword(Parameter('charset', 'UTF-8' )) ) );
        Assert.isTrue( m[4].match( Keyword(Parameter('NaMe123', 'vAlUe456' )) ) );
    }
    
    public function testTree() {
        var m = parse( 'application/vnd.a' );
        
        Assert.isTrue( m.length == 2 );
        Assert.isTrue( m[0].match( Keyword(Toplevel(Application)) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
    }
    
    public function testTree_withSuffix() {
        var m = parse( 'application/vnd.a+xml' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
    }
    
    public function testTree_withSpacedSuffix() {
        var m = parse( 'application/vnd.a +xml' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
    }

    public function testTree_suffixMimeDB() {
        var m = parse( 'application/geo+json-seq' );
        
        Assert.equals( 3, m.length );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('geo')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('json-seq')) ) );

        var m = parse( 'application/emergencycalldata.comment+xml' );
        Assert.equals( 3, m.length );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Unknown, 'emergencycalldata.comment')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
    }

    public function testTree_characters() {
        var m = parse ( 'application/vnd.ntt-local.sip-ta_remote' );
        
        Assert.equals( 2, m.length );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'ntt-local.sip-ta_remote')) ) );

        var m = parse( 'audio/amr-wb+' );

        Assert.equals( 3, m.length );
        Assert.isTrue( m[0].match( Keyword(Toplevel(Audio)) ) );
        Assert.isTrue( m[1].match( Keyword(Subtype('amr-wb')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('')) ) );
    }
    
    public function testTree_withParameter() {
        var m = parse( 'application/vnd.a; charset=UTF-8' );
        
        Assert.isTrue( m.length == 3 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
        Assert.isTrue( m[2].match( Keyword(Parameter('charset', 'UTF-8')) ) );
    }
    
    public function testTree_withMultiParameter() {
        var m = parse( 'application/vnd.a; charset=UTF-8; NaMe123=vAlUe456' );
        
        Assert.isTrue( m.length == 4 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
        Assert.isTrue( m[2].match( Keyword(Parameter('charset', 'UTF-8')) ) );
        Assert.isTrue( m[3].match( Keyword(Parameter('NaMe123', 'vAlUe456' )) ) );
    }
    
    public function testTree_withSuffixAndMultiParameter() {
        var m = parse( 'application/vnd.a +xml; charset=UTF-8; NaMe123=vAlUe456' );
        
        Assert.isTrue( m.length == 5 );
        Assert.isTrue( m[0].match( Keyword(Toplevel(Application)) ) );
        Assert.isTrue( m[1].match( Keyword(Tree(Vendor, 'a')) ) );
        Assert.isTrue( m[2].match( Keyword(Suffix('xml')) ) );
        Assert.isTrue( m[3].match( Keyword(Parameter('charset', 'UTF-8' )) ) );
        Assert.isTrue( m[4].match( Keyword(Parameter('NaMe123', 'vAlUe456' )) ) );
    }
    
    public function testMultiTree() {
        var m = parse( 'application/vnd.a.b.1.2.3.opendocument' );
        
        Assert.isTrue( m.length == 2 );
        Assert.isTrue( m[0].match( Keyword(Toplevel('application')) ) );
        Assert.isTrue( m[1].match( Keyword(Tree( Vendor, 'a.b.1.2.3.opendocument')) ) );
    }
    
}