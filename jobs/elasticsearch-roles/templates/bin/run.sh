#!/bin/bash

set -e # If a command fails, exit immediately

<%
  elasticsearch_host = p("elasticsearch.host")
  if p("elasticsearch.prefer_bosh_link") then
      if_link("elasticsearch") { |elasticsearch_link| elasticsearch_host = elasticsearch_link.instances[0].address }
  end

  elasticsearch_url = p("elasticsearch.protocol") + '://' + p("elasticsearch.username") + ':' + p("elasticsearch.password") + '@' + elasticsearch_host + ':' + p("elasticsearch.port")
%>

<% if p("elasticsearch.curl.authenticate") %>
USER="-u <%= p("elasticsearch.curl.username") %>:<%= p("elasticsearch.curl.password") %> " 
<% else %>
USER="" 
<% end %>

<% if_p("elasticsearch.roles.anonymous.name") do |name| %>
    curl $USER -vs -X PUT "<%= elasticsearch_url %>/_security/role/<%= name %>" \
      -H "Content-Type: application/json"  \
      --data-binary '<%= p("elasticsearch.roles.anonymous.permissions") %>'
<% end %>

<% if_p("elasticsearch.roles.kibana.name") do |name| %>
    curl $USER -vs -X PUT "<%= elasticsearch_url %>/_security/role/<%= name %>" \
      -H "Content-Type: application/json"  \
      --data-binary '<%= p("elasticsearch.roles.kibana.permissions") %>'
<% end %>

