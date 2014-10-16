/* {HEAD}

{LOOPS!} */

{USE} 
/* 
{view `"{LOOPS-}##introduction"':1. Introduction}{BR}
{view `"{LOOPS-}##tracing"':2. Tracing}{BR}
{view `"{LOOPS-}##macros"':3. More on Macros}{BR}
{view `"{LOOPS-}##loops"':4. More Loops}

{hline}{marker introduction}

{bf:1. Introduction}

{hline}

Let's do a quick review of for-loops and macros. Here is an example of a for-loop: 

{TRYITCMD}
foreach i of numlist 1/10 {{BR}
	display "Hello world!"{BR}
}
{DEF}

This repeats the commands enclosed by the braces ({cmd}{ }{txt})
(here, just {cmd:display "Hello world!"})
{cmd:10} times. It's preferable to typing the command 10 times: */

display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"
display "Hello world!"

/* The for-loop was less code and more efficient,
and it's easier to update:
if I want to switch {cmd:"Hello world!"} to something else
or make a larger change,
I have to do it just once within the loop instead of 10 times.
The loop is also less error-prone,
because repetitively typing out the same thing can lead to mistakes.
Indeed, there are 11 {cmd:display}s above when I meant 10.

{marker style}A quick detour into style.
Notice that after the left brace ({cmd}{{txt}), I indented once.
The code stayed indented until the right brace ({cmd}}{txt}).
This formatting makes the code more readable;
it's easy to tell what's in the loop and what's not.

{TECH}
{COL}For more tips on Stata programming style, see these resources:{CEND}
{BLANK}
{COL}{browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0018":{it:Suggestions on Stata programming style}}{CEND}
{BLANK}
{COL}{browse "http://faculty.chicagobooth.edu/matthew.gentzkow/research/ra_manual_coding.pdf":{it:RA Manual: Notes on Writing Code}}{CEND}
{BOTTOM}

For-loops and macros are distinct but related concepts.
Every for-loop is associated with its own macro, but not every macro is associated with a for-loop.
The loop above was associated with a local macro ({cmd:`i'}),
though the macro wasn't used inside the loop.
Let's look at an example of {helpb foreach:foreach}
that incorporates its macro within the loop:

{TRYITCMD}
foreach var in sex age educ {
	display "Checking `var' for missing values..."
	list hhid `var' if `var' == .
}
{DEF}

This {cmd:foreach} command loops over the variables {cmd:sex}, {cmd:age}, and {cmd:educ}.
In this dataset, these variables should never have missing values.
For each variable, the loop first displays the variable name as part of a message
({cmd:"Checking `var' for missing values..."}).
It then lists all values of {cmd:hhid} for which the variable is missing.
Knowing these, we can then examine the problematic observations more closely.

This {cmd:foreach} repeatedly sets the local macro {cmd:`var'} to each element in
the list that follows {cmd:in}, executing the commands in the loop for each value of {cmd:`var'}.
{cmd:var} is a name I made up, and I could have chosen something else.

{marker whats_in_a_name}{...}
{TECH}
{COL}{bf:What's in a name?}{CEND}
{MLINE}
{COL}The same rules generally apply to all Stata names, whether it's of a{CEND}
{COL}variable, macro, or something else. From {helpb varname:help varname}:{CEND}
{BLANK}
{COL}"Variable names may be 1 to 32 characters long and must start with {cmd:a-z}, {cmd:A-Z},{CEND}
{COL}or {cmd:_}, and the remaining characters may be {cmd:a-z}, {cmd:A-Z}, {cmd:_}, or {cmd:0-9}."{CEND}
{BLANK}
{COL}The exception to this rule is local macros, which may be 1 to 31 characters{CEND}
{COL}long (a character shorter), but may start with {cmd:0-9}. Global macros (which{CEND}
{COL}we will discuss later) follow the same naming conventions as variables.{CEND}
{BOTTOM}

The first element in the list is {cmd:"sex"}.
Thus, the local macro {cmd:`var'} is first set to {cmd:"sex"}.
The commands in the loop are then executed:

{CMD}
display "Checking {ul:`var'} for missing values..."{BR}
list hhid {ul:`var'} if {ul:`var'} == .
{DEF}

The value of {cmd:`var'} is immediately substituted for {cmd:`var'} in the commands,
so this is the same as:

{CMD}
display "Checking {ul:sex} for missing values..."{BR}
list hhid {ul:sex} if {ul:sex} == .
{DEF}

After {cmd:list},
all the commands in the for-loop have been executed,
so {cmd:`var'} is set to the next element in the list: {cmd:"age"} and then finally {cmd:"educ".}

Don't think of {cmd:display} as searching for and then accessing the contents of the local macro {cmd:`var'}.
Instead, the value of {cmd:`var'} is essentially "copied and pasted" into the command before it is executed.
Stata completes the substitution, replacing {cmd:`var'} with its value,
and {it:then} {cmd:display} is executed.
{cmd:display} has no idea that a local macro was used,
because the substitution was done before the command was executed.

In Stata, "macros" are objects that can be substituted into commands in this way.
They are not variables;
that term is used in reference to the variables in the dataset,
which have as many values as there are observations.

Some additional terminology: {help quotes:"double quotes"} ({cmd:""}) are used to enclose strings.
For example, {cmd:"abc"}, {cmd:"123"}, and {cmd:"Hello world"} are each a single string enclosed by double quotes.
"Single quotes" ({cmd:`} and {cmd:'}) is the term for the characters used to enclose locals,
such as {cmd:`var'}.

{hline}{marker tracing}

{bf:2. Tracing}

{hline}

Loops can be confusing, and they're also difficult to debug,
because for a loop that results in an error,
Stata doesn't clearly indicate which command in the loop is causing the problem.
For example, here's the loop from above,
but with a bug introduced: */

