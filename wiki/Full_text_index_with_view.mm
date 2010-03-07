I wanted to throw this idea out there to see what people thought.

There has been a lot of discussion about integrating full text search into couch and possibly implementing full text search in Erlang. Would it be worth investigating the use of CouchDB's !MapReduce functionality to implement a full text indexer? I whipped together a short example using views. It implements a simple white space tokenizer in !JavaScript, emits each token with it's doc id and position, and reduces each token to a list of doc ids and positions.

Here is the map function:

{{{
function(doc) 
{
    var tokenEmit = function(token) {
        emit([token.value,token.field], [this._id,token.position]);
    }
    
    var whiteSpaceAnalyzer = function(str, field) {
        // Returns tokens split by white space
        // token: { value: tokenString, position: [0,10] }
        var len = str.length;
        var tokenPositions = new Array();
        var startPosition = null;

        var isTokenChar = function(Char) {
            if (Char === ' ' || Char === '\t' || Char === '\n')
                return false;
            return true;
        }

        for(var i=0; i < len; i++)
        {
            if(startPosition == null)
            {
                if(isTokenChar(str[i]))
                {
                    // start of word
                    startPosition = i;
                    if( i+1 == len )
                    {
                        // end of string
                        tokenPositions[tokenPositions.length] = [startPosition, i+1];
                    }
                }
            }
            else
            {
                if(!isTokenChar(str[i]))
                {
                    // end of word
                    tokenPositions[tokenPositions.length] = [startPosition, i];
                    startPosition = null; // reset startPosition
                    continue;
                }
                
                if( i+1 == len )
                {
                    // end of string
                    tokenPositions[tokenPositions.length] = [startPosition, i+1];
                }
            }
        }

        var tokenMap = function(tokenPosition) {
            var token = this.str.substring(tokenPosition[0],tokenPosition[1]);
            return { value: token, field:this.field, position: tokenPosition };
        }
        
        return tokenPositions.map(tokenMap,{str:str,field:field});
    }
    
    var tokens;
    
    for (field in doc) {
        if (typeof(doc[field])=='string') {
            tokens = whiteSpaceAnalyzer(doc[field], field);
            tokens.map(tokenEmit, doc);
        }
    }
}
}}}

Here is the reduce function:

{{{
function(keys,values,combine)
{
    var result = new Array();
    var docHash = new Array();
    if(combine) 
    {
        for(var v in values)
        {
            var docObject = values[v][0];
            var docId = docObject["doc"];
            var positions = docObject["pos"];
            if(docHash[docId] == null)
            {
                docHash[docId]=new Array();
            }
            docHash[docId] = docHash[docId].concat(positions);
        }
        for(var i in docHash){
            result[result.length]={doc:i,pos:docHash[i]};
        }
    }
    else
    {
        for(var j in values)
        {
            var docId = values[j][0];
            var position = values[j][1];
            if(docHash[docId] == null)
            {
            docHash[docId]=new Array();
            }
            docHash[docId] = docHash[docId].concat([position]);
        }
        for(var i in docHash){
            result[result.length]={doc:i,pos:docHash[i]};
        }
    }
    return result;  
}
}}}

The key emitted from the view is {{{["token","field"]}}}. This allows terms to be searched per field while also allowing the use of group_level=1 to combine the results of all fields. Combining results of multiple fields currently eliminates the use of positions.

To reduce the amount of information passed during view generation the whiteSpaceAnalyzer function can be moved to the main.js file.

Is this worth pursuing further?
___

After pursuing this a little further, here's an expanded version of the above m/r functions, modified to support stemming (via porter), optional case-insensitivity, min-length for tokens, wider whitespace handling (still english-centric though).

Here's the map function: options can be set in the options object at the top, as well whitespace and ignore words, then the porter stemming function (which could get sucked into main.js as noted by Dan). I still have no idea how to do any kind of boolean operations.

