This page collects code snippets to be used in your [[Views]]. They are mainly meant to help get your head around the map/reduce approach to accessing database content. Keep in mind that the the Futon web client silently adds group=true to your views.

  * [[#common_mistakes|Common mistakes]]
  * [[#get_doc_id|Get docs with a particular user id ]]
  * [[#get_doc_with_attachment|Get all documents which have an attachment ]]
  * [[#count_doc_with_attachment|Count documents with and without an attachment]]
  * [[#list_unique_values|Generating a list of unique values]]
  * [[#top_n_tags|Retrieve the top N tags]]
  * [[#aggregate_sum|Joining an aggregate sum along with related data ]]
  * [[#standard_deviation|Computing the standard deviation]]
  * [[#summary_stats|Computing simple summary statistics (min,max,mean,standard deviation) ]]
  * [[#interactive_couchdb|Interactive CouchDB Tutorial]]
  * [[#documents_without_a_field|Retrieving documents without a certain field]]
  * [[#geospatial_indexes|Using views to search for sort documents geographically]]

<<Anchor(common_mistakes)>>
== Common mistakes ==

When creating a reduce function, a re-reduce should behave in the same way as the regular reduce. The reason is that CouchDB doesn't necessarily call re-reduce on your map results.

Think about it this way: If you have a bunch of values V1 V2 V3 for key K, then you can get the combined result either by calling reduce([K,K,K],[V1,V2,V3],0) or by re-reducing the individual results: reduce(null,[R1,R2,R3],1). This depends on what your view results look like internally.

<<Anchor(get_doc_id)>>
== Get docs with a particular user id ==

{{{
map: function(doc) {
  if (doc.user_id) {
    emit(doc.user_id, null);
  }
}
}}}

Then query with key=USER_ID to get all the rows that match that user.

<<Anchor(get_doc_with_attachment)>>
== Get all documents which have an attachment ==

This lists only the documents which have an attachment.

{{{
map: function(doc) {
  if (doc._attachments) {
    emit(doc._id, null);
  }
}
}}}

In SQL this would be something like {{{SELECT id FROM table WHERE attachment IS NOT NULL}}}.

<<Anchor(count_doc_with_attachment)>>
== Count documents with and without an attachment ==

Call this with ''group=true'' or you only get the combined number of documents with and without attachments.

{{{
map: function(doc) {
  if (doc._attachments) {
    emit("with attachment", 1);
  }
  else {
    emit("without attachment", 1); 
  }
}
reduce: function(keys, values) {
   return sum(values);
}
}}}

Using curl you can call it like this:

{{{
curl -s -i -X POST -H 'Content-Type: application/json' 
  -d '{"map": "function(doc){if(doc._attachments) {emit(\"with\",1);} else {emit(\"without\",1);}}", 
  "reduce": "function(keys, values) {return sum(values);}"}' 
  'http://localhost:5984/somedb/_temp_view?group=true'
}}}

In SQL this would be something along the lines of {{{SELECT num_attachments FROM table GROUP BY num_attachments}}} (but this would give extra output for rows containing more than one attachment).

<<Anchor(list_unique_values)>>
== Generating a list of unique values ==

Here we use the fact that the key for a view result can be an array. Suppose you have a map that generates (key, value) pairs with many duplicates and you want to remove the duplicates. To do so, use ([key, value], null) as the map output.

Call this with ''group=true'' or you only get ''null''.

{{{
map: function(doc) {
  for (var i in doc.links)
    emit([doc.parent, i], null);
  }
}
reduce: function(keys, values) {
   return null;
}
}}}

This will give you results like
{{{
{"rows":[
{"key":["thisparent","thatlink"],"value":null},
{"key":["thisparent","thatotherlink"],"value":null}
]}
}}}

You can then get all the rows for the key ''"thisparent"'' with the view parameters ''startkey=[''''''"thisparent"]&endkey=["thisparent",{}]&inclusive_end=false''

Note that the trick here is using the key for what you want to make unique. You can combine this with the counting above to get a count of duplicate values:

{{{
map: function(doc) {
  for (var i in doc.links)
    emit([doc.parent, i], 1);
  }
}
reduce: function(keys, values) {
   return sum(values);
}
}}}

If you then want to know the total count for each parent, you can use the ''group_level'' view parameter:
''startkey=[''''''"thisparent"]&endkey=["thisparent",{}]&inclusive_end=false&group_level=1''

<<Anchor(top_n_tags)>>
== Retrieve the top N tags. ==

This snippet assumes your docs have a top level tags element that is an array of strings, theoretically it'd work with an array of anything, but it hasn't been tested as such.

Use a standard counting emit function:

{{{
function(doc)
{
    for(var idx in doc.tags)
    {
        emit(doc.tags[idx], 1);
    }
}
}}}

Notice that `MAX` is the number of tags to return. Technically this snippet relies on an implementation artifact that CouchDB will send keys in sorted order to the reduce functions, thus it'd break subtly if this stopped being true. Buyer beware!

{{{
function(keys, values, rereduce)
{
    var MAX = 3;

    /*
        Basically we're just kind of faking a priority queue. We
        do have one caveat in that we may process a single key
        across reduce calls. I'm reasonably certain that even so
        we'll still be processing keys in collation order in
        which case we can just keep the last key from the previous
        non-rereduce in our return value. Should work itself out
        in the rereduces though when we don't keep the extras
        around.
    */

    var tags = {};
    var lastkey = null;
    if(!rereduce)
    {
        /*
            I could probably alter the view output to produce
            a slightly different output so that this code
            could get pushed into the same code as below, but
            I figure that the view output might be used for
            other reduce functions.

            This just creates an object {tag1: N, tag2: M, ...}
        */
        
        for(var k in keys)
        {
            if(tags[keys[k][0]]) tags[keys[k][0]] += values[k];
            else tags[keys[k][0]] = values[k];
        }
        lastkey = keys[keys.length-1][0];
    }
    else
    {
        /*
            This just takes a collection of objects that have
            (tag, count) key/value pairs and merges into a
            single object.
        */
        tags = values[0];
        for(var v = 1; v < values.length; v++)
        {
            for(var t in values[v])
            {
                if(tags[t]) tags[t] += values[v][t];
                else tags[t] = values[v][t];
            }
        }
    }

    /*
        This code just removes the tags that are out of
        the top N tags. When re-reduce is false we may
        keep the last key passed to use because its
        possible that we only processed part of it's
        data.
    */
    var top = [];
    for(var t in tags){top[top.length] = [t, tags[t]];}
    function sort_tags(a, b) {return b[1] - a[1];}
    top.sort(sort_tags);
    for(var n = MAX; n < top.length; n++)
    {
        if(top[n][0] != lastkey) tags[top[n][0]] = undefined;
    }

    // And done.
    return tags;
}
}}}

There's probably a more efficient method to get the priority queue stuff, but I was going for simplicity over speed.

When querying this reduce you should not use the `group` or `group_level` query string parameters. The returned reduce value will be an object with the top `MAX` tag: count pairs.

<<Anchor(aggregate_sum)>>
== Joining an aggregate sum along with related data ==

Here is a modified example from the [[View_collation|View collation]] page.  Note that `group_level` needs to be set to `1` for it to return a meaningful `customer_details`.

{{{
// Map function
function(doc) {
  if (doc.Type == "customer") {
    emit([doc._id, 0], doc);
  } else if (doc.Type == "order") {
    emit([doc.customer_id, 1], doc);
  }
}

// Reduce function
// Only produces meaningful output.customer_details if group_level >= 1
function(keys, values, rereduce) {
  var output = {};
  if (rereduce) {
    for (idx in values) {
      if (values[idx].total !== undefined) {
        output.total += values[idx].total;
      } else if (values[idx].customer_details !== undefined) {
        output.customer_details = values[idx].customer_details;
      }
    }
  } else {
    for (idx in values) {
      if (values[idx].Type == "customer") output.customer_details = doc;
      else if (values[idx].Type == "order") output.total += 1;
    }
  }
  return output;
}
}}}


<<Anchor(standard_deviation)>>
== Computing the standard deviation ==
This example is from the couchdb test-suite. It is '''much''' easier and less complex then following example ([[#summary_stats|Computing simple summary statistics (min,max,mean,standard deviation)]]) although it does not calculate min,max and mean (but this should be an easy exercise).

{{{
// Map
function (doc) {
  emit(doc.val, doc.val)
};
}}}

{{{
// Reduce
function (keys, values, rereduce) {
    // This computes the standard deviation of the mapped results
    var stdDeviation=0.0;
    var count=0;
    var total=0.0;
    var sqrTotal=0.0;

    if (!rereduce) {
      // This is the reduce phase, we are reducing over emitted values from
      // the map functions.
      for(var i in values) {
        total = total + values[i];
        sqrTotal = sqrTotal + (values[i] * values[i]);
      }
      count = values.length;
    }
    else {
      // This is the rereduce phase, we are re-reducing previosuly
      // reduced values.
      for(var i in values) {
        count = count + values[i].count;
        total = total + values[i].total;
        sqrTotal = sqrTotal + values[i].sqrTotal;
      }
    }

    var variance =  (sqrTotal - ((total * total)/count)) / count;
    stdDeviation = Math.sqrt(variance);

    // the reduce result. It contains enough information to be rereduced
    // with other reduce results.
    return {"stdDeviation":stdDeviation,"count":count,
        "total":total,"sqrTotal":sqrTotal};
}; 
}}}


<<Anchor(summary_stats)>>
== Computing simple summary statistics (min,max,mean,standard deviation)  ==

This implementation of standard deviation is more complex than the above algorithm, called the "textbook one-pass algorithm" by Chan, Golub, and Le``Veque.  While it is mathematically equivalent to the standard two-pass computation of standard deviation, it can be numerically unstable under certain conditions.  Specifically, if the square of the sums and  the sum of the squares terms are large, then they will be computed with some rounding error.  If the variance of the data set is small, then subtracting those two large numbers (which have been rounded off slightly) might wipe out the computation of the variance.  See http://www.jstor.org/stable/2683386, http://people.xiph.org/~tterribe/notes/homs.html, and the wikipedia description of Knuth's algorithm http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance.

The below implementation in {{{JavaScript}}} by MarcaJames.  Any mistakes in the js coding are my fault.  The algorithms are from others (all smarter than I), as noted in the comments in the code.  To the best of my knowledge the algorithms are public domain, and my implementation freely available to all.  

Note that the view is specialized to my dataset, but the reduce function is written to be fairly generic.  I kept the view as is because I'm too lazy to write up a generic view, and also because when I wrote it I wasn't sure one could use Date, Math, and Reg``Exp in Couch``DB Java``Script.  

{{{
// Map function
function(doc) {
    var risk_exponent = 
	-3.194 +
	doc.CV_VOLOCC_1                 *1.080 +
	doc.CV_VOLOCC_M                 *0.627 +
	doc.CV_VOLOCC_R                 *0.553 +
	doc.CORR_VOLOCC_1M              *1.439 +
	doc.CORR_VOLOCC_MR              *0.658 +
	doc.LAG1_OCC_M                  *0.412 +
	doc.LAG1_OCC_R                  *1.424 +
	doc.MU_VOL_1                    *0.038 +
	doc.MU_VOL_M                    *0.100 +
	doc["CORR_OCC_1M X MU_VOL_M"]      *-0.168 +
	doc["CORR_OCC_1M X SD_VOL_R" ]     *0.479 +
	doc["CORR_OCC_1M X LAG1_OCC_R"]    *-1.462 ;
    
    var risk = Math.exp(risk_exponent);
    
    // parse the date and "chunk" it up
    var pattern = new RegExp("(.*)-0?(.*)-0?(.*)T0?(.*):0?(.*):0?(.*)(-0800)");
    var result = pattern.exec(doc.EstimateTime);
    var day;
    if(result){
        //new Date(year, month, day, hours, minutes, seconds, ms)
        // force rounding to 5 minutes, 0 seconds, for aggregation of 5 minute chunks
        var fivemin = 5 * Math.floor(result[5]/5)
        day = new Date(result[1],result[2]-1,result[3],result[4], fivemin, 0);
    }
    var weekdays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    emit([weekdays[day.getDay()],day.toLocaleTimeString( )],{'risk':risk});
}

// Reduce function
function (keys, values, rereduce) {

    // algorithm for on-line computation of moments from 
    // 
    //    Tony F. Chan, Gene H. Golub, and Randall J. LeVeque: "Updating
    //    Formulae and a Pairwise Algorithm for Computing Sample
    //    Variances." Technical Report STAN-CS-79-773, Department of
    //    Computer Science, Stanford University, November 1979.  url:
    //    ftp://reports.stanford.edu/pub/cstr/reports/cs/tr/79/773/CS-TR-79-773.pdf
    
    // so there is some weirdness in that the original was Fortran, index from 1,
    // and lots of arrays (no lists, no hash tables)
    

    // also consulted http://people.xiph.org/~tterribe/notes/homs.html
    // and http://www.jstor.org/stable/2683386
    // and (ick!) the wikipedia description of Knuth's algorithm
    // to clarify what was going on with http://www.slamb.org/svn/repos/trunk/projects/common/src/java/org/slamb/common/stats/Sample.java

    /* 
       combine the variance esitmates for two partitions, A and B.
       partitionA and partitionB both should contain
        { S :  the current estimate of the second moment
          Sum : the sum of observed values
          M : the number of observations used in the partition to calculate S and Sum
        }

    The output will be an identical object, containing the S, Sum and
    M for the combination of partitions A and B
       
    This routine is derived from original fortran code in Chan et al,
    (1979)

    But it is easily derived by recognizing that all you're doing is
    multiplying each partition's S and Sum by its respective count M,
    and then dividing by the new count Ma + Mb.  The arrangement of
    the diff etc is just rearranging terms to make it look nice.

    And then summing up the sums, and summing up the counts

    */
    function combine_S(partitionA,partitionB){
	var NewS=partitionA.S;
	var NewSum=partitionA.Sum;
	var min = partitionA.min;
	var max = partitionA.max;
	var M = partitionB.M;
	if(!M){M=0;}
	if(M){
	    var diff = 
		((partitionA.M * partitionB.Sum / partitionB.M) - partitionA.Sum );
	    
	    NewS += partitionB.S + partitionB.M*diff*diff/(partitionA.M * (partitionA.M+partitionB.M) );
	    NewSum += partitionB.Sum ;

	    min = Math.min(partitionB.min, min);
	    max = Math.max(partitionB.max, max);
	}
	return {'S':NewS,'Sum':NewSum, 'M': partitionA.M+M, 'min':min, 'max':max };
    }
	    

    /*

    This routine is derived from original fortran code in Chan et al,
    (1979), with the combination step split out above to allow that to
    be called independently in the rereduce step.

    Arguments:  

    The first argument (values) is an array of objects.  The
    assumption is that the key to the variable of interest is 'risk'.
    If this is not the case, the seventh argument should be the correct
    key to use.  More complicated data structures are not supported.

    The second, third, and fourth arguments are in case this is a
    running tally.  You can pass in exiting values for M (the number
    of observations already processed), Sum (the running sum of those
    M observations) and S (the current estimate of variance for those
    M observations).  Totally optional, defaulting to zero.  

    The fifth parameter is for the running min, and the sixth for the
    max.

    Pass "null"  for parameters 2 through 6 if you need to pass a key in the
    seventh slot.

    Some notes on the algorithm.  There is a precious bit of trickery
    with stack pointers, etc that make for a minimal amount of
    temporary storage.  All this was included in the original
    algorithm.  I can't see that it makes much sense to include all
    that effort given that I've got gobs of RAM and am instead most
    likely processor bound, but it reminded me of programming in
    assembly so I kept it in.  

    If you watch the progress of this algorithm in a debugger or
    firebug, you'll see that the size of the stack stays pretty small,
    with the bottom (0) entry staying at zero, then the [1] entry
    containing a power of two (2,4,8,16, etc), and the [2] entry
    containing the next power of two down from [1] and so on.  As the
    slots of the stack get filled up, they get cascaded together by
    the inner loop.

    You could skip all that, and just pairwise process repeatedly
    until the list of intermediate values is empty, but whatever.  And
    there seems to be some super small gain in efficiency in using
    identical support for two groups being combined, in that you don't
    have to consider different Ma and Mb in the computation.  One less
    divide I guess)

    */
    function pairwise_update (values, M, Sum, S, min, max, key){
	if(!key){key='risk';}
	if(!Sum){Sum = 0; S = 0; M=0;}
	if(!S){Sum = 0; S = 0; M=0;}
	if(!M){Sum = 0; S = 0; M=0;}
	if(!min){ min = Infinity; }
	if(!max){ max = -Infinity; }
	var T;
	var stack_ptr=1;
	var N = values.length;
	var half = Math.floor(N/2);
	var NewSum;
	var NewS ;
	var SumA=[];
	var SA=[];
	var Terms=[];
	Terms[0]=0;
	if(N == 1){
	    Nsum=values[0][key];
	    Ns=0;
	}else if(N > 1){
	    // loop over the data pairwise
	    for(var i = 0; i < half; i++){
		// check min max
		if(values[2*i+1][key] < values[2*i][key] ){
		    min = Math.min(values[2*i+1][key], min);
		    max = Math.max(values[2*i][key], max);
		}else{
		    min = Math.min(values[2*i][key], min);
		    max = Math.max(values[2*i+1][key], max);
		}
		SumA[stack_ptr]=values[2*i+1][key] + values[2*i][key];
		var diff = values[2*i + 1][key] - values[2*i][key] ;
		SA[stack_ptr]=( diff * diff ) / 2;
		Terms[stack_ptr]=2;
		while( Terms[stack_ptr] == Terms[stack_ptr-1]){
		    // combine the top two elements in storage, as
		    // they have equal numbers of support terms.  this
		    // should happen for powers of two (2, 4, 8, etc).
		    // Everything else gets cleaned up below
		    stack_ptr--;
		    Terms[stack_ptr]*=2;
		    // compare this diff with the below diff.  Here
		    // there is no multiplication and division of the
		    // first sum (SumA[stack_ptr]) because it is the
		    // same size as the other.
		    var diff = SumA[stack_ptr] - SumA[stack_ptr+1];
		    SA[stack_ptr]=  SA[stack_ptr] + SA[stack_ptr+1] +
			(diff * diff)/Terms[stack_ptr];
		    SumA[stack_ptr] += SumA[stack_ptr+1];
		} // repeat as needed
		stack_ptr++;
	    }
	    stack_ptr--;
	    // check if N is odd
	    if(N % 2 !=  0){
		// handle that dangling entry
		stack_ptr++;
		Terms[stack_ptr]=1;
		SumA[stack_ptr]=values[N-1][key];
		SA[stack_ptr]=0;  // the variance of a single observation is zero!
		min = Math.min(values[N-1][key], min);
		max = Math.max(values[N-1][key], max);
	    }
	    T=Terms[stack_ptr];
	    NewSum=SumA[stack_ptr];
	    NewS= SA[stack_ptr];
	    if(stack_ptr > 1){
		// values.length is not power of two, so not
		// everything has been scooped up in the inner loop
		// above.  Here handle the remainders
		for(var i = stack_ptr-1; i>=1 ; i--){
		    // compare this diff with the above diff---one
		    // more multiply and divide on the current sum,
		    // because the size of the sets (SumA[i] and NewSum)
		    // are different.
		    var diff = Terms[i]*NewSum/T-SumA[i]; 
		    NewS = NewS + SA[i] + 
			( T * diff * diff )/
			(Terms[i] * (Terms[i] + T));
		    NewSum += SumA[i];
		    T += Terms[i];
		}
	    }
	}
	// finally, combine NewS and NewSum with S and Sum
	return 	combine_S(
	    {'S':NewS,'Sum':NewSum, 'M': T ,  'min':min, 'max':max},
	    {'S':S,'Sum':Sum, 'M': M ,  'min':min, 'max':max});
    }


    /*

    This function is attributed to Knuth, the Art of Computer
    Programming.  Donald Knuth is a math god, so I am sure that it is
    numerically stable, but I haven't read the source so who knows.

    The first parameter is again values, a list of objects with the expectation that the variable of interest is contained under the key 'risk'.  If this is not the case, pass the correct variable in the 7th field.
    
    Parameters 2 through 6 are all optional.  Pass nulls if you need to pass a key in slot 7.

    In order they are 

    mean:  the current mean value estimate 
    M2: the current estimate of the second moment (variance)
    n:  the count of observations used in the current estimate
    min:   the current min value observed
    max:   the current max value observed

    */
    function KnuthianOnLineVariance(values, M2, n, mean, min, max,  key){
	if(!M2){ M2 = 0; }
	if(!n){ n = 0; }
	if(!mean){ mean  = 0; }
	if(!min){ min = Infinity; }
	if(!max){ max = -Infinity; }
	if(!key){ key = 'risk'; }

	// this algorithm is apparently a special case of the above
	// pairwise algorithm, in which you just apply one more value
	// to the running total.  I don't know why bun Chan et al
	// (1979) and again in their later paper claim that using M
	// greater than 1 is always better than not.

	// but this code is certainly cleaner!  code based on Scott
	// Lamb's Java found at
	// http://www.slamb.org/svn/repos/trunk/projects/common/src/java/org/slamb/common/stats/Sample.java
	// but modified a bit

	for(var i=0; i<values.length; i++ ){
	    var diff = (values[i][key] - mean);
            var newmean = mean +  diff / (n+i+1);
            M2 += diff * (values[i][key] - newmean);
            mean = newmean;
            min = Math.min(values[i][key], min);
            max = Math.max(values[i][key], max);
        }
	return {'M2': M2, 'n': n + values.length, 'mean': mean, 'min':min, 'max':max };
    }

    function KnuthCombine(partitionA,partitionB){
	if(partitionB.n){
	    var newn = partitionA.n + partitionB.n;
            var diff = partitionB.mean - partitionA.mean;
            var newmean = partitionA.mean + diff*(partitionB.n/newn)
            var M2 = partitionA.M2 + partitionB.M2 + (diff * diff * partitionA.n * partitionB.n / newn );
            min = Math.min(partitionB.min, partitionA.min);
            max = Math.max(partitionB.max, partitionA.max);
	    return {'M2': M2, 'n': newn, 'mean': newmean, 'min':min, 'max':max };
        } else {
            return partitionA;
        }
    }

    var output={};
    var knuthOutput={};

    // two cases in the application of reduce.  In the first reduce
    // case the rereduce flag is false, and we have raw values.  We
    // also have keys, but that isn't applicable here.
    // 
    // In the rereduce case, rereduce is true, and we are being passed
    // output for identical keys that needs to be combined further.

    if(!rereduce)
    {
	output = pairwise_update(values);
	output.variance_n=output.S/output.M;
	output.mean = output.Sum/output.M;
	knuthOutput = KnuthianOnLineVariance(values);
	knuthOutput.variance_n=knuthOutput.M2/knuthOutput.n;
	output.knuthOutput=knuthOutput;

    } else {
	/*
           we have an existing pass, so should have multiple outputs to combine  
        */
	for(var v in values){
	    output = combine_S(values[v],output);
	    knuthOutput = KnuthCombine(values[v].knuthOutput, knuthOutput);
	}
	output.variance_n=output.S/output.M;
	output.mean = output.Sum/output.M;
	knuthOutput.variance_n=knuthOutput.M2/knuthOutput.n;
	output.knuthOutput=knuthOutput;
    }
    // and done
    return output;
}

}}}

Sample output.  Note the difference in the very last few decimal places between the two methods.  

||`["Tue", "08:00:00"] `|| ` {"S": 1276.8988123975391, "Sum": 1257.4497350063903, "M": 955, "min": 0.033031734767263086, "max": 6.011336961717487,`  `"variance_n": 1.3370668192644388, "mean": 1.3167012932004087,`  `"knuthOutput": {"M2": 1276.898812397539, "n": 955, "mean": 1.3167012932004083, "min": 0.033031734767263086, "max": 6.011336961717487,` `"variance_n": 1.3370668192644386}} `||
||`["Tue", "08:05:00"]`||` {"S": 1363.1444727834003, "Sum": 1303.08214106713, "M": 939, "min": 0.03216066554751794, "max": 5.93544645899576,`  `"variance_n": 1.4516980540824285, "mean": 1.387733909549659,`  `"knuthOutput": {"M2": 1363.1444727834005, "n": 939, "mean": 1.3877339095496595, "min": 0.03216066554751794, "max": 5.93544645899576,` `"variance_n": 1.4516980540824287}} `||

<<Anchor(interactive_couchdb)>>
== Interactive CouchDB Tutorial ==
See [[http://labs.mudynamics.com/2009/04/03/interactive-couchdb/|this blog post]], which is a CouchDB emulator (in JavaScript) that explains the basics of map/reduce, view collation and querying CouchDB RESTfully.

<<Anchor(documents_without_a_field)>>
== Retrieving documents without a certain field ==
Sometimes you might need to get a list of documents that '''don't''' have a certain field. You can do this quite easy by emitting keys that fit the "undefined" condition:

{{{
map
function(doc)
{
  if (doc.field === void 0)
  {
    emit(doc.id, null);
  }
}
}}}

However, if you have more than just a few fields that need to be tested for abcense you can use another approach instead of creating a view for each negation:

{{{
function (doc)
{
  // List of fields to test for abcense in documents, fields specified here will be emitted as key
  var fields = new Array("type", "role", "etc");

  // Loop through our fields
  for (idx in fields)
  {
    // Does the current field exists?
    if (typeof eval("doc." + fields[idx]) === void 0)
    {
      // It doesn't, emit the field name as key
      emit(fields[idx], null);
    }
  }
}
}}}

For example: you can now query your view and retrieve all documents that do not contain the field `role` (view/NAME/?key="role").

<<Anchor(geospatial_indexes)>>
== Using views to search for sort documents geographically ==

If you use latitude/longitude information in your documents, it's not very easy to sort on proximity from a given point using the normal approach (of using a key of [<latitude>, <longitude>]). This happens because they're on different axes, which doesn't map well onto CouchDB's treatment of the index sorting -- which is a linear sort. However, using a [[http://en.wikipedia.org/wiki/Geohash|geohash]] may solve this, by letting you convert the coordinates of a location into a string that sorts well (e.g., locations that are close share a common prefix).

(Note that I haven't actually used this approach, but this came up in IRC and geohashes are conceptually a good match. Please reword/refactor this entry if I've stated the problem or solution poorly.)
