# safari-ctl - Command Line Tool To Control Safari for MacOS

A Command Line Tool to Control Safari for MacOS. (Browsing/FillingForm/GetSetCopyURL/JavascriptInjection/GetTitle/Search)

![](https://kanasys.s3-ap-northeast-1.amazonaws.com/safari-ctl-1566223361.jpg)

- [Documentation(npmjs)](https://www.npmjs.com/safari-ctl)
- [Bug Report(GitHub)](https://github.com/kssfilo/safari-ctl)
- [Home Page](https://kanasys.com/gtech/)

```
### Get current URL on Safari

$ safari-ctl
https://github.com

### Copy current URL on Safari to the clipboard

$ safari-ctl -s

### Navigating by command line

$ safari-ctl -m
# marks all <a> with numbers

$ safari-ctl -a 32
# click 32'th <a>

$ safari-ctl -b
# history back

### Filing form

$ safari-ctl -M
# marks all <input> with numbers

$ safari-ctl -A 0 -I 'Japan'
# Fill 0th input with 'Japan'

$ safari-ctl -A 1
# click 1st input button

### Javascript Injection

$  safari-ctl -j 'document.getElementById("sb_form_q").value="Japan"'
Japan
```

## Install

    npm i -g safari-ctl

You must enable the 'Allow JavaScript from Apple Events' option in Safari's Develop menu to use some features.

@PARTPIPE@|dist/cli.js -h

You can see detail usage on npmjs.com

- [Documentation(npmjs)](https://www.npmjs.com/package/safari-ctl)

@PARTPIPE@

## Change Log

- 0.1.x: beta release

## Idea

- history forward
- marking buttons
