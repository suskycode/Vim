" Vim syntax file
" Language:	Cascading Style Sheets
" Maintainer:	Claudio Fleiner <claudio@fleiner.com>
" URL:		http://www.fleiner.com/vim/syntax/css.vim
" Last Change:	2007 Nov 06
" CSS2 by Nikolai Weibull
" Full CSS2, HTML4 support by Yeti
" 把bg换成6位的十六进制代码
function! s:FGforBG(bg)
   " takes a 6hex color code and returns a matching color that is visible
   " substitute 删除开头的#
   let pure = substitute(a:bg,'^#','','')
   " 按位取出RGB
   let r = eval('0x'.pure[0].pure[1])
   let g = eval('0x'.pure[2].pure[3])
   let b = eval('0x'.pure[4].pure[5])
   if r*30 + g*59 + b*11 > 12000
      return '#000000'
   else
      return '#ffffff'
   end
endfunction

function! s:SetMatcher(clr,pat)
   let group = 'cssColor'.substitute(a:clr,'^#','','')
   " Redirect messages to a variable
   redir => s:currentmatch
      silent! exe 'syn list '.group
   " End redirecting messages
   redir END
   " !~ regexp doesn't match
   if s:currentmatch !~ a:pat.'\/'
      exe 'syn match '.group.' /'.a:pat.'\>/ contained'
      exe 'syn cluster cssColors add='.group
      if has('gui_running')
        exe 'hi '.group.' guifg='.s:FGforBG(a:clr)
        exe 'hi '.group.' guibg='.a:clr
      elseif &t_Co == 256
        exe 'hi '.group.' ctermfg='.s:Rgb2xterm(s:FGforBG(a:clr))
        exe 'hi '.group.' ctermbg='.s:Rgb2xterm(a:clr)
      endif
      return 1
   else
      return 0
   endif
endfunction

"" the 6 value iterations in the xterm color cube
let s:valuerange = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
"
"" 16 basic colors
let s:basic16 = [ [ 0x00, 0x00, 0x00 ], [ 0xCD, 0x00, 0x00 ], [ 0x00, 0xCD, 0x00 ], [ 0xCD, 0xCD, 0x00 ], [ 0x00, 0x00, 0xEE ], [ 0xCD, 0x00, 0xCD ], [ 0x00, 0xCD, 0xCD ], [ 0xE5, 0xE5, 0xE5 ], [ 0x7F, 0x7F, 0x7F ], [ 0xFF, 0x00, 0x00 ], [ 0x00, 0xFF, 0x00 ], [ 0xFF, 0xFF, 0x00 ], [ 0x5C, 0x5C, 0xFF ], [ 0xFF, 0x00, 0xFF ], [ 0x00, 0xFF, 0xFF ], [ 0xFF, 0xFF, 0xFF ] ]
:
function! s:Xterm2rgb(color) 
	" 16 basic colors
   let r=0
   let g=0
   let b=0
   if a:color<16
      let r = s:basic16[a:color][0]
      let g = s:basic16[a:color][1]
      let b = s:basic16[a:color][2]
   endif
	
	" color cube color
   if a:color>=16 && a:color<=232
      let color=a:color-16
      let r = s:valuerange[(color/36)%6]
      let g = s:valuerange[(color/6)%6]
      let b = s:valuerange[color%6]
   endif
	
	" gray tone
	if a:color>=233 && a:color<=253
      let r=8+(a:color-232)*0x0a
      let g=r
      let b=r
   endif
   let rgb=[r,g,b]
   return rgb
endfunction

function! s:pow(x, n)
   let x = a:x
   for i in range(a:n-1)
      let x = x*a:x
   return x
endfunction

let s:colortable=[]
for c in range(0, 254)
   let color = s:Xterm2rgb(c)
   call add(s:colortable, color)
endfor

" selects the nearest xterm color for a rgb value like #FF0000
function! s:Rgb2xterm(color)
   let best_match=0
   let smallest_distance = 10000000000
   let r = eval('0x'.a:color[1].a:color[2])
   let g = eval('0x'.a:color[3].a:color[4])
   let b = eval('0x'.a:color[5].a:color[6])
   for c in range(0,254)
      let d = s:pow(s:colortable[c][0]-r,2) + s:pow(s:colortable[c][1]-g,2) + s:pow(s:colortable[c][2]-b,2)
      if d<smallest_distance
      let smallest_distance = d
      let best_match = c
      endif
   endfor
   return best_match
