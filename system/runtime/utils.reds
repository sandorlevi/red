Red/System [
	Title:   "Red/System runtime OS-independent runtime functions"
	Author:  "Nenad Rakocevic"
	File: 	 %utils.reds
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2015 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;-------------------------------------------
;-- Print a given number of characters at max from a c-string
;-------------------------------------------
prin-only: func [s [c-string!] len [integer!] return: [c-string!] /local p][
	p: s
	while [p/1 <> null-byte][
		if zero? len [break]
		prin-byte p/1
		p: p + 1
		len: len - 1
	]
	s
]

;-------------------------------------------
;-- Print a byte value in source format (MOLD-ed format)
;-------------------------------------------
prin-molded-byte: func [b [byte!] /local i][
	prin {#"}
	i: as-integer b
	case [
		i =  00h [prin "^^@"]
		i =  09h [prin "^^-"]
		i =  0Ah [prin "^^/"]
		i =  1Bh [prin "^^]"]
		i <= 1Fh [prin-byte #"^^" prin-byte #"A" + i - 1]
		i <= 7Fh [prin-byte b]
		i <= FFh [prin "^^(" prin-2hex i prin-byte #")"]
	]
	prin-byte #"^""
]

;-------------------------------------------
;-- Print in console a single byte as an ASCII character
;-------------------------------------------
prin-byte: func [
	c 		[byte!]							;-- ASCII value to print
	return: [byte!]
	/local char
][
	char: " "
	char/1: c
	prin char
	c
]

;-------------------------------------------
;-- Low-level polymorphic print function 
;-- (not intended to be called directly)
;-------------------------------------------
_print: func [
	count	[integer!]						;-- typed values count
	list	[typed-value!]					;-- pointer on first typed value
	spaced?	[logic!]						;-- if TRUE, insert a space between items
	/local 
		fp [typed-float!]
		s  [c-string!]
		c  [byte!]
][
	until [
		switch list/type [
			type-logic!	   [prin either as-logic list/value ["true"]["false"]]
			type-integer!  [prin-int list/value]
			type-float!    [fp: as typed-float! list prin-float fp/value]
			type-float32!  [prin-float32 as-float32 list/value]
			type-byte!     [prin-byte as-byte list/value]
			type-c-string! [s: as-c-string list/value prin s]
			default 	   [prin-hex list/value]
		]
		count: count - 1
		
		if all [spaced? count <> 0][
			switch list/type [
				type-c-string! [
					s: s + (length? s) - 1
					c: s/1
				]
				type-byte! [
					c: as-byte list/value
				]
				default [
					c: null-byte
				]
			]
			if all [
				c <> #" "
				c <> #"^/"
				c <> #"^M"
				c <> #"^-"
			][
				prin " "
			]
		]
		list: list + 1
		zero? count
	]
]

;-------------------------------------------
;-- Polymorphic print in console
;-- (inserts a space character between each item)
;-------------------------------------------
print-wide: func [
	[typed]	count [integer!] list [typed-value!]
][
	_print count list yes
]

;-------------------------------------------
;-- Polymorphic print in console
;-------------------------------------------
print: func [
	[typed]	count [integer!] list [typed-value!]
][
	_print count list no
]

;-------------------------------------------
;-- Polymorphic print in console, with a line-feed 
;-------------------------------------------
print-line: func [
	[typed]	count [integer!] list [typed-value!]
][
	_print count list no
	prin-byte lf
]

#enum trigonometric-type! [
	TYPE_TANGENT
	TYPE_COSINE
	TYPE_SINE
]

degree-to-radians: func [
	val		[float!]
	type	[integer!]
	return: [float!]
][
	val: val % 360.0
	if any [val > 180.0 val < -180.0] [
		val: val + either val < 0.0 [360.0][-360.0]
	]
	if any [val > 90.0 val < -90.0] [
		if type = TYPE_TANGENT [
			val: val + either val < 0.0 [180.0][-180.0]
		]
		if type = TYPE_SINE [
			val: (either val < 0.0 [-180.0][180.0]) - val
		]
	]
	val: val * PI / 180.0			;-- to radians
	val
]