{{{
options = {
  stem: porter_stem,
  min_length: 3,
  case_sensitive: false,
  ignore_words: true
};

token_chars = [' ', 'h', '.', ',', ':', '\  ', '\
'];

// list of fields to not index
// defaults set to ['type'] as a common usecase
ignore_fields = ['type'];

ignore_words = [
  'about','after','all','also','an','and','another','any','are','as','at','be','because',
  'been','before','being','between','both','but','by','came','can','come',
  'could','did','do','each','for','from','get','got','has','had','he',
  'have','her','here','him','himself','his','how','if','in','into','is',
  'it','like','make','many','me','might','more','most','much','must','my',
  'never','now','of','on','only','or','other','our','out','over','said',
  'same','see','should','since','some','still','such','take','than',
  'that','the','their','them','then','there','these','they','this','those',
  'through','to','too','under','up','very','was','way','we','well','were',
  'what','where','which','while','who','with','would','you','your','a','b',
  'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
  'u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'
];


// Porter stemmer in Javascript. Few comments, but it's easy to follow against 
// the rules in the original paper, in
//
//  Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
//  no. 3, pp 130-137,
//
// see also http://www.tartarus.org/~martin/PorterStemmer

// Release 1

step2list = new Array();
step2list["ational"]="ate";
step2list["tional"]="tion";
step2list["enci"]="ence";
step2list["anci"]="ance";
step2list["izer"]="ize";
step2list["bli"]="ble";
step2list["alli"]="al";
step2list["entli"]="ent";
step2list["eli"]="e";
step2list["ousli"]="ous";
step2list["ization"]="ize";
step2list["ation"]="ate";
step2list["ator"]="ate";
step2list["alism"]="al";
step2list["iveness"]="ive";
step2list["fulness"]="ful";
step2list["ousness"]="ous";
step2list["aliti"]="al";
step2list["iviti"]="ive";
step2list["biliti"]="ble";
step2list["logi"]="log";

step3list = new Array();
step3list["icate"]="ic";
step3list["ative"]="";
step3list["alize"]="al";
step3list["iciti"]="ic";
step3list["ical"]="ic";
step3list["ful"]="";
step3list["ness"]="";

c = "[^aeiou]";          // consonant
v = "[aeiouy]";          // vowel
C = c + "[^aeiouy]*";    // consonant sequence
V = v + "[aeiou]*";      // vowel sequence

mgr0 = "^(" + C + ")?" + V + C;               // [C]VC... is m>0
meq1 = "^(" + C + ")?" + V + C + "(" + V + ")?$";  // [C]VC[V] is m=1
mgr1 = "^(" + C + ")?" + V + C + V + C;       // [C]VCVC... is m>1
s_v   = "^(" + C + ")?" + v;                   // vowel in stem

function porter_stem(w) {
	var stem;
	var suffix;
	var firstch;
	var origword = w;

	if (w.length < 3) { return w; }

   	var re;
   	var re2;
   	var re3;
   	var re4;

	firstch = w.substr(0,1);
	if (firstch == "y") {
		w = firstch.toUpperCase() + w.substr(1);
	}

	// Step 1a
   	re = /^(.+?)(ss|i)es$/;
   	re2 = /^(.+?)([^s])s$/;

   	if (re.test(w)) { w = w.replace(re,"$1$2"); }
   	else if (re2.test(w)) {	w = w.replace(re2,"$1$2"); }

	// Step 1b
	re = /^(.+?)eed$/;
	re2 = /^(.+?)(ed|ing)$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		re = new RegExp(mgr0);
		if (re.test(fp[1])) {
			re = /.$/;
			w = w.replace(re,"");
		}
	} else if (re2.test(w)) {
		var fp = re2.exec(w);
		stem = fp[1];
		re2 = new RegExp(s_v);
		if (re2.test(stem)) {
			w = stem;
			re2 = /(at|bl|iz)$/;
			re3 = new RegExp("([^aeiouylsz])\\1$");
			re4 = new RegExp("^" + C + v + "[^aeiouwxy]$");
			if (re2.test(w)) {	w = w + "e"; }
			else if (re3.test(w)) { re = /.$/; w = w.replace(re,""); }
			else if (re4.test(w)) { w = w + "e"; }
		}
	}

	// Step 1c
	re = /^(.+?)y$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		stem = fp[1];
		re = new RegExp(s_v);
		if (re.test(stem)) { w = stem + "i"; }
	}

	// Step 2
	re = /^(.+?)(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		stem = fp[1];
		suffix = fp[2];
		re = new RegExp(mgr0);
		if (re.test(stem)) {
			w = stem + step2list[suffix];
		}
	}

	// Step 3
	re = /^(.+?)(icate|ative|alize|iciti|ical|ful|ness)$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		stem = fp[1];
		suffix = fp[2];
		re = new RegExp(mgr0);
		if (re.test(stem)) {
			w = stem + step3list[suffix];
		}
	}

	// Step 4
	re = /^(.+?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/;
	re2 = /^(.+?)(s|t)(ion)$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		stem = fp[1];
		re = new RegExp(mgr1);
		if (re.test(stem)) {
			w = stem;
		}
	} else if (re2.test(w)) {
		var fp = re2.exec(w);
		stem = fp[1] + fp[2];
		re2 = new RegExp(mgr1);
		if (re2.test(stem)) {
			w = stem;
		}
	}

	// Step 5
	re = /^(.+?)e$/;
	if (re.test(w)) {
		var fp = re.exec(w);
		stem = fp[1];
		re = new RegExp(mgr1);
		re2 = new RegExp(meq1);
		re3 = new RegExp("^" + C + v + "[^aeiouwxy]$");
		if (re.test(stem) || (re2.test(stem) && !(re3.test(stem)))) {
			w = stem;
		}
	}

	re = /ll$/;
	re2 = new RegExp(mgr1);
	if (re.test(w) && re2.test(w)) {
		re = /.$/;
		w = w.replace(re,"");
	}

	// and turn initial Y back to y

	if (firstch == "y") {
		w = firstch.toLowerCase() + w.substr(1);
	}

	return w;

}