endfunction

function! s:SetNamedColor(clr,name)
   let group = 'cssColor'.substitute(a:clr,'^#','','')
   exe 'syn keyword '.group.' '.a:name.' contained'
   exe 'syn cluster cssColors add='.group
   if has('gui_running')
     exe 'hi '.group.' guifg='.s:FGforBG(a:clr)
     exe 'hi '.group.' guibg='.a:clr
   elseif &t_Co == 256
     exe 'hi '.group.' ctermfg='.s:Rgb2xterm(s:FGforBG(a:clr))
     exe 'hi '.group.' ctermbg='.s:Rgb2xterm(a:clr)
   endif
   return 23
endfunction

function! s:PreviewCSSColorInLine(where)
   " TODO use cssColor matchdata
   let foundcolor = matchstr( getline(a:where), '#[0-9A-Fa-f]\{3,6\}\>' )
   let color = ''
   if foundcolor != ''
      if foundcolor =~ '#\x\{6}$'
         let color = foundcolor
      elseif foundcolor =~ '#\x\{3}$'
         let color = substitute(foundcolor, '\(\x\)\(\x\)\(\x\)', '\1\1\2\2\3\3', '')
      else
         let color = ''
      endif
      if color != ''
         return s:SetMatcher(color,foundcolor)
      else
         return 0
      endif
   else
      return 0
   endif
endfunction

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
  finish
endif
  let main_syntax = 'css'
endif

syn case ignore

syn keyword cssTagName abbr acronym address applet area a b base
syn keyword cssTagName basefont bdo big blockquote body br button
syn keyword cssTagName caption center cite code col colgroup dd del
syn keyword cssTagName dfn dir div dl dt em fieldset font form frame
syn keyword cssTagName frameset h1 h2 h3 h4 h5 h6 head hr html img i
syn keyword cssTagName iframe img input ins isindex kbd label legend li
syn keyword cssTagName link map menu meta noframes noscript ol optgroup
syn keyword cssTagName option p param pre q s samp script select small
syn keyword cssTagName span strike strong style sub sup tbody td
syn keyword cssTagName textarea tfoot th thead title tr tt ul u var
syn match cssTagName "\<table\>"
syn match cssTagName "\*"

syn match cssTagName "@page\>" nextgroup=cssDefinition

syn match cssSelectorOp "[+>.]"
syn match cssSelectorOp2 "[~|]\?=" contained
syn region cssAttributeSelector matchgroup=cssSelectorOp start="\[" end="]" transparent contains=cssUnicodeEscape,cssSelectorOp2,cssStringQ,cssStringQQ

try
syn match cssIdentifier "#[A-Za-z?�_@][A-Za-z?�0-9_@-]*"
catch /^.*/
syn match cssIdentifier "#[A-Za-z_@][A-Za-z0-9_@-]*"
endtry


syn match cssMedia "@media\>" nextgroup=cssMediaType skipwhite skipnl
syn keyword cssMediaType contained screen print aural braile embosed handheld projection ty tv all nextgroup=cssMediaComma,cssMediaBlock skipwhite skipnl
syn match cssMediaComma "," nextgroup=cssMediaType skipwhite skipnl
syn region cssMediaBlock transparent matchgroup=cssBraces start='{' end='}' contains=cssTagName,cssError,cssComment,cssDefinition,cssURL,cssUnicodeEscape,cssIdentifier

syn match cssValueInteger contained "[-+]\=\d\+"
syn match cssValueNumber contained "[-+]\=\d\+\(\.\d*\)\="
syn match cssValueLength contained "[-+]\=\d\+\(\.\d*\)\=\(%\|mm\|cm\|in\|pt\|pc\|em\|ex\|px\)"
syn match cssValueAngle contained "[-+]\=\d\+\(\.\d*\)\=\(deg\|grad\|rad\)"
syn match cssValueTime contained "+\=\d\+\(\.\d*\)\=\(ms\|s\)"
syn match cssValueFrequency contained "+\=\d\+\(\.\d*\)\=\(Hz\|kHz\)"

