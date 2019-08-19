#!/usr/bin/env bats

@test "-q" {
	dist/cli.js -q Japan
}

@test "-s" {
	dist/cli.js -s bing.com
}

@test "-j" {
	sleep 5
 	dist/cli.js -j 'document.getElementById("sb_form_q").value="Japan";document.getElementById("sb_form_go").click()'
}

@test "-p" {
	dist/cli.js -s 'kanasys.com/gtech/'
	sleep 5
	test "$(dist/cli.js -p)" = "https://kanasys.com/gtech/"
}

@test "-c" {
	dist/cli.js -s 'kanasys.com/gtech/790'
	sleep 5
	dist/cli.js -c
	test "$(pbpaste)" = "https://kanasys.com/gtech/790"
}
