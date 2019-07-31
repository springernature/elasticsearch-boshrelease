#!/bin/bash

set -e # If a command fails, exit immediately

<%
  elasticsearch_host = p("elasticsearch.host")
  if p("elasticsearch.prefer_bosh_link") then
      if_link("elasticsearch") { |elasticsearch_link| elasticsearch_host = elasticsearch_link.instances[0].address }
  end

  elasticsearch_url = p("elasticsearch.protocol") + '://' + p("elasticsearch.username") + ':' + p("elasticsearch.password") + '@' + elasticsearch_host + ':' + p("elasticsearch.port")
%>

<% if_p("elasticsearch.users.admin.password") do |password| %>
    curl -vs -X PUT "<%= elasticsearch_url %>/_security/user/admin" \
      -H "Content-Type: application/json"  \
      --data-binary '{"password": "<%= p("elasticsearch.users.admin.password") %>",
                      "roles": [ "<%= p("elasticsearch.users.admin.role") %>" ]
                     }'
<% end %>

<% if_p("elasticsearch.users.read_only_kibana.password") do |password| %>
    curl -vs -X PUT "<%= elasticsearch_url %>/_security/user/read_only_kibana" \
      -H "Content-Type: application/json"  \
      --data-binary '{"password": "<%= p("elasticsearch.users.read_only_kibana.password") %>",
                      "roles": [ "kibana_system" ]
                     }'
<% end %>

<% if_p("elasticsearch.users.curator.password") do |password| %>
    curl -vs -X PUT "<%= elasticsearch_url %>/_security/user/curator" \
      -H "Content-Type: application/json"  \
      --data-binary '{"password": "<%= p("elasticsearch.users.curator.password") %>",
                      "roles": [ "<%= p("elasticsearch.users.curator.role") %>" ]
                     }'
<% end %>

<% if_p("elasticsearch.users.cerebro.password") do |password| %>
    curl -vs -X PUT "<%= elasticsearch_url %>/_security/user/cerebro" \
      -H "Content-Type: application/json"  \
      --data-binary '{"password": "<%= p("elasticsearch.users.cerebro.password") %>",
                      "roles": [ "<%= p("elasticsearch.users.cerebro.role") %>" ]
                     }'
<% end %>

<% if_p("elasticsearch.users.logstash.password") do |password| %>
    curl -vs -X PUT "<%= elasticsearch_url %>/_security/user/logstash" \
      -H "Content-Type: application/json"  \
      --data-binary '{"password": "<%= p("elasticsearch.users.logstash.password") %>",
                      "roles": [ "<%= p("elasticsearch.users.logstash.role") %>" ]
                     }'
<% end %>