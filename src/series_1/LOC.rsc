module series_1::testParsingLOC

import IO;
import Exception;
import ParseTree;
import List;

layout Standard = WhitespaceOrComment* !>> [\ \t\n\r] !>> "//";

start syntax LinesOfCode = Statement*;

lexical WhitespaceOrComment 
  = whitespace: Whitespace
  | comment: Comment
  ; 

lexical Whitespace
  = [\t-\n \a0C-\a0D \ ]
  ;

lexical Comment =
  "/**/" 
  | "//" EOLCommentChars !>> ![\n \a0D] [\ \t\n\r] 
  | "/*" !>> [*] CommentPart* "*/" 
  | "/**" !>> [/] CommentPart* "*/" 
  ;
lexical BlockCommentChars =
  ![* \\]+ 
  ;
  lexical EOLCommentChars =
  ![\n \a0D]* 
  ;
 lexical UnicodeEscape =
   unicodeEscape: "\\" [u]+ [0-9 A-F a-f] [0-9 A-F a-f] [0-9 A-F a-f] [0-9 A-F a-f] 
  ;
lexical EscChar =
  "\\" 
  ;
lexical CommentPart =
  UnicodeEscape 
  | BlockCommentChars !>> ![* \\] 
  | EscChar !>> [\\ u] 
  | "*" !>> [/] 
  | "\\\\" 
  ;

lexical Statement = ![WhitespaceOrComment];


int getLOCLines(loc locc) {
	Tree tree;
	try {
		tree = parse(#start[LinesOfCode], readFile(locc));
	} catch Error(e): {
		println("Error <e> at <l>");
	}

	if ((LinesOfCode)`<Statement* st>` := tree.top) {
		return sum([ *{ s@\loc.begin.line | Statement s <- st}]);
	}

	return 0;
}