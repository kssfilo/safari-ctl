#!/usr/bin/env coffee
GetOpt=require '@kssfilo/getopt'
OsaScript=require 'node-osascript'

AppName="@PARTPIPE@BINNAME@PARTPIPE@"
PackageName="@PARTPIPE@NAME@PARTPIPE@"

P=console.log
E=(e)=>
	switch
		when typeof(e) in ['string','value']
			console.error e
		when ctx.isDebugMode
			console.error e
		else
			if e[0]?.message
				console.error e[0].message
			else
				console.error e.toString()

D=(str)=>
	E "#{AppName}:"+str if ctx.isDebugMode


ctx={
	command:'print'
	isDebugMode:false
	isRecipeJsDebugMode:false
	url:null
	doActivate:false
	javaScript:null
	query:null
	text:null
	dropResult:false
}

optUsages=
	h:"show this help"
	d:"debug mode"
	p:"print current Safari's URL(default)"
	t:"print current Safari's title"
	g:"print selected string on current Safari's tab"
	c:"copy current Safari's URL into the clipboard"
	s:["URL","set <URL> to Safari's active tab"]
	S:["URL","same as -s but set focus to Safari"]
	q:["query","search <query> to Safari's active tab"]
	Q:["URL","same as -q but set focus to Safari"]
	m:"marks all <a> link with number to click by next -a command(*)"
	a:["number","click <number> link. you can know link number by -m command(*)"]
	M:"marks all <input> with number to click/set by next -A command(*)"
	A:["number","click <number> input. you can know input number by -M command(*)"]
	I:["string","works with -A, Input <string> instead of click. for filling form(*)"]
	b:"history back(*)"
	f:"history forward(*)"
	n:"scroll to next page(*)"
	N:"scroll to previous page (*)"
	j:["javascript","run <javascript> on active tab(*)"]
	J:["javascript","same as s but set focus to Safari(*)"]

try
	GetOpt.setopt 'h?dptgcs:S:q:Q:ma:MA:I:bfnNj:J:'
catch e
	switch e.type
		when 'unknown'
			E "Unknown option:#{e.opt}"
		when 'required'
			E "Required parameter for option:#{e.opt}"
	process.exit(1)

