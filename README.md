# mo-mime

[Mo](https://github.com/skial/mo)'s mime / internet media type lexer & parser.

> https://en.wikipedia.org/wiki/Internet_media_type

> `top-level type name / subtype name [ ; parameters ]`
> `top-level type name / [ tree. ] subtype name [ +suffix ] [ ; parameters ]`

## Installation

1. [hxparse] - `https://github.com/Simn/hxparse development src`
2. [mo] - `haxelib git mo https://github.com/skial/mo master src`
3. mo-mime - `haxelib git mo-mime https://github.com/skial/mo-mime master src`

[mo]: https://github.com/skial/mo "Mo's base lexer and parser utilities based on hxparse."
[hxparse]: http://github.com/simn/hxparse "Haxe Lexer and Parser Library."

## Usage

```Haxe
import uhx.mo.mime.Parser;

class Main {
    public static function main() {
        var parser = new Parser();
        trace( parser.toTokens( 'application/vnd.a; charset=UTF-8', 'some id' ) ); // [Keyword(Toplevel('application')), Keyword(Tree(Vendor, 'a')), Keyword(Parameter('charset', 'UTF-8'))]
    }
}
```

## Types

### `MimeToplevel`

```Haxe
@:enum abstract MimeToplevel {
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
```

### `MimeTree`

```Haxe
@:enum abstract MimeTree {
    var Standard = 0;
    var Vendor = 1;
    var Personal = 2;
    var Unregistered = 3;
    var Unknown = 4;

    @:to private inline function asString():String;
}
```

### `MimeKeywords`

```Haxe
@:enum MimeKeywords {
    Toplevel(name:MimeToplevel);
    Tree(type:MimeTree, subtype:String);
    Subtype(name:String);
    Suffix(name:String);
    Parameter(name:String, value:String);
}
```