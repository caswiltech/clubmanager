// // Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function remove_fields(link) {
  $(link).prev().children().first().val("true");
  $(link).closest(".inputs").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}
