" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Sept 17, 2016


" TODO: {{{
" " Only load relevent dictionaries
" " Allowing the setting of custom dictionaries
" " Create an easy way to reenter math mode namespace
" " Add . $ functions (perhaps as . and ')
" " " Transform them after jumping out of math mode
" " Add undo and redo keywords
" " Add del keyword
" " Improve command to change to \[ \]
" " Add search keywords?
" " Visually Select when JumpFuncing
" " Map infimum
" " Fix mod keyword
" " Fix JumpFunc for multiline math mode
" }}}

" Special Key Assignment {{{
" Only map these functions if inside a tex file
" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
augroup filetype_tex
    autocmd!
    autocmd FileType tex inoremap _ <C-r>=MathStart()<CR>
    autocmd FileType tex inoremap <Space> <C-r>=ExpandWord()<CR>
augroup END
" }}}

" Main Functions {{{
" Function that starts mathmode
function! MathStart()
    " If already in mathmode, just return a space. This is useful if you want
    " to normally type a keyword. That way, by pressing _, you can space
    " without keyword expansion
    if &ft == 'math'
        return " "
    else
        " If the last character is a space, then start math mode and go inside
        " the brackets
        if getline(".")[col(".")-2] == " "
            set filetype=math
            set syntax=tex
            return "\\(  \\) \<Left>\<Left>\<Left>\<Left>"
        " Otherwise, replace the last word with \(word\)
        else
            return "\<ESC>ciw\\(\<ESC>pa\\) "
        endif
    endif
endfunction

" Function for jumping around
" This function is only used in ExpandWord
function! JumpFunc()
    if &ft == 'math'
        " If there's a <++> to jump to in the line, then jump to it
        if getline('.') =~ '<++>'
            return "\<Right>\<BS>\<ESC>/<++>\<CR>cf>"
        else
        " If there is no <++> on the current line, then exit math mode and jump to
        " right after \)
            set filetype=tex
            execute "normal! / \\\\)\<CR>x"
            return "\<Right>\<Right> "
        endif
    else
        return "\<Right>\<BS>\<ESC>/<+.*+>\<CR>cf>"
    endif
endfunction

function! ExpandWord()
    " Move left so that the cursor is over the word and then expand the word
    normal! h
    let word = expand('<cword>')

    " If the last character was a space, then JumpFunc
    " It's -1 instead of -2 because we already moved to the left one space
    if getline('.')[col(".")-1] == " "
        return JumpFunc()
    endif

    " Check if the dictionary exists for the given filetype.
    if exists('s:vimtexer_'.&ft)
        " If it exists, set that dictionary to the variable 'dictionary'
        execute "let dictionary = s:vimtexer_".&ft
    else
        " If the dictionary doesn't exist, remember, we moved left and are over
        " the last character of the word, so move right and put the original space
        return "\<Right> "
    endif

    " Get the result of the keyword. If the keyword doesn't exist in the
    " dictonary, return the empty string ''
    let rhs = get(dictionary, word,'')

    " If we found a match in the dictionary
    if rhs != ''
        let jumpBack = ""
        " If the RHS contains the identifier "<+++>", then your cursor will be
        " placed there automatically after the subsitution. Notice that, in
        " general, the JumpFunc goes to "<++>" instead
        if rhs =~ '<+++>'
            let jumpBack = "\<ESC>?<+++>\<CR>cf>"
        endif
        " This is a hack for one letter keywords. It types an extra letter and
        " escapes, so now it's two letters
        let hack = "a\<ESC>"
        " Do the hack, then delete the word and go to insert mode, then type
        " out the right hand side then jump back to "<+++>"
        return hack."ciw".rhs.jumpBack
    else
        " If the dictionary doesn't exist, remember, we moved left and are over
        " the last character of the word, so move right and put the original space
        return "\<Right> "
    endif
endfunction
" }}}

" Keywords {{{

" Keyword mappings are simply a dictionary. Dictionaries are of the form
" "vimtexer_" and then the filetype. The result of a keyword is either a
" literal string or a double quoted string, depending on what you want.
"
" In a literal string, the result is just a simple literal substitution
"
" In a double quoted string, \'s need to be escape (i.e. "\\"), however, you
" can use nonalphanumberical keypresses, like "\<CR>", "\<BS>", or "\<Right>"
"
" Unfortunately, comments are not allowed inside multiline vim dictionaries.
" Thus, sections and comments must be included as entries themselves. Make
" sure that the comment more than one word, that way it could never be called
" by the ExpandWord function

" Math Mode Keywords {{{

let s:vimtexer_math = {
\'Section: Lowercase Greek Letters' : 'COMMENT',
    \'alpha'   : '\alpha ',
    \'beta'    : '\beta ',
    \'gamma'   : '\gamma ',
    \'delta'   : '\delta ',
    \'epsilon' : '\epsilon ',
    \'ge'      : '\varepsilon ',
    \'zeta'    : '\zeta ',
    \'eta'     : '\eta ',
    \'theta'   : '\theta ',
    \'iota'    : '\iota ',
    \'kappa'   : '\kappa ',
    \'lambda'  : '\lambda ',
    \'gl'      : '\lambda ',
    \'mu'      : '\mu ',
    \'nu'      : '\nu ',
    \'xi'      : '\xi ',
    \'omega'   : '\omega ',
    \'pi'      : '\pi ',
    \'rho'     : '\rho ',
    \'sigma'   : '\sigma ',
    \'tau'     : '\tau ',
    \'upsilon' : '\upsilon ',
    \'gu'      : '\upsilon ',
    \'phi'     : '\varphi ',
    \'chi'     : '\chi ',
    \'psi'     : '\psi ',
    \
\'Section: Uppercase Greek Letters' : 'COMMENT',
    \'Alpha'   : '\Alpha ',
    \'Beta'    : '\Beta ',
    \'Gamma'   : '\Gamma ',
    \'Delta'   : '\Delta ',
    \'Epsilon' : '\Epsilon ',
    \'Zeta'    : '\Zeta ',
    \'Eta'     : '\Eta ',
    \'Theta'   : '\Theta ',
    \'Iota'    : '\Iota ',
    \'Kappa'   : '\Kappa ',
    \'Lambda'  : '\Lambda ',
    \'Mu'      : '\Mu ',
    \'Nu'      : '\Nu ',
    \'Xi'      : '\Xi ',
    \'Omega'   : '\Omega ',
    \'Pi'      : '\Pi ',
    \'Rho'     : '\Rho ',
    \'Sigma'   : '\Sigma ',
    \'Tau'     : '\Tau ',
    \'Upsilon' : '\Upsilon ',
    \'Phi'     : '\Phi ',
    \'Chi'     : '\Chi ',
    \'Psi'     : '\Psi ',
    \
\'Section: Set Theory' : 'COMMENT',
    \'R'    : '\mathbb{R} ',
    \'C'    : '\mathbb{C} ',
    \'Q'     : '\mathbb{Q} ',
    \'N'    : '\mathbb{N} ',
    \'Z'    : '\mathbb{Z} ',
    \'subs'  : '\subseteq ',
    \'in'    : '\in ',
    \'nin'   : '\not\in ',
    \'cup'   : '\cup ',
    \'cap'   : '\cap ',
    \'union' : '\cup ',
    \'sect'  : '\cap ',
    \'smin'  : '\setminus ',
    \'set'   : '\{ <+++> \} <++>',
    \'card'  : '\card{ <+++> } <++>',
    \'empty' : '\varnothing ',
    \'pair'  : '( <+++> , <++> ) <++>',
    \'dots'  : '\dots ',
    \
\'Section: Logic' : 'COMMENT',
    \'st'      : '\st ',
    \'exists'  : '\exists ',
    \'nexists' : '\nexists ',
    \'forall'  : '\forall ',
    \'implies' : '\implies ',
    \'iff'     : '\iff ',
    \'and'     : '\land ',
    \'or'      : '\lor ',
    \
\'Section: Relations' : 'COMMENT',
    \'lt'      : '< ',
    \'gt'      : '> ',
    \'leq'     : '\leq ',
    \'geq'     : '\geq ',
    \'eq'      : '= ',
    \'nl'      : '\nless ',
    \'ng'      : '\ngtr ',
    \'nleq'    : '\nleq ',
    \'ngeq'    : '\ngeq ',
    \'neq'     : '\neq ',
    \'neg'     : '\neg ',
    \'uarrow'  : '\uparrow ',
    \'darrow'  : '\downarrow ',
    \'divides' : '\divides ',
    \
\'Section: Operations' : 'COMMENT',
    \'add'   : '+ ',
    \'min'   : '- ',
    \'frac'  : '\frac{ <+++> }{ <++> } <++>',
    \'recip' : '\frac{ 1 }{ <+++> } <++>',
    \'dot'   : '\cdot ',
    \'mult'  : '* ',
    \'exp'   : "\<BS>^",
    \'pow'   : "\<BS>^",
    \'sq'    : "\<BS>^2 ",
    \'inv'   : "\<BS>^{-1} ",
    \'cross' : '\times ',
    \
\'Section: Delimiters' : 'COMMENT',
    \'para'  : '\left( <+++> \right) <++>',
    \'sb'    : '\left[ <+++> \right] <++>',
    \'brac'  : '\left\{ <+++> \right\} <++>',
    \'group' : '{ <+++> } <++>',
    \'angle' : '\angle{ <+++> } <++>',
    \'abs'   : '\abs{ <+++> } <++>',
    \
\'Section: Group Theory' : 'COMMENT',
    \'ord'   : '\ord{ <+++> } <++>',
    \'iso'   : '\iso ',
    \'niso'  : '\niso ',
    \'subg'  : '\leq ',
    \'nsubg' : '\trianglelefteq ',
    \'mod'   : '/ ',
    \'aut'   : '\aut ',
    \
\'Section: Functions' : 'COMMENT',
    \'to'    : '\to ',
    \'comp'  : '\circ ',
    \'of'    : '\left( <+++> \right) <++>',
    \'sin'   : '\sin{ <+++> } <++>',
    \'cos'   : '\cos{ <+++> } <++>',
    \'tan'   : '\tan{ <+++> } <++>',
    \'ln'    : '\ln{ <+++> } <++>',
    \'log'   : '\log{ <+++> } <++>',
    \'dfunc' : '<+++> : <++> \to <++>',
    \'sqrt'  : '\sqrt{ <+++> } <++>',
    \'img'   : '\img ',
    \'ker'   : '\ker ',
    \'case'  : '\begin{cases} <+++> \end{cases} <++>',
    \
\'Section: LaTeX commands' : 'COMMENT',
    \'big'  : "è\<ESC>/\\\\)\<CR>lr]?\\\\(\<CR>lr[llcw",
    \'sub'  : "\<BS>_",
    \'ud'   : "\<BS>_{ <+++> }^{ <++> } ",
    \'text' : '\text{ <+++> } <++>',
    \
\'Section: Fancy Variables' : 'COMMENT',
    \'fa' : '\mathcal{A} ',
    \'fn' : '\mathcal{N} ',
    \'fp' : '\mathcal{P} ',
    \'fc' : '\mathcal{C} ',
    \'fm' : '\mathcal{M} ',
    \'ff' : '\mathcal{F} ',
    \'fb' : '\mathcal{B} ',
    \
\'Section: Encapsulating keywords' : 'COMMENT',
    \'bar'  : "\<ESC>F a\\bar{\<ESC>f i} ",
    \'hat'  : "\<ESC>F a\\hat{\<ESC>f i} ",
    \'star' : "\<BS>^* ",
    \'vec'  : "\<ESC>F a\\vec{\<ESC>f i} ",
    \
\'Section: Linear Algebra' : 'COMMENT',
    \'dim' : '\dim ',
    \'det' : '\det ',
    \'com' : "\<BS>^c ",
    \'matrix' : "\<CR>\\begin{bmatrix}\<CR><+++>\<CR>\\end{bmatrix}\<CR><++>",
    \'vdots' : '\vdots & ',
    \'ddots' : '\ddots & ',
    \
\'Section: Constants' : 'COMMENT',
    \'aleph' : '\aleph ',
    \'inf'   : '\infty ',
    \'one'   : '1 ',
    \'zero'  : '0 ',
    \'two'   : '2 ',
    \'three' : '3 ',
    \'four'  : '4 ',
    \
\'Section: Operators' : 'COMMENT',
    \'int'    : '\int^{ <+++> } <++>',
    \'dev'    : '\frac{d}{d<+++> } <++>',
    \'lim'    : '\lim_{ <+++> } <++>',
    \'sum'    : '\sum_{ <+++> }^{ <++> } <++>',
    \'prd'    : '\prod_{ <+++> }^{ <++> } <++>',
    \'limsup' : '\limsup ',
    \'liminf' : '\liminf ',
    \'sup'    : '\sup ',
\}

" }}}


" LaTeX Mode Keywords {{{

let s:vimtexer_tex = {
\'Section: Environments' : 'COMMENT',
    \'exe' : "\\begin{exercise}{<+++>}\<CR><++>\<CR>\\end{exercise}",
    \'prf' : "\\begin{proof}\<CR><+++>\<CR>\\end{proof}",
    \'thm' : "\\begin{theorem}\<CR><+++>\<CR>\\end{theorem}",
    \'lem' : "\\begin{lemma}\<CR><+++>\<CR>\\end{lemma}",
    \'que' : "\\begin{question}\<CR><+++>\<CR>\\end{question}",
    \'cor' : "\\begin{corollary}\<CR><+++>\<CR>\\end{corollary}",
    \'lst' : "\\begin{enumerate}[a)]\<CR>\\item <+++>\<CR>\\end{enumerate}",
    \'cd'  : "$$\<CR>\\begin{tikzcd}\<CR><+++>\<CR>\\end{tikzcd}\<CR>$$\<CR><++>",
    \
\'Section: Simple Aliases' : 'COMMENT',
    \'st'   : 'such that ',
    \'homo' : 'homomorphism ',
    \'iso'  : 'isomorphism ',
    \'iff'  : 'if and only if ',
    \'wlog' : 'without loss of generality ',
    \'Wlog' : 'Without loss of generality, ',
    \'siga' : '\(\sigma\)-algebra ',
    \'gset' : '\(G\)-set ',
    \
\'Section: Other Commands' : 'COMMENT',
    \'itm'   : '\item ',
    \'todo'  : '\textcolor{red}{TODO: <+++>} <++>',
    \'arrow' : '\arrow[ <+++> ] <++>',
    \'sect'  : '\section*{ <+++> }',
    \'qt'    : " ``<++>'' <++>",
    \'gtg'   : '\textcolor{purple}{ <+++> }',
\}

" }}}
" }}}
