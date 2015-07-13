scriptencoding utf-8

let g:jsonwireapi_webdriver_path = get(g:, 'jsonwireapi_webdriver_path', 'chromedriver')
let g:jsonwireapi_webdriver_host = get(g:, 'jsonwireapi_webdriver_host', 'localhost')
let g:jsonwireapi_webdriver_port = get(g:, 'jsonwireapi_webdriver_port', 9515)

function! jsonwireapi#new()
  let _ = extend({'proc': s:proc(), 'base_address': printf('http://%s:%d', g:jsonwireapi_webdriver_host, g:jsonwireapi_webdriver_port)}, s:template)
  lockvar _.proc _.base_address
  return _
endfunction

function! s:proc()
  return vimproc#popen3(printf('%s --port=%d', tr(g:jsonwireapi_webdriver_path, '\', '/'), g:jsonwireapi_webdriver_port))
endfunction

let s:template = {}

function! s:template.status()
  let response = webapi#http#get(self.base_address . '/status')
  if response.status == '200' && response.message = 'OK'
    return eval(response.content)
  endif
endfunction

function! s:template.session()
  let response = webapi#http#post(self.base_address . '/session', webapi#json#encode({'desiredCapabilities': {}}))
  if response.status == '200' && response.message = 'OK'
    let result = webapi#json#decode(response.content)
  endif
endfunction

function! s:template.sessions()
  let response = webapi#http#get(self.base_address . '/sessions')
  if response.status == '200' && response.message = 'OK'
    return eval(response.content)
  endif
endfunction

function! s:template.delete()
  " for id in s:webdriver_sessions(9513)
  "   call s:webdriver_delete(9513, id)
  " endfor
  try
    unlockvar self.proc
    call self.proc.kill(9)
  catch /^Vim\%((\a\+)\)\=:E.*/
    throw 'jsonwierapi: delete webdriver'
  endtry
endfunction

let s:template_session = {}

function! s:template_session.new()
  return 'empty id'
endfunction

if expand("%:p") == expand("<sfile>:p")
  let s:a = jsonwireapi#new()
  echo s:a.status()
  call s:a.delete()
endif