syn match cssFontDescriptor "@font-face\>" nextgroup=cssFontDescriptorBlock skipwhite skipnl
syn region cssFontDescriptorBlock contained transparent matchgroup=cssBraces start="{" end="}" contains=cssComment,cssError,cssUnicodeEscape,cssFontProp,cssFontAttr,cssCommonAttr,cssStringQ,cssStringQQ,cssFontDescriptorProp,cssValue.*,cssFontDescriptorFunction,cssUnicodeRange,cssFontDescriptorAttr
syn match cssFontDescriptorProp contained "\<\(unicode-range\|unit-per-em\|panose-1\|cap-height\|x-height\|definition-src\)\>"
syn keyword cssFontDescriptorProp contained src stemv stemh slope ascent descent widths bbox baseline centerline mathline topline
syn keyword cssFontDescriptorAttr contained all
syn region cssFontDescriptorFunction contained matchgroup=cssFunctionName start="\<\(uri\|url\|local\|format\)\s*(" end=")" contains=cssStringQ,cssStringQQ oneline keepend
syn match cssUnicodeRange contained "U+[0-9A-Fa-f?]\+"
syn match cssUnicodeRange contained "U+\x\+-\x\+"

syn keyword cssColor contained aqua black blue fuchsia gray green lime maroon navy olive purple red silver teal yellow
" FIXME: These are actually case-insentivie too, but (a) specs recommend using
" mixed-case (b) it's hard to highlight the word `Background' correctly in
" all situations
syn case match
syn keyword cssColor contained ActiveBorder ActiveCaption AppWorkspace ButtonFace ButtonHighlight ButtonShadow ButtonText CaptionText GrayText Highlight HighlightText InactiveBorder InactiveCaption InactiveCaptionText InfoBackground InfoText Menu MenuText Scrollbar ThreeDDarkShadow ThreeDFace ThreeDHighlight ThreeDLightShadow ThreeDShadow Window WindowFrame WindowText Background
syn case ignore
syn match cssColor contained "\<transparent\>"
syn match cssColor contained "\<white\>"
syn match cssColor contained "#[0-9A-Fa-f]\{3\}\>"
syn match cssColor contained "#[0-9A-Fa-f]\{6\}\>"
"syn match cssColor contained "\<rgb\s*(\s*\d\+\(\.\d*\)\=%\=\s*,\s*\d\+\(\.\d*\)\=%\=\s*,\s*\d\+\(\.\d*\)\=%\=\s*)"
syn region cssURL contained matchgroup=cssFunctionName start="\<url\s*(" end=")" oneline keepend
syn region cssFunction contained matchgroup=cssFunctionName start="\<\(rgb\|clip\|attr\|counter\|rect\)\s*(" end=")" oneline keepend

syn match cssImportant contained "!\s*important\>"

syn keyword cssCommonAttr contained auto none inherit
syn keyword cssCommonAttr contained top bottom
syn keyword cssCommonAttr contained medium normal

syn match cssFontProp contained "\<font\>\(-\(family\|style\|variant\|weight\|size\(-adjust\)\=\|stretch\)\>\)\="
syn match cssFontAttr contained "\<\(sans-\)\=\<serif\>"
syn match cssFontAttr contained "\<small\>\(-\(caps\|caption\)\>\)\="
syn match cssFontAttr contained "\<x\{1,2\}-\(large\|small\)\>"
syn match cssFontAttr contained "\<message-box\>"
syn match cssFontAttr contained "\<status-bar\>"
syn match cssFontAttr contained "\<\(\(ultra\|extra\|semi\|status-bar\)-\)\=\(condensed\|expanded\)\>"
syn keyword cssFontAttr contained cursive fantasy monospace italic oblique
syn keyword cssFontAttr contained bold bolder lighter larger smaller
syn keyword cssFontAttr contained icon menu
syn match cssFontAttr contained "\<caption\>"
syn keyword cssFontAttr contained large smaller larger
syn keyword cssFontAttr contained narrower wider

