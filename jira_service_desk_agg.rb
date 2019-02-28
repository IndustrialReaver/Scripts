#!/usr/bin/env ruby

# This simple Ruby script uses the jira REST API to query jira service desk for issues
# It uses basic auth, and is currently configured to use a username/password combo of 'test:test'
# To connect to a non-local jira, simple chagne the base_url variable to the jira servers url and
# chenge the username/password combo to be one that has permission to access the jira server.

require 'open-uri'
require 'json'

def out_write(content)
	puts content
	File.open("./jira_sd_data_tmp.json", 'a') do |f|
		f.write(content)
	end
end


# This URL should point to the root jira domain
base_url = "http://localhost:9001"

out_write "{\"jiradata\": ["
service_desks = open("#{base_url}/rest/servicedeskapi/servicedesk?start=0&limit=999", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
# Change the json to a ruby hash so we can easily access the service desk id and key
service_desks = JSON.parse(service_desks)
service_desks["values"].each do |service_desk|
  sd_id = service_desk["id"]
  sd_key = service_desk["projectKey"]
  issues = open("#{base_url}/rest/servicedeskapi/servicedesk/#{sd_id}/queue/1/issue?start=0&limit=999", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
  # Convert the issue to a ruby hash so we can easily add the service desk key
  issues = JSON.parse(issues)
  issues["values"].each do |issue|
    issue["projectKey"] = sd_key
    out_write "#{issue.to_json},\n"
  end
  #out_write issues.to_json
end
out_write "{\"empty\":\"\"}]}"

# # This URL should point to the root jira domain
# base_url = "http://localhost:9001"

# service_desks = open("#{base_url}/rest/servicedeskapi/servicedesk", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
# # Change the json to a ruby hash so we can easily access the service desk id and key
# service_desks = JSON.parse(service_desks)
# service_desks["values"].each do |service_desk|
#   sd_id = service_desk["id"]
#   sd_key = service_desk["projectKey"]
#   issues = open("#{base_url}/rest/servicedeskapi/servicedesk/#{sd_id}/queue/1/issue?start=0&limit=999", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
#   # Convert the issue to a ruby hash so we can easily add the service desk key
#   issues = JSON.parse(issues)
#   issues["values"].each do |issue|
#     issue["projectKey"] = sd_key
#   end
#   out_write issues.to_json
# end


# Bad Code Below, Outlines a better solution but non-functional, Please Ignore

# def out_write(content)
# 	puts content
# 	File.open("./jira_sd_data_tmp.json", 'a') do |f|
# 		f.write(content)
# 	end
# end

# out_write "{\"jiradata\":[\n"
# service_desks = open("#{base_url}/rest/servicedeskapi/servicedesk", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
# service_desks = JSON.parse(service_desks)
# service_desks["type"] = "sds"
# service_desks = service_desks.to_json
# out_write service_desks
# out_write ","
# service_desks = JSON.parse(service_desks, object_class: OpenStruct)
# service_desks.values.each do |service_desk|
#   sd_id = service_desk.id
#   queues = open("#{base_url}/rest/servicedeskapi/servicedesk/#{sd_id}/queue", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
#   queues = JSON.parse(queues)
#   queues["type"] = "sd#{sd_id}qs"
#   queues = queues.to_json
#   out_write queues
#   out_write ","
#   queues = JSON.parse(queues, object_class: OpenStruct)
#   queues.values.each do |queue|
#     q_id = queue.id
#     issues = open("#{base_url}/rest/servicedeskapi/servicedesk/#{sd_id}/queue/#{q_id}/issue", "Content-Type" => "application/json", "X-ExperimentalApi" => "true", :http_basic_authentication => ['test', 'test']).read
#     issues = JSON.parse(issues)
#     issues["type"] = "sd#{sd_id}q#{q_id}"
#     issues = issues.to_json
#     out_write issues
#     out_write ","
#   end
# end
# out_write "{\"empty\":\"\"}]}"