try
	GetOpt.getopt (o,p)->
		switch o
			when 'h','?'
				ctx.command='usage'
				ctx.restCommand=p[0] if p[0] isnt ''
			when 'd'
				ctx.isDebugMode=true
			when 'c'
				ctx.command='copy'
			when 'p'
				ctx.command='print'
			when 's'
				ctx.command='set'
				ctx.url=p[0]
			when 'S'
				ctx.command='set'
				ctx.url=p[0]
				ctx.doActivate=true
			when 't'
				ctx.command='printTitle'
			when 'j'
				ctx.command='javaScript'
				ctx.javaScript=p[0]
			when 'J'
				ctx.command='javaScript'
				ctx.javaScript=p[0]
				ctx.doActivate=true
			when 'g'
				ctx.command='javaScript'
				ctx.javaScript="document.getSelection().toString()"
			when 'q'
				ctx.command='search'
				ctx.query=p[0]
			when 'Q'
				ctx.command='search'
				ctx.query=p[0]
				ctx.doActivate=true
			when 'm'
				ctx.command='javaScript'
				ctx.javaScript='var $OSA$=document.getElementsByTagName("a");for(var i=0;i<$OSA$.length;i++){v=$OSA$[i];v.innerHTML="<span style=background-color:yellow>"+i+"</span>:"+v.innerHTML;}'
			when 'M'
				ctx.command='javaScript'
				ctx.javaScript='var $OSA$=document.getElementsByTagName("input");for(var i=0;i<$OSA$.length;i++){v=$OSA$[i];var e=document.createElement("span");e.style="background-color:lightgreen";e.innerText=i;v.before(e);}'
			when 'a'
				ctx.command='javaScript'
				index=Number(p[0])
				ctx.javaScript="var $OSA$=document.getElementsByTagName('a');$OSA$[#{index}].click()"
				ctx.dropResult=true
			when 'A'
				ctx.command='javaScript'
				index=Number(p[0])
				ctx.javaScript="var $OSA$=document.getElementsByTagName('input');$OSA$[#{index}].click()"
				ctx.dropResult=true
			when 'I'
				ctx.text=p[0]
				ctx.dropResult=true
			when 'b'
				ctx.command='javaScript'
				ctx.javaScript="history.back()"
			when 'f'
				ctx.command='javaScript'
				ctx.javaScript="history.forward()"
			when 'n'
				ctx.command='javaScript'
				ctx.javaScript="window.scrollBy({top:window.innerHeight,left:0,behavior:'smooth'})"
				ctx.dropResult=true
			when 'N'
				ctx.command='javaScript'
				ctx.javaScript="window.scrollBy({top:-window.innerHeight,left:0,behavior:'smooth'})"
				ctx.dropResult=true

	if ctx.command is 'usage'
		P """
		## Command line
		
			#{AppName} [options]
			
			@PARTPIPE@DESCRIPTION@PARTPIPE@
			
			Copyright (C) 2019-@PARTPIPE@|date +%Y;@PARTPIPE@ @kssfilo(https://kanasys.com/gtech/)

		## Prepare
		
		(*)You must enable the 'Allow JavaScript from Apple Events' option in Safari's Develop menu to use some features.

		## Options

		#{GetOpt.getHelp optUsages}		

		## Examples
		
		### Get current URL on Safari

		    $ #{AppName}
		    https://github.com

		### Copy current URL on Safari to the clipboard
		
		    $ #{AppName} -s

		### Open specified URL on Safari
		
		    $ #{AppName} -s 'http://github.com'
		    # withoug focus

		    $ #{AppName} -S 'github.com'
		    # with focus(omiting scheme->appends https://)

		### Gets window title

		    $ #{AppName} -t

		### Navigating by command line
		
		    $ #{AppName} -m
		    # marks all <a> with numbers
		
		    $ #{AppName} -a 32
		    # click 32'th <a>

		    $ #{AppName} -b
		    # history back
		
		    $ #{AppName} -M
		    # marks all <input> with numbers
		
		    $ #{AppName} -A 0 -I 'Japan'
		    # Fill 0th input with 'Japan'

		    $ #{AppName} -A 1
		    # click 1st input button
		
		### Searchs Bing with word "Japan" (JavaScript injection)

		    $  #{AppName} -s 'https://bing.com'
		    $  #{AppName} -j 'document.getElementById("sb_form_q").value="Japan";document.getElementById("sb_form_go").click()'

		### Print string in Bing search form
		
		    $  #{AppName} -j 'document.getElementById("sb_form_q").value'
		    Japan
		"""

		process.exit 0

	D "==starting #{AppName}"

	if ctx.javaScript
		ctx.javaScript=ctx.javaScript.replace(/"/g,'\\"')

	if ctx.url && !ctx.url.match(/^https?:\/\//)
		ctx.url="https://"+ctx.url

	D "sanity checking.."
	throw "-I works with -A" if ctx.text and !ctx.javaScript
	if ctx.text and ctx.javaScript
		D "CHECK"
		ctx.javaScript=ctx.javaScript.replace(/click\(\)$/,"value='#{ctx.text}'")
	D "..OK"
	D "-------"
	D "-options"
	D "#{JSON.stringify ctx,null,2}"

	if ctx.isCheckCommand or ctx.isDebugMode
		E "command:#{ctx.restCommand}" if ctx.restCommand?
		E "method:#{ctx.command}" if ctx.restCommand?
		E "params:#{JSON.stringify ctx.restParam}" if ctx.restParam?

	checkError=(e)=>
		if e
			P e.toString()
			process.exit 1

	doActivateIfNecessary=(cb)=>
		if ctx.doActivate
			OsaScript.execute "tell application \"safari\"\nactivate\nend tell",cb
		else
			cb(null,null,null)

	switch ctx.command
		when 'print'
			OsaScript.execute "tell application \"safari\"\nURL in front document\nend tell",(e,r,w)=>
				checkError e
				P r

		when 'printTitle'
			OsaScript.execute "tell application \"safari\"\nname of front document\nend tell",(e,r,w)=>
				checkError e
				P r

		when 'copy'
			OsaScript.execute "tell application \"safari\"\nset curURL to URL in front document\nset the clipboard to curURL\nend tell",(e,r,w)=>
				checkError e

		when 'set'
			OsaScript.execute "tell application \"safari\"\nset URL in front document to URLTOSET\nend tell",{URLTOSET:ctx.url},(e,r,w)=>
				checkError e
				doActivateIfNecessary (e,r,w)=>
					checkError e

		when 'search'
			OsaScript.execute "tell application \"safari\"\nsearch the web in front document for QUERY\nend tell",{QUERY:ctx.query},(e,r,w)=>
				checkError e
				doActivateIfNecessary (e,r,w)=>
					checkError e

		when 'javaScript'
			D ctx.javaScript
			doActivateIfNecessary (e,r,w)=>
				checkError e
				OsaScript.execute "tell application \"safari\"\ndo JavaScript TORUN in front document\nend tell",{TORUN:ctx.javaScript},(e,r,w)=>
					checkError e
					P r if r and !ctx.dropResult

catch e
	E console.error e.toString()
	process.exit 1