foreach var in sex age educ {
	display "Checking `var' for missing values..."
	list hhid `var' if `var == .
}

/* To get around this, you can turn on {help trace:tracing}:

{TRYITCMD}
set trace on
{DEF}

This gives details about the commands Stata is executing: */

foreach var in sex age educ {
	display "Checking `var' for missing values..."
	list hhid `var' if `var == .
}

/* Once you've identified the problem:

{TRYITCMD}
set trace off
{DEF}

Notice the behavior of {cmd:set trace on} with macros: */

set trace on

foreach var in sex age educ {
	display "Checking `var' for missing values..."
	list hhid `var' if `var' == .
}

set trace off

/* {cmd:set trace on} first shows the commands as they were originally typed,
before the values of macros are substituted.
It then shows the commands
after the macros have been "expanded."
Here, we see:

- foreach var in sex age educ {{BR}
- display "Checking `var' for missing values..."{BR}
= display "Checking sex for missing values..."{BR}
Checking sex for missing values...{BR}
- list hhid `var' if `var' == .{BR}
= list hhid sex if sex == .{BR}
- }

First, we see the command as it was first typed:

- display "Checking `var' for missing values..."

Then the command after the macro expansion:

= display "Checking sex for missing values..."{BR}

Then the result:

Checking sex for missing values...

{hline}{marker macros}

{bf:3. More on Macros}

{hline}

A few more points about macros.

Local macros don't exist after the do-file ends.
For example, copy these commands to a new do-file, then run it:

{CMD}
local x Hello world{BR}
display "`x'"
{DEF}

Now try the following command: */

display "`x'"

/* It doesn't work, because the local doesn't exist now that the do-file is done.

We will now briefly discuss global macros.
Basically, they're like local macros
except they stick around even after the do-file ends,
so they can be used in the Command window afterwards
or by other do-files.
Rather than being enclosed by ` and ', they
start with {cmd:$}.
Copy these commands to a new do-file, then run it:

{CMD}
global x Hello world{BR}
display "$x"
{DEF}

Now try the following command: */

display "$x"

