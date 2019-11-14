#!/bin/bash
<%
  elasticsearch_host = p("elasticsearch.host")
  if p("elasticsearch.prefer_bosh_link") then
      if_link("elasticsearch") { |elasticsearch_link| elasticsearch_host = elasticsearch_link.instances[0].address }
  end

  elasticsearch_url = p("elasticsearch.protocol") + '://' + p("elasticsearch.username") + ':' + p("elasticsearch.password") + '@' + elasticsearch_host + ':' + p("elasticsearch.port")
%>

# If a command fails, exit immediately
set -e

<% if p("elasticsearch.curl.authenticate") %>
USER="-u <%= p("elasticsearch.curl.username") %>:<%= p("elasticsearch.curl.password") %> " 
<% else %>
USER="" 
<% end %>

curl $USER -k -X PUT "<%= elasticsearch_url %>/_cluster/settings" -H 'Content-Type: application/json' --data-binary '<%=p('elasticsearch.dynamic.properties') %>'

<% if !p("elasticsearch.index.settings").empty? %>
curl $USER -k -X PUT "<%= elasticsearch_url %>/_all/_settings" -H 'Content-Type: application/json' --data-binary '<%=p('elasticsearch.index.settings') %>'
<% end %>
