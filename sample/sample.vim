" Navigate webdriver via vimscript
" https://code.google.com/p/selenium/wiki/JsonWireProtocol
scriptencoding utf-8

let s:webdriver_path = expand('chromedriver.exe', 1)
" let s:webdriver_path = expand('IEDriverServer.exe', 1)

function! s:webdriver_start(port)
  " execute printf('!start %s --port=%d', s:webdriver_path, a:port)
  return vimproc#popen3(printf('%s --port=%d', tr(s:webdriver_path, '\', '/'), a:port))
endfunction

function! s:webdriver_status(port)
  let response = webapi#http#get(printf('http://localhost:%d/status', a:port))
  echo 'STATUS:' eval(response.content)
endfunction

function! s:webdriver_create_session(port)
  let response = webapi#http#post(printf('http://localhost:%d/session', a:port)
        \ , webapi#json#encode({'desiredCapabilities': {}}))
  echo response
  let result = webapi#json#decode(response.content)
  echo result
  if result.status == 0
    return result.sessionId
  else
    return ''
  endif
endfunction

function! s:webdriver_sessions(port)
  let response = webapi#http#get(printf('http://localhost:%d/sessions', a:port))
  if empty(response.content)
    return []
  endif
  return map(webapi#json#decode(response.content).value, 'v:val.sessionId')
endfunction

function! s:webdriver_show_url(port, sessionId, url)
  let response = webapi#http#post(
        \   printf('http://localhost:%d/session/%s/url', a:port, a:sessionId)
        \ , webapi#json#encode({'url': a:url}))
  echo 'URL:' webapi#json#decode(response.content)
endfunction

function! s:webdriver_delete(port, sessionId)
  let response = webapi#http#post(
        \   printf('http://localhost:%d/session/%s', a:port, a:sessionId)
        \ , {}, {}, 'DELETE')
  echo 'DELETE:' webapi#json#decode(response.content)
endfunction

function! s:webdriver_find_by_id(port, sessionId, id)
  let response = webapi#http#post(
        \   printf('http://localhost:%d/session/%s/element', a:port, a:sessionId)
        \ , webapi#json#encode(
        \ { 'using': 'id'
        \ , 'value': a:id}))
  let elementId = webapi#json#decode(response.content).value.ELEMENT
  echo 'ELEMENT ID:' elementId type(elementId)
  return elementId
endfunction

function! s:webdriver_find_by_css(port, sessionId, selector)
  let response = webapi#http#post(
        \   printf('http://localhost:%d/session/%s/elements', a:port, a:sessionId)
        \ , webapi#json#encode(
        \ { 'using': 'css selector'
        \ , 'value': a:selector}))
  let elementId = webapi#json#decode(response.content).value
  echo 'ELEMENT ID:' elementId
  return map(elementId, 'v:val.ELEMENT')
endfunction

function! s:webdriver_click(port, sessionId, elementId)
  let response = webapi#http#post(
        \   printf('http://localhost:%d/session/%s/element/%s/click', a:port, a:sessionId, a:elementId), {})
  echo 'CLICK:' webapi#json#decode(response.content)
endfunction

let s:proc = s:webdriver_start(9513)
try
  let s:sessionId = s:webdriver_create_session(9513)

  call s:webdriver_show_url(9513, s:sessionId, 'http://apngoap99/kon/KONUser/home.aspx')

  let s:ids = s:webdriver_find_by_css(9513, s:sessionId, '#ctl00_hldContent_dlstEcocheck table tr:nth-child(1) td:nth-child(1)')
  " let s:ids = s:webdriver_find_by_id(9513, s:sessionId, 'ctl00_hldContent_dlstEcocheck_ctl00_chkEcoList')

  for s:id in s:ids
    call s:webdriver_click(9513, s:sessionId, s:id)
  endfor

  " let s:saveid = s:webdriver_find_by_id(9513, s:sessionId, 'ctl00_hldContent_btnSave')
  " call s:webdriver_click(9513, s:sessionId, s:saveid)
  "
  " sleep 3
 
  " call s:webdriver_status(9515)
finally
  for s:id in s:webdriver_sessions(9513)
    call s:webdriver_delete(9513, s:id)
  endfor
  unlet s:id
  echo 'finalize'
  call s:proc.kill(9)
endtry