/* It works!

{TECH}
{COL}I defined {cmd:`x'} as follows:{CEND}
{BLANK}
{COL}{cmd:local x Hello world}{CEND}
{BLANK}
{COL}But I also could have coded:{CEND}
{BLANK}
{COL}{cmd:local x "Hello world"}{CEND}
{BLANK}
{COL}Here, I enclosed the value of {cmd:`x'} with double quotes. Usually, these quotes{CEND}
{COL}are not required. For example, they were not needed here. However, they are{CEND}
{COL}always allowed. The only times they are necessary are when the value of the{CEND}
{COL}macro begins with double quotes or a macro operator, such as {cmd:=}, or when it{CEND}
{COL}contains leading leading or trailing spaces. Let's look at an example where{CEND}
{COL}the quotes are necessary.{CEND}
{BLANK}
{CMD}
{COL}foreach x in "Hello world" "a" "b" "c" {c -(}{CEND}
{COL}	display "`x'"{CEND}
{COL}{c )-}{CEND}
{DEF}
{BLANK}
{COL}{stata `"run "Do/Text boxes.do" "for-loops and macros" 1"':Click here to execute.}{CEND}
{BLANK}
{COL}The loop above {cmd:display}ed the four string values that followed {cmd:foreach in}.{CEND}
{COL}Let's examine a variation on this loop:{CEND}
{BLANK}
{CMD}
{COL}local list ""Hello world" "a" "b" "c""{CEND}
{COL}foreach x in `list' {c -(}{CEND}
{COL}	display "`x'"{CEND}
{COL}{c )-}{CEND}
{DEF}
{BLANK}
{COL}{stata `"run "Do/Text boxes.do" "for-loops and macros" 2"':Click here to execute.}{CEND}
{BLANK}
{COL}We see the same output. In the definition of {cmd:`list'}, we used enclosing{CEND}
{COL}double quotes. Here is what would have happened if we hadn't:{CEND}
{BLANK}
{CMD}
{COL}local list "Hello world" "a" "b" "c"{CEND}
{COL}foreach x in `list' {c -(}{CEND}
{COL}	display "`x'"{CEND}
{COL}{c )-}{CEND}
{DEF}
{BLANK}
{COL}{stata `"run "Do/Text boxes.do" "for-loops and macros" 3"':Click here to execute.}{CEND}
{BLANK}
{COL}Do you notice the difference in output? {cmd:macro list}, which shows the values{CEND}
{COL}of macros, is one way to see it. Here, {cmd:`list1'} is the list with the extra{CEND}
{COL}set of double quotes, and {cmd:`list2'} is the list without it:{CEND}
{BLANK}
{COL}{bf:{stata local list1 ""Hello world" "1" "2" "3" "a" "b" "c""}}{CEND}
{COL}{bf:{stata local list2 "Hello world" "1" "2" "3" "a" "b" "c"}}{CEND}
{COL}{bf:{stata macro list _list1 _list2}}{CEND}
{BLANK}
{COL}If {cmd:`list'} is defined without the extra set of double quotes, its own first{CEND}
{COL}and last quotes are removed. This is one of the few situations in which{CEND}
{COL}enclosing double quotes are required. This is because {cmd:`list'} began with a{CEND}
{COL}double quote. However, while not always required, the extra double quotes{CEND}
{COL}are always allowed.{CEND}
{BOTTOM}

There are more advanced ways to use macros. For example:

{TRYITCMD}
local num = 1 * 2 + 3{BR}
display "`num'"
{DEF}

{cmd:local num = 1 * 2 + 3} first evaluates {cmd:1 * 2 + 3},
then stores the result in the local {cmd:`num'}.
Notice the {cmd:=} operator.

Compare this with:

{TRYITCMD}
local num 1 * 2 + 3{BR}
display "`num'"
{DEF}

There's no {cmd:=} operator before the expression, so Stata doesn't evaluate it,
and just stores the string as-is in the local {cmd:`num'}.

{marker counting}{...}
A common use of this feature is counting:

{TRYITCMD}
local i 0{BR}
foreach var of varlist _all {{BR}
	local i = `i' + 1{BR}
}
{DEF} */

display "The dataset has `i' variables."

/* {...}
{TECH}
{COL}{bf:More on macros}{CEND}
{MLINE}
{COL}If you've never read a {help manuals:Stata manual}, and would never intend to otherwise,{CEND}
{COL}you should still read {manlink U 18.3 Macros} in the Stata User's Guide. Especially{CEND}
{COL}if you are an office PA/RA, this section is a must-read about one of the{CEND}
{COL}most important and powerful tools in Stata: macros.{CEND}
{BLANK}
{COL}Afterwards, read more about {help extended_fcn:extended macro functions} and {help macro lists},{CEND}
{COL}advanced macro features.{CEND}
{BOTTOM}

{hline}{marker loops}

{bf:4. More on Loops}

{hline}

{cmd:foreach} isn't the only loop or even the only for-loop in
Stata. If you're not already familiar with the very useful variants on {cmd:foreach in},
{cmd:foreach of varlist} and {cmd:foreach of numlist}, check out {bf:Stata 102} for examples. 
{helpb forvalues} loops over certain {it:numlists}, and especially abbreviated as
{cmd:forv} or {cmd:forval}, is easier to type than {cmd:foreach of numlist}. The {helpb while} loop, 
is a more advanced, but useful loop that we'll look at below: 

Instead of designating text/variables/numbers to substitute within the loop, 
{cmd:while} simply sets a condition that must be met for the loop to run. 
You are essentially telling Stata that if X is true, it needs to do Y. 
The syntax is very simple, as follows: 

{CMD}
while x = true {
	do Y
}
{DEF}

Try this loop (with a local thrown in for good measure) if you feel comfortable with loops so far.
If you are already confused, it might be best to come back to it later � it�s a bit more advanced. */  

local i = 1
while  `i' < 15 {
	display "Round `i'"
	local i = `i' + 1
}

/* At the beginning of the loop, `i� was set to 1.
For the first loop, the {cmd:while} command reads: if 1 < 15, 
Stata would display �Round 1�, and then reset `i� to 2 (one more than it was before). 
Since the condition was in fact met, (1 is less than 15), Stata then cycled through the loop 14 times,
making `i� first 2, then 3, etc, until `i� hit 15.
Then, once the condition imposed on the {cmd:while} loop was no longer true 
(15 is not less than 15), Stata stopped performing the operation and the loop was ended. 

{FOOT}

{GOTOPS}{LOOPS_PS}

{NEXT}{IF}
{PREV}{SUBSCRIPTING}
{START} */