syn keyword cssColorProp contained color
syn match cssColorProp contained "\<background\(-\(color\|image\|attachment\|position\)\)\="
syn keyword cssColorAttr contained center scroll fixed
syn match cssColorAttr contained "\<repeat\(-[xy]\)\=\>"
syn match cssColorAttr contained "\<no-repeat\>"

syn match cssTextProp "\<\(\(word\|letter\)-spacing\|text\(-\(decoration\|transform\|align\|index\|shadow\)\)\=\|vertical-align\|unicode-bidi\|line-height\)\>"
syn match cssTextAttr contained "\<line-through\>"
syn match cssTextAttr contained "\<text-indent\>"
syn match cssTextAttr contained "\<\(text-\)\=\(top\|bottom\)\>"
syn keyword cssTextAttr contained underline overline blink sub super middle
syn keyword cssTextAttr contained capitalize uppercase lowercase center justify baseline sub super

syn match cssBoxProp contained "\<\(margin\|padding\|border\)\(-\(top\|right\|bottom\|left\)\)\=\>"
syn match cssBoxProp contained "\<border-\(\(\(top\|right\|bottom\|left\)-\)\=\(width\|color\|style\)\)\=\>"
syn match cssBoxProp contained "\<\(width\|z-index\)\>"
syn match cssBoxProp contained "\<\(min\|max\)-\(width\|height\)\>"
syn keyword cssBoxProp contained width height float clear overflow clip visibility
syn keyword cssBoxAttr contained thin thick both
syn keyword cssBoxAttr contained dotted dashed solid double groove ridge inset outset
syn keyword cssBoxAttr contained hidden visible scroll collapse

syn keyword cssGeneratedContentProp contained content quotes
syn match cssGeneratedContentProp contained "\<counter-\(reset\|increment\)\>"
syn match cssGeneratedContentProp contained "\<list-style\(-\(type\|position\|image\)\)\=\>"
syn match cssGeneratedContentAttr contained "\<\(no-\)\=\(open\|close\)-quote\>"
syn match cssAuralAttr contained "\<lower\>"
syn match cssGeneratedContentAttr contained "\<\(lower\|upper\)-\(roman\|alpha\|greek\|latin\)\>"
syn match cssGeneratedContentAttr contained "\<\(hiragana\|katakana\)\(-iroha\)\=\>"
syn match cssGeneratedContentAttr contained "\<\(decimal\(-leading-zero\)\=\|cjk-ideographic\)\>"
syn keyword cssGeneratedContentAttr contained disc circle square hebrew armenian georgian
syn keyword cssGeneratedContentAttr contained inside outside

syn match cssPagingProp contained "\<page\(-break-\(before\|after\|inside\)\)\=\>"
syn keyword cssPagingProp contained size marks inside orphans widows
syn keyword cssPagingAttr contained landscape portrait crop cross always avoid

syn keyword cssUIProp contained cursor
syn match cssUIProp contained "\<outline\(-\(width\|style\|color\)\)\=\>"
syn match cssUIAttr contained "\<[ns]\=[ew]\=-resize\>"
syn keyword cssUIAttr contained default crosshair pointer move wait help
syn keyword cssUIAttr contained thin thick
syn keyword cssUIAttr contained dotted dashed solid double groove ridge inset outset
syn keyword cssUIAttr contained invert

syn match cssRenderAttr contained "\<marker\>"
syn match cssRenderProp contained "\<\(display\|marker-offset\|unicode-bidi\|white-space\|list-item\|run-in\|inline-table\)\>"
syn keyword cssRenderProp contained position top bottom direction
syn match cssRenderProp contained "\<\(left\|right\)\>"
syn keyword cssRenderAttr contained block inline compact
syn match cssRenderAttr contained "\<table\(-\(row-gorup\|\(header\|footer\)-group\|row\|column\(-group\)\=\|cell\|caption\)\)\=\>"
syn keyword cssRenderAttr contained static relative absolute fixed
syn keyword cssRenderAttr contained ltr rtl embed bidi-override pre nowrap
syn match cssRenderAttr contained "\<bidi-override\>"


