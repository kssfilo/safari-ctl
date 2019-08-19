#!/usr/bin/env coffee
GetOpt=require '@kssfilo/getopt'
Fs=require 'fs'
Path=require 'path'
Util=require 'util'
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
}

optUsages=
	h:["command","show help and command list.if you specify command name, you can see details."]
	"?":["command",""]
	d:"debug mode"
	p:"print current Safari's URL(default)"
	c:"copy current Safari's URL into the clipboard"
	s:["URL","set <URL> to Safari's active tab"]
	S:["URL","same as -s but set focus to Safari"]
	q:["query","search <query> to Safari's active tab"]
	Q:["URL","same as -q but set focus to Safari"]
	g:"print selected string on current Safari's tab"
	j:["javascript","run <javascript> on active tab(You must enable the 'Allow JavaScript from Apple Events' option in Safari's Develop menu to)"]
	J:["javascript","same as s but set focus to Safari"]

try
	GetOpt.setopt 'h?dcs:S:tj:J:gq:Q:p'
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

	if ctx.command is 'usage'
		P """
		## Command line
		
			#{AppName} [-u <username>] <command> [options]
			
			@PARTPIPE@DESCRIPTION@PARTPIPE@
			
			Copyright (C) 2019-@PARTPIPE@|date +%Y;@PARTPIPE@ @kssfilo(https://kanasys.com/gtech/)

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

		$ #{AppName} -S 'http://github.com'
		# with focus
		
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

	D "-options"
	D "#{JSON.stringify ctx,null,2}"
	D "-------"
	D "sanity checking.."
	D "..OK"

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
			OsaScript.execute "tell application \"safari\"\nfront document\nend tell",(e,r,w)=>
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
					P r if r

catch e
	E console.error e.toString()
	process.exit 1



