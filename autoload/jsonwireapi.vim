scriptencoding utf-8

let g:jsonwireapi_webdriver_path = get(g:, 'jsonwireapi_webdriver_path', 'chromedriver')

function! jsonwireapi#new(...)
  let port = a:0 ? a:1 : 9515
  let proc = s:start(port)
  return extend({'proc': proc, 'port': port}, s:template)
endfunction

function! s:start(port)
  if type(a:port) != type(0)
    throw 'jsonwierapi: argument'
    return {}
  endif
  return vimproc#popen3(printf('%s --port=%d', tr(g:jsonwireapi_webdriver_path, '\', '/'), a:port))
endfunction

let s:template = {}

function! s:template.delete() dict
  " for id in s:webdriver_sessions(9513)
  "   call s:webdriver_delete(9513, id)
  " endfor
  try
    call self.proc.kill(9)
    echo 'deleted'
  catch /^Vim\%((\a\+)\)\=:E.*/
    throw 'jsonwierapi: delete webdriver'
  endtry
endfunction

if expand("%:p") == expand("<sfile>:p")
  let s:a = jsonwireapi#new()
  call s:a.delete()
endif