syn match cssAuralProp contained "\<\(pause\|cue\)\(-\(before\|after\)\)\=\>"
syn match cssAuralProp contained "\<\(play-during\|speech-rate\|voice-family\|pitch\(-range\)\=\|speak\(-\(punctuation\|numerals\)\)\=\)\>"
syn keyword cssAuralProp contained volume during azimuth elevation stress richness
syn match cssAuralAttr contained "\<\(x-\)\=\(soft\|loud\)\>"
syn keyword cssAuralAttr contained silent
syn match cssAuralAttr contained "\<spell-out\>"
syn keyword cssAuralAttr contained non mix
syn match cssAuralAttr contained "\<\(left\|right\)-side\>"
syn match cssAuralAttr contained "\<\(far\|center\)-\(left\|center\|right\)\>"
syn keyword cssAuralAttr contained leftwards rightwards behind
syn keyword cssAuralAttr contained below level above higher
syn match cssAuralAttr contained "\<\(x-\)\=\(slow\|fast\)\>"
syn keyword cssAuralAttr contained faster slower
syn keyword cssAuralAttr contained male female child code digits continuous

syn match cssTableProp contained "\<\(caption-side\|table-layout\|border-collapse\|border-spacing\|empty-cells\|speak-header\)\>"
syn keyword cssTableAttr contained fixed collapse separate show hide once always

" FIXME: This allows cssMediaBlock before the semicolon, which is wrong.
syn region cssInclude start="@import" end=";" contains=cssComment,cssURL,cssUnicodeEscape,cssMediaType
syn match cssBraces contained "[{}]"
syn match cssError contained "{@<>"
syn region cssDefinition transparent matchgroup=cssBraces start='{' end='}' contains=css.*Attr,css.*Prop,cssComment,cssValue.*,cssColor,cssURL,cssImportant,cssError,cssStringQ,cssStringQQ,cssFunction,cssUnicodeEscape
syn match cssBraceError "}"

syn match cssPseudoClass ":\S*" contains=cssPseudoClassId,cssUnicodeEscape
syn keyword cssPseudoClassId contained link visited active hover focus before after left right
syn match cssPseudoClassId contained "\<first\(-\(line\|letter\|child\)\)\=\>"
syn region cssPseudoClassLang matchgroup=cssPseudoClassId start=":lang(" end=")" oneline

syn region cssComment start="/\*" end="\*/" contains=@Spell

syn match cssUnicodeEscape "\\\x\{1,6}\s\?"
syn match cssSpecialCharQQ +\\"+ contained
syn match cssSpecialCharQ +\\'+ contained
syn region cssStringQQ start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=cssUnicodeEscape,cssSpecialCharQQ
syn region cssStringQ start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=cssUnicodeEscape,cssSpecialCharQ
syn match cssClassName "\.[A-Za-z][A-Za-z0-9_-]\+"

if main_syntax == "css"
  syn sync minlines=10
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_css_syn_inits")
  if version < 508
    let did_css_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink cssComment Comment
  HiLink cssTagName Statement
  HiLink cssSelectorOp Special
  HiLink cssSelectorOp2 Special
  HiLink cssFontProp StorageClass
  HiLink cssColorProp StorageClass
  HiLink cssTextProp StorageClass
  HiLink cssBoxProp StorageClass
  HiLink cssRenderProp StorageClass
  HiLink cssAuralProp StorageClass
  HiLink cssRenderProp StorageClass
  HiLink cssGeneratedContentProp StorageClass
  HiLink cssPagingProp StorageClass
  HiLink cssTableProp StorageClass
  HiLink cssUIProp StorageClass
  HiLink cssFontAttr Type
  HiLink cssColorAttr Type
  HiLink cssTextAttr Type
  HiLink cssBoxAttr Type
  HiLink cssRenderAttr Type
  HiLink cssAuralAttr Type
  HiLink cssGeneratedContentAttr Type
  HiLink cssPagingAttr Type
  HiLink cssTableAttr Type
  HiLink cssUIAttr Type
  HiLink cssCommonAttr Type
  HiLink cssPseudoClassId PreProc
  HiLink cssPseudoClassLang Constant
  HiLink cssValueLength Number
  HiLink cssValueInteger Number
  HiLink cssValueNumber Number
  HiLink cssValueAngle Number
  HiLink cssValueTime Number
  HiLink cssValueFrequency Number
  HiLink cssFunction Constant
  HiLink cssURL String
  HiLink cssFunctionName Function
  HiLink cssColor Constant
  HiLink cssIdentifier Function
  HiLink cssInclude Include
  HiLink cssImportant Special
  HiLink cssBraces Function
  HiLink cssBraceError Error
  HiLink cssError Error
  HiLink cssInclude Include
  HiLink cssUnicodeEscape Special
  HiLink cssStringQQ String
  HiLink cssStringQ String
  HiLink cssMedia Special
  HiLink cssMediaType Special
  HiLink cssMediaComma Normal
  HiLink cssFontDescriptor Special
  HiLink cssFontDescriptorFunction Constant
  HiLink cssFontDescriptorProp StorageClass
  HiLink cssFontDescriptorAttr Type
  HiLink cssUnicodeRange Constant
  HiLink cssClassName Function
  delcommand HiLink
