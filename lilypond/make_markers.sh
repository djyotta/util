#! /bin/bash

#
# This program will generate 'Markers' from bars marked with \barNumberCheck
# Two modes are supported:
#  - basic: each marker is the current bar number in a \markup \box
#  - alpha: each marker is an alphabetic character
#
# Assumptions:
#  - each bar starts on a new line
#  - coding style looks somewhat like this:
#    ...
#
#    | %1
#    a b c d e f g
#    | %2
#    g f e d c b a
#    \time a/b            %it's important that the 'time' keyword preceeds '|'
#    | \barNumberCheck #3
#    a b c d e f g
#    | %4
#    ...
#    
#    minor variances around that should also work.
#  - whitespace (except new lines) is not important:
#    ...
#
#    | %1
#       a b c d e f g
#      | % 2
#    g f e d c b a
#    \time a/b              %it's important that the 'time' keyword preceeds '|'
#    |\barNumberCheck #3    
#    a b c d e f g
#        |%4
#    ...
#    
#    should work the same as the previous example.
# 
set -x
gawk -v type=${2-basic} -f-  $1 <<'EOF'
BEGIN {
    bar = 1
    rest = "s1"
    split("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z", alpha,/,/)
    section = 1
    max_bar = 1
}
{
	if (match($0, "\\\\time[ \t\n\r]*([0-9]+)/([0-9])+", tok)) {
		rest = "s"tok[2]"*"tok[1]
        t[bar] = tok[1]"/"tok[2]
    }
	if (match($0, "\\|[ \t\n\r]*[%][ \t\n\r]*([0-9]+)", tok)) {
		bar = tok[1]
        if (bar > max_bar){
            max_bar = bar
        }
        !b[bar]++
        r[bar] = rest
    }
	if (match($0, "\\|[ \t\n\r]*\\\\barNumberCheck[ \t\n\r]*[#]([0-9]+)", tok)) {
        if (type == "alpha"){
            mark = "\\mark \\markup { \\box { " toupper(alpha[section++]) " } } "
        } else {
            mark = "\\mark \\markup { \\box { " tok[1] " } } "
        }
		bar = tok[1]
        if (bar > max_bar){
            max_bar = bar
        }
        b[bar]++
		m[bar] = mark
        r[bar] = rest
    }
}
END {
    for (bar = 1; bar <= max_bar; bar++){
        if (m[bar]){
            print m[bar]
            print "| \\barNumberCheck #" bar
            print r[bar]
        } else {
            print "| %" bar
            print r[bar]
        }
        if (t[bar] && !(bar == max_bar)) print "\\time "t[bar]
    }
}
EOF