function(doc) {
  var tokenEmit = function(token) {
    emit([token.value, token.field], [this._id, token.position]);
    if(typeof(options.stem) == 'function')
      emit([options.stem(token.value), token.field], [this._id, token.position]);
  }
  
  var stripIgnoreFields = function(token) {
    return (ignore_fields.indexOf(token.field.toLowerCase()) < 0);
  }
  
  var stripIgnoreWords = function(token) {
    return (ignore_words.indexOf(token.value) < 0);
  }
  
  var whiteSpaceAnalyzer = function(str, field) {
    // Returns tokens split by white space
    // token: {value:tokenString, position:[0,10]}
    var len = str.length;
    var tokenPositions = new Array();
    var startPosition = null;
    
    var isTokenChar = function(chr) {
      return !(token_chars.indexOf(chr) >= 0);
    }
    
    for(var i=0; i < len; i++) {
      if(startPosition == null) {
        if(isTokenChar(str[i])) {
          // start of word
          startPosition = i;
          if(i+1 == len)
            tokenPositions[tokenPositions.length] = [startPosition, i+1];
        }
      } else {
        if(!isTokenChar(str[i])) {
          // end of word
          tokenPositions[tokenPositions.length] = [startPosition, i];
          startPosition = null; // reset startPosition
          continue;
        }
             
        if(i+1 == len) {
          // end of string
          tokenPositions[tokenPositions.length] = [startPosition, i+1];
        }
      }
    }
    
    // kill all tokens shorter than min_length
    var newPositions = new Array();
    for(var i=0; i<tokenPositions.length; i++){
      if (tokenPositions[i][1] - tokenPositions[i][0] >= options.min_length)
        newPositions.push(tokenPositions[i]);
    }
    tokenPositions = newPositions;
    
    var tokenMap = function(tokenPosition) {
      var token = this.str.substring(tokenPosition[0], tokenPosition[1]);
      if (!options.case_sensitive)
        token = token.toLowerCase();
      return {value:token, field:this.field, position:tokenPosition};
    }
    
    return tokenPositions.map(tokenMap, {str:str, field:field});
  }
  
  var tokens;
  
  for (field in doc){
    if (field[0] != '_' && typeof(doc[field]) == 'string'){
      tokens = whiteSpaceAnalyzer(doc[field], field);
      tokens = tokens.filter(stripIgnoreFields);
      tokens = tokens.filter(stripIgnoreWords);
      tokens.map(tokenEmit, doc);
    }
  }
}
}}}

Here is the reduce function (mostly unchanged from above):

{{{
function(keys, values, combine) {
  var result = new Array();
  var docHash = new Array();
  if(combine) {
    for(var v in values){
      var docObject = values[v][0];
      var docId = docObject["doc"];
      var positions = docObject["pos"];
      if(docHash[docId] == null)
        docHash[docId] = new Array();
      docHash[docId] = docHash[docId].concat(positions);
    }
    for(var i in docHash) {
      result[result.length]={doc:i, pos:docHash[i]};
    }
  } else {
    for(var j in values) {
      var docId = values[j][0];
      var position = values[j][1];
      if(docHash[docId] == null)
        docHash[docId] = new Array();
      docHash[docId] = docHash[docId].concat([position]);
    }
    for(var i in docHash) {
      result[result.length] = {doc:i, pos:docHash[i]};
    }
  }
  return result;  
}
}}}