endif

" 我们的要求是必须在256色下，所以要设置:set t_Co=256
if has("gui_running") || &t_Co==256
   " HACK modify cssDefinition to add @cssColors to its contains
   redir => s:olddef
      silent!  syn list cssDefinition
   redir END
   if s:olddef != ''
      let s:b = strridx(s:olddef,'matchgroup')
      if s:b != -1
         exe 'syn region cssDefinition '.strpart(s:olddef,s:b).',@cssColors'
      endif
   endif

   " w3c Colors
   let i = s:SetNamedColor('#800000', 'maroon')
   let i = s:SetNamedColor('#ff0000', 'red')
   let i = s:SetNamedColor('#ffA500', 'orange')
   let i = s:SetNamedColor('#ffff00', 'yellow')
   let i = s:SetNamedColor('#808000', 'olive')
   let i = s:SetNamedColor('#800080', 'purple')
   let i = s:SetNamedColor('#ff00ff', 'fuchsia')
   let i = s:SetNamedColor('#ffffff', 'white')
   let i = s:SetNamedColor('#00ff00', 'lime')
   let i = s:SetNamedColor('#008000', 'green')
   let i = s:SetNamedColor('#000080', 'navy')
   let i = s:SetNamedColor('#0000ff', 'blue')
   let i = s:SetNamedColor('#00ffff', 'aqua')
   let i = s:SetNamedColor('#008080', 'teal')
   let i = s:SetNamedColor('#000000', 'black')
   let i = s:SetNamedColor('#c0c0c0', 'silver')
   let i = s:SetNamedColor('#808080', 'gray')

   " extra colors
   let i = s:SetNamedColor('#F0F8FF','AliceBlue')
   let i = s:SetNamedColor('#FAEBD7','AntiqueWhite')
   let i = s:SetNamedColor('#7FFFD4','Aquamarine')
   let i = s:SetNamedColor('#F0FFFF','Azure')
   let i = s:SetNamedColor('#F5F5DC','Beige')
   let i = s:SetNamedColor('#FFE4C4','Bisque')
   let i = s:SetNamedColor('#FFEBCD','BlanchedAlmond')
   let i = s:SetNamedColor('#8A2BE2','BlueViolet')
   let i = s:SetNamedColor('#A52A2A','Brown')
   let i = s:SetNamedColor('#DEB887','BurlyWood')
   let i = s:SetNamedColor('#5F9EA0','CadetBlue')
   let i = s:SetNamedColor('#7FFF00','Chartreuse')
   let i = s:SetNamedColor('#D2691E','Chocolate')
   let i = s:SetNamedColor('#FF7F50','Coral')
   let i = s:SetNamedColor('#6495ED','CornflowerBlue')
   let i = s:SetNamedColor('#FFF8DC','Cornsilk')
   let i = s:SetNamedColor('#DC143C','Crimson')
   let i = s:SetNamedColor('#00FFFF','Cyan')
   let i = s:SetNamedColor('#00008B','DarkBlue')
   let i = s:SetNamedColor('#008B8B','DarkCyan')
   let i = s:SetNamedColor('#B8860B','DarkGoldenRod')
   let i = s:SetNamedColor('#A9A9A9','DarkGray')
   let i = s:SetNamedColor('#A9A9A9','DarkGrey')
   let i = s:SetNamedColor('#006400','DarkGreen')
   let i = s:SetNamedColor('#BDB76B','DarkKhaki')
   let i = s:SetNamedColor('#8B008B','DarkMagenta')
   let i = s:SetNamedColor('#556B2F','DarkOliveGreen')
   let i = s:SetNamedColor('#FF8C00','Darkorange')
   let i = s:SetNamedColor('#9932CC','DarkOrchid')
   let i = s:SetNamedColor('#8B0000','DarkRed')
   let i = s:SetNamedColor('#E9967A','DarkSalmon')
   let i = s:SetNamedColor('#8FBC8F','DarkSeaGreen')
   let i = s:SetNamedColor('#483D8B','DarkSlateBlue')
   let i = s:SetNamedColor('#2F4F4F','DarkSlateGray')
   let i = s:SetNamedColor('#2F4F4F','DarkSlateGrey')
   let i = s:SetNamedColor('#00CED1','DarkTurquoise')
   let i = s:SetNamedColor('#9400D3','DarkViolet')
   let i = s:SetNamedColor('#FF1493','DeepPink')
   let i = s:SetNamedColor('#00BFFF','DeepSkyBlue')
   let i = s:SetNamedColor('#696969','DimGray')
   let i = s:SetNamedColor('#696969','DimGrey')
   let i = s:SetNamedColor('#1E90FF','DodgerBlue')
   let i = s:SetNamedColor('#B22222','FireBrick')
   let i = s:SetNamedColor('#FFFAF0','FloralWhite')
   let i = s:SetNamedColor('#228B22','ForestGreen')
   let i = s:SetNamedColor('#DCDCDC','Gainsboro')
   let i = s:SetNamedColor('#F8F8FF','GhostWhite')
   let i = s:SetNamedColor('#FFD700','Gold')
   let i = s:SetNamedColor('#DAA520','GoldenRod')
   let i = s:SetNamedColor('#808080','Grey')
   let i = s:SetNamedColor('#ADFF2F','GreenYellow')
   let i = s:SetNamedColor('#F0FFF0','HoneyDew')
   let i = s:SetNamedColor('#FF69B4','HotPink')
   let i = s:SetNamedColor('#CD5C5C','IndianRed')
   let i = s:SetNamedColor('#4B0082','Indigo')
   let i = s:SetNamedColor('#FFFFF0','Ivory')
   let i = s:SetNamedColor('#F0E68C','Khaki')
   let i = s:SetNamedColor('#E6E6FA','Lavender')
   let i = s:SetNamedColor('#FFF0F5','LavenderBlush')
   let i = s:SetNamedColor('#7CFC00','LawnGreen')
   let i = s:SetNamedColor('#FFFACD','LemonChiffon')
   let i = s:SetNamedColor('#ADD8E6','LightBlue')
   let i = s:SetNamedColor('#F08080','LightCoral')
   let i = s:SetNamedColor('#E0FFFF','LightCyan')
   let i = s:SetNamedColor('#FAFAD2','LightGoldenRodYellow')
   let i = s:SetNamedColor('#D3D3D3','LightGray')
   let i = s:SetNamedColor('#D3D3D3','LightGrey')
   let i = s:SetNamedColor('#90EE90','LightGreen')
   let i = s:SetNamedColor('#FFB6C1','LightPink')
   let i = s:SetNamedColor('#FFA07A','LightSalmon')
   let i = s:SetNamedColor('#20B2AA','LightSeaGreen')
   let i = s:SetNamedColor('#87CEFA','LightSkyBlue')
   let i = s:SetNamedColor('#778899','LightSlateGray')
   let i = s:SetNamedColor('#778899','LightSlateGrey')
   let i = s:SetNamedColor('#B0C4DE','LightSteelBlue')
   let i = s:SetNamedColor('#FFFFE0','LightYellow')
   let i = s:SetNamedColor('#32CD32','LimeGreen')
   let i = s:SetNamedColor('#FAF0E6','Linen')
   let i = s:SetNamedColor('#FF00FF','Magenta')
   let i = s:SetNamedColor('#66CDAA','MediumAquaMarine')
   let i = s:SetNamedColor('#0000CD','MediumBlue')
   let i = s:SetNamedColor('#BA55D3','MediumOrchid')
   let i = s:SetNamedColor('#9370D8','MediumPurple')
   let i = s:SetNamedColor('#3CB371','MediumSeaGreen')
   let i = s:SetNamedColor('#7B68EE','MediumSlateBlue')
   let i = s:SetNamedColor('#00FA9A','MediumSpringGreen')
   let i = s:SetNamedColor('#48D1CC','MediumTurquoise')
   let i = s:SetNamedColor('#C71585','MediumVioletRed')
   let i = s:SetNamedColor('#191970','MidnightBlue')
   let i = s:SetNamedColor('#F5FFFA','MintCream')
   let i = s:SetNamedColor('#FFE4E1','MistyRose')
   let i = s:SetNamedColor('#FFE4B5','Moccasin')
   let i = s:SetNamedColor('#FFDEAD','NavajoWhite')
   let i = s:SetNamedColor('#FDF5E6','OldLace')
   let i = s:SetNamedColor('#6B8E23','OliveDrab')
   let i = s:SetNamedColor('#FF4500','OrangeRed')
   let i = s:SetNamedColor('#DA70D6','Orchid')
   let i = s:SetNamedColor('#EEE8AA','PaleGoldenRod')
   let i = s:SetNamedColor('#98FB98','PaleGreen')
   let i = s:SetNamedColor('#AFEEEE','PaleTurquoise')
   let i = s:SetNamedColor('#D87093','PaleVioletRed')
   let i = s:SetNamedColor('#FFEFD5','PapayaWhip')
   let i = s:SetNamedColor('#FFDAB9','PeachPuff')
   let i = s:SetNamedColor('#CD853F','Peru')
   let i = s:SetNamedColor('#FFC0CB','Pink')
   let i = s:SetNamedColor('#DDA0DD','Plum')
   let i = s:SetNamedColor('#B0E0E6','PowderBlue')
   let i = s:SetNamedColor('#BC8F8F','RosyBrown')
   let i = s:SetNamedColor('#4169E1','RoyalBlue')
   let i = s:SetNamedColor('#8B4513','SaddleBrown')
   let i = s:SetNamedColor('#FA8072','Salmon')
   let i = s:SetNamedColor('#F4A460','SandyBrown')
   let i = s:SetNamedColor('#2E8B57','SeaGreen')
   let i = s:SetNamedColor('#FFF5EE','SeaShell')
   let i = s:SetNamedColor('#A0522D','Sienna')
   let i = s:SetNamedColor('#87CEEB','SkyBlue')
   let i = s:SetNamedColor('#6A5ACD','SlateBlue')
   let i = s:SetNamedColor('#708090','SlateGray')
   let i = s:SetNamedColor('#708090','SlateGrey')
   let i = s:SetNamedColor('#FFFAFA','Snow')
   let i = s:SetNamedColor('#00FF7F','SpringGreen')
   let i = s:SetNamedColor('#4682B4','SteelBlue')
   let i = s:SetNamedColor('#D2B48C','Tan')
   let i = s:SetNamedColor('#D8BFD8','Thistle')
   let i = s:SetNamedColor('#FF6347','Tomato')
   let i = s:SetNamedColor('#40E0D0','Turquoise')
   let i = s:SetNamedColor('#EE82EE','Violet')
   let i = s:SetNamedColor('#F5DEB3','Wheat')
   let i = s:SetNamedColor('#F5F5F5','WhiteSmoke')
   let i = s:SetNamedColor('#9ACD32','YellowGreen')



   let i = 1
   while i <= line("$")
      call s:PreviewCSSColorInLine(i)
      let i = i+1
   endwhile
   unlet i

   autocmd CursorHold * silent call s:PreviewCSSColorInLine('.')
   autocmd CursorHoldI * silent call s:PreviewCSSColorInLine('.')
   set ut=100
endif		" has("gui_running")

let b:current_syntax = "css"

if main_syntax == 'css'
  unlet main_syntax
endif

" vim: ts=8

