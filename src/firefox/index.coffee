data    = require("sdk/self").data
pageMod = require('sdk/page-mod')
ss      = require("sdk/simple-storage")
note    = require("sdk/notifications").notify

notify = (msg) ->
  note {
    title: "codesy"
    text: msg
  }

auths =
  onAdd : []
  find : (domains,domain) ->
    domains.map((item) -> item.domain).indexOf(domain)
  add : (auth)->
    domains = ss.storage.domains ? []
    idx = auths.find(domains,auth.domain)
    domains.splice(idx, 1) if idx isnt -1
    domains.unshift(auth)
    ss.storage.domains = domains
    for  callback in auths.onAdd
      do (auth)->
        callback auth      
  get : ->
    domains = ss.storage.domains ? []
    domains[0] ?= {}

# github issue pages
pageMod.PageMod {
  include: /.*github.*/
  contentScriptWhen : "end"
  contentStyleFile : [
    './css/styles.css'
    './css/pure-min.css'
  ]
  contentScriptFile : [
    data.url('./js/jquery-2.0.3.min.js')
    data.url('./js/issue.js')
  ]
  onAttach: (worker)->
    emitDomain = (domain) ->
      worker.port.emit "domain", domain
    
    auths.onAdd.push emitDomain
    
    # event from issue asking for domain
    worker.port.on "getDomain", ->      
      emitDomain auths.get()

    worker.port.on "getLocal",(file)->
      worker.port.emit "replace", data.url('./img/'+file) 
}

# codesy home page
pageMod.PageMod {
  include : [
    /.*127.0.0.1:8443\//
    /.*codesy.io\//
  ]
  contentScriptFile : [
    data.url('./js/jquery-2.0.3.min.js')
    data.url('./js/home.js')
  ]
  onAttach: (worker) ->
    worker.port.on "newDomain", (domain)->
      auths.add domain
      worker.port.emit "domain", auths.get()
  
  }