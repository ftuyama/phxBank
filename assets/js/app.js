// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import "bootstrap"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

function validateForm() {
  var url = $("input[name=api]").val();
  var method = $("input[name=method]:checked").val();
  var data = $("textarea[name=json]").val();
  var debug = $("input[name=debug]").is(":checked");

  url = url.replace(/\/api\//, "");
  data = (data === "")? {} : JSON.parse(data);
  data["debug"] = debug;
 
  if(!url || !method) {
    alert("Fill the HTTP url/method");
    return undefined;
  } else {
    return {"url": "api/" + url, "type": method, "data": data};
  }
}

$("form").on("submit", function(e) {
  e.preventDefault();
  var form = validateForm();

  if (form) {
    $.ajax({
      type: form["type"],
      url:  form["url"],
      data: form["data"], 
      success: function(response) {
        $("#response").html("<p>Your amazing response:</p><pre>" + syntaxHighlight(response) + "</pre>");
        $("#error").html("");
      },
      error: function(request) {
        $("#response").html("");
        $("#error").html("<p>We had some problem... :</p>" + request.responseText);
      }
    });
  }
});

/* Source https://stackoverflow.com/questions/4810841/how-can-i-pretty-print-json-using-javascript */
function syntaxHighlight(json) {
  if (typeof json != 'string') {
    json = JSON.stringify(json, undefined, 2);
  }
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
    var cls = 'number';
    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
          cls = 'key';
      } else {
          cls = 'string';
      }
    } else if (/true|false/.test(match)) {
      cls = 'boolean';
    } else if (/null/.test(match)) {
      cls = 'null';
    }
    return '<span class="' + cls + '">' + match + '</span>';
  });
}
