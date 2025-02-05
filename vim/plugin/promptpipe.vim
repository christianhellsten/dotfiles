let s:promptpipe_has_yq = -1
let g:promptpipe_cmd = get(g:, 'promptpipe_cmd', 'Prompt')

function! s:CheckYq()
  if s:promptpipe_has_yq == -1
    let s:promptpipe_has_yq = has('win32') ? executable('yq.exe') : system('which yq') != ''
  endif
  return s:promptpipe_has_yq
endfunction

function! s:ReadPromptTemplate(name)
  if !s:CheckYq()
    return ''
  endif
  let template_paths = [
        \ expand('~/.promptpipe/prompts/' . a:name . '.yml'),
        \ '.promptpipe/prompts/' . a:name . '.yml',
        \ expand('~/.promptpipe/prompts/' . a:name . '.yaml'),
        \ '.promptpipe/prompts/' . a:name . '.yaml'
        \ ]
  for path in template_paths
    if filereadable(path)
      let path = has('win32') ? substitute(path, '/', '\', 'g') : path
      let template = system('yq eval .template ' . shellescape(path))
      if v:shell_error == 0
        return substitute(template, '\n$', '', '')
      endif
    endif
  endfor
  return ''
endfunction

function! s:GetBufferXML()
  let xml = []
  for buf in getbufinfo({'buflisted': 1})
    let name = buf.name
    let path = empty(name) ? '[Buffer ' . buf.bufnr . ']' : name
    let buftype = getbufvar(buf.bufnr, '&buftype')
    let is_file = !empty(name) && filereadable(name)
    
    if (empty(name) && empty(buftype)) || is_file
      call add(xml, '<file path="' . path . '">')
      call extend(xml, getbufline(buf.bufnr, 1, '$'))
      call add(xml, '</file>')
    endif
  endfor
  return join(xml, "\n")
endfunction

function! s:CheckAIPrompt(prompt)
  let template = s:ReadPromptTemplate(a:prompt)
  let final_prompt = empty(template) ? a:prompt : template
  let @+ = final_prompt . "\n\n" . s:GetBufferXML()
  let &statusline = escape(final_prompt, ' %')
endfunction

function! s:GetPromptFiles(ArgLead, CmdLine, CursorPos)
  let prompt_dirs = [
        \ expand('~/.promptpipe/prompts/'),
        \ '.promptpipe/prompts/'
        \ ]
  let matches = []
  for dir in prompt_dirs
    if isdirectory(dir)
      let files = globpath(dir, '**/*.y{a,}ml', 0, 1)
      let files = map(files, { _, f -> substitute(f, dir, '', '') })
      let files = map(files, { _, f -> substitute(f, '\.\(yaml\|yml\)$', '', '') })
      let matches += filter(files, { _, f -> f =~ '^' . a:ArgLead })
    endif
  endfor
  return matches
endfunction

execute 'command! -nargs=+ -complete=customlist,<SID>GetPromptFiles ' . g:promptpipe_cmd . ' call <SID>CheckAIPrompt(<q-args>)'

augroup AIPrompt
  autocmd!
  autocmd InsertLeave * if getline('.') =~? '\v^/' . g:promptpipe_cmd . '\s+' | execute g:promptpipe_cmd . ' ' . substitute(getline('.'), '\v^/' . g:promptpipe_cmd . '\s+', '', '') | endif
augroup END
