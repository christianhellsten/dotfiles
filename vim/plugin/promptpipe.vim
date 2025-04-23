let s:promptpipe_has_yq = -1
let g:promptpipe_cmd = get(g:, 'promptpipe_cmd', 'Prompt')
let g:promptpipe_pipecmd = get(g:, 'promptpipe_pipecmd', '')

function! s:CheckYq()
  if s:promptpipe_has_yq == -1
    let s:promptpipe_has_yq = has('win32') ? executable('yq.exe') : system('which yq') != ''
  endif
  return s:promptpipe_has_yq
endfunction

function! s:ReadPromptTemplate(name)
  let template_paths = [
        \ expand('~/.promptpipe/prompts/' . a:name . '.yml'),
        \ '.promptpipe/prompts/' . a:name . '.yml',
        \ expand('~/.promptpipe/prompts/' . a:name . '.yaml'),
        \ '.promptpipe/prompts/' . a:name . '.yaml'
        \ ]
  for path in template_paths
    if filereadable(path)
      let path = has('win32') ? substitute(path, '/', '\', 'g') : path
      if !s:CheckYq()
        return join(readfile(path), "\n")
      endif
      let template = system('yq eval .template ' . shellescape(path))
      if v:shell_error == 0
        return substitute(template, '\n$', '', '')
      endif
    endif
  endfor
  return ''
endfunction

function! s:GetSystemPrompt()
  let system_prompt_paths = [
        \ expand('~/.promptpipe/PROMPTPIPE.md'),
        \ '.promptpipe/PROMPTPIPE.md'
        \ ]
  for path in system_prompt_paths
    if filereadable(path)
      return join(readfile(path), "\n")
    endif
  endfor
  return ''
endfunction

function! s:GetProjectPrompt()
  let project_prompt_path = './PROMPTPIPE.md'
  if filereadable(project_prompt_path)
    return join(readfile(project_prompt_path), "\n")
  endif
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

function! s:EnsureLogDir()
  let log_dir = '.promptpipe/logs'
  if !isdirectory(log_dir)
    call mkdir(log_dir, 'p')
  endif
  return log_dir
endfunction

function! s:RunPrompt(prompt)
  let template = s:ReadPromptTemplate(a:prompt)
  let final_statusline = "Prompt '" . a:prompt . "'"
  let final_prompt = empty(template) ? a:prompt : template

  " Get system and project prompts
  let system_prompt = s:GetSystemPrompt()
  let project_prompt = s:GetProjectPrompt()

  " Build the complete prompt with system and project prompt prepended
  let complete_prompt = ''
  if !empty(system_prompt)
    let complete_prompt .= system_prompt . "\n\n"
    let final_statusline .= ", ~/.promptpipe/PROMPTPIPE.md"
  endif
  if !empty(project_prompt)
    let complete_prompt .= project_prompt . "\n\n"
    let final_statusline .= ", ./PROMPTPIPE.md"
  endif
  let complete_prompt .= final_prompt

  " Append buffer XML
  let final_content = complete_prompt . "\n\n" . s:GetBufferXML()

  " Set to clipboard
  let @+ = final_content

  " Check if we should pipe to a command
  if !empty(g:promptpipe_pipecmd)
    " Create timestamp for log file
    let timestamp = strftime('%Y%m%d_%H%M%S')

    " Ensure log directory exists
    let log_dir = s:EnsureLogDir()
    let log_file = log_dir . '/' . timestamp . '.prompt'

    " Write prompt to log file
    call writefile(split(final_content, "\n"), log_file)

    " Execute the pipe command and capture output
    let cmd = ''
    if has('win32')
      " Use type command on Windows (equivalent to cat)
      let cmd = 'type ' . shellescape(log_file) . ' | ' . g:promptpipe_pipecmd
    else
      " Use cat on Unix-like systems
      let cmd = 'cat ' . shellescape(log_file) . ' | ' . g:promptpipe_pipecmd
    endif
    let output = system(cmd)

    " Create a new buffer with the output
    execute 'new'
    call setline(1, split(output, '\n'))
    setlocal buftype=nofile
    setlocal bufhidden=hide
    execute 'file PromptPipe_' . timestamp . '_output'

    let final_statusline .= " | Executed with: " . g:promptpipe_pipecmd
  endif

  " Update statusline
  let &statusline = escape(final_statusline . " copied to clipboard", ' %')
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

execute 'command! -nargs=+ -complete=customlist,<SID>GetPromptFiles ' . g:promptpipe_cmd . ' call <SID>RunPrompt(<q-args>)'

" Run on exit insert mode
" augroup PromptPipe
"   autocmd!
"   autocmd InsertLeave * if getline('.') =~? '\v^/' . g:promptpipe_cmd . '\s+' | execute g:promptpipe_cmd . ' ' . substitute(getline('.'), '\v^/' . g:promptpipe_cmd . '\s+', '', '') | endif
" augroup END

" leader+p start prompt completion
nnoremap <leader>p :<C-u>Prompt<space>
