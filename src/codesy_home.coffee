# replace the install instructions with a check mark

if $("#installed").length > 0
  $("#install-step").hide()
  $("#installed").show()

console.time "codesy: check token"
if $("#api_token_pass").length > 0
  console.log "codesy: found token"
  chrome.storage.local.set auth_token: $("#api_token_pass").val()
console.timeEnd "codesy: check token"  
