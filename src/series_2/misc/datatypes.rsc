module series_2::misc::datatypes

data ClonePair = ClonePair(snip l, snip r);

// Confusing sometimes but otherwise handy
alias codeAst = value;
//code snippet
alias snip = tuple[loc location, codeAst code];
alias snips = rel[loc location, codeAst code];
//code attributes
alias att = tuple[int sloc,int cc]; 
//Clone pair
alias cpair = tuple[snip first, snip second];
//this is a bitch to type
alias cmaps = tuple [map[codeAst, snips] c, map[att, set[codeAst]] m];