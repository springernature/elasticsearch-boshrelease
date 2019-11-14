#!/bin/bash

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

## we only want to execute the errand job in one of the master nodes, 
## otherwise we might have problems due to concurrency
<% if @index == 0 %>

## this function is needed to be able to pass the index name as parameter to the 
## reindex API
generate_request_body()
{
  cat <<EOF
{
    "source": {
      "index": "$1"
    },
    "dest": {
      "index": ".backup.$1"
    }
}
EOF
}

## delete all backup indices
TEMP_FILE=$(mktemp)

curl $USER -X GET "<%= elasticsearch_url %>/_cat/indices/.backup.*?h=index" -H 'Content-Type: application/json' > $TEMP_FILE

while read index; do
  curl $USER -X DELETE "<%= elasticsearch_url %>/$index" -H 'Content-Type: application/json' 
done < $TEMP_FILE

## get all the special indices
curl $USER -X GET "<%= elasticsearch_url %>/_cat/indices/.*?h=index" -H 'Content-Type: application/json' > $TEMP_FILE

while read index; do
  curl $USER -X POST "<%= elasticsearch_url %>/_reindex?pretty" -H 'Content-Type: application/json' --data "$(generate_request_body $index)"
done < $TEMP_FILE

## rollover all the indices
indices=(logs-info logs-warn logs-error logs-unknown logs-debug)
for i in "${indices[@]}"
do
  curl $USER -X POST "<%= elasticsearch_url %>/$i/_rollover/" -H 'Content-Type: application/json' -d'
  {
    "conditions": {
      "max_docs":  1
    }
  }
  '
done

## change node left timeout
curl $USER -X PUT "<%= elasticsearch_url %>/_all/_settings" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index.unassigned.node_left.delayed_timeout": "120m"
  }
}
'
<% else %>
exit 0
<% end %>
