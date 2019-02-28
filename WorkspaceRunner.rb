#!/usr/bin/env ruby
#auth: ben helsley
#desc: ruby test thingy that helps the other test thingy


require "aws-sdk"
require "date"



class WorkspaceRunner

	attr_accessor :query_tag_key, :query_tag_value, :query_action, :query_region, :verbose_mode, :total_count, :total_running, :total_stopped, :total_actions

	def initialize(key,value,mode,region,verbose = false)
		@query_tag_key = key
		@query_tag_value = value
		@query_action = mode
		@query_region = region
		@verbose_mode = verbose
		@total_count = 0
		@total_running = 0
		@total_stopped = 0
		@total_actions = 0
	end

	def list

	end

	def start(instance_id="all")

	end

	def stop(instance_id="all")
		region_names = get_region_list		
		
		if verbose_mode
			puts "tagKey: #{query_tag_key}"
			puts "tagValue: #{query_tag_value}"
			puts "Region(s): #{region_names}"
		end
		
		region_names.each do |region_name|
			ec2 = Aws::EC2::Resource.new(region: rgn.name)
			instance_list = get_instance_list region_name, query_tag_key, query_tag_value
			puts "Region: #{rgn.name}" if verbose_mode
			
			if verbose_mode
				if instance_list.first != nil
					puts "  Instances:"
				else
					puts "  Instacnes:"
					puts "    --none--"
				end
			end
			
			instance_list.each do |instance|
				state = instance.state.name
				if state == "running"
					self.total_actions += 1
					instance.stop
					index = 0
					instance.wait_until_stopped do |w|
						w.delay = 2
						w.max_attempts = 100
						state = ec2.instance(instance.instance_id.to_s).state.name
						print_info query_action, instance.instance_id, state, "\r" if verbose_mode
						$stdout.flush
						index += 1
					end
					total_stopped += 1
				elsif state == "stopped"
					total_stopped += 1
				end
				state = ec2.instance(instance.instance_id.to_s).state.name
				self.total_count += 1
				print_info query_action, instance.instance_id, state, "\n" if verbose_mode
			end
		end
	end

	def renew(instance_id="all",days=8)
		days_extended = days
		fail 'date must be between 1 and 10' unless (1...10).include?(days_extended)
		new_expiration_date = (DateTime.now + days_extended).to_date

		if verbose_mode
			puts "tagKey: #{query_tag_key}"
			puts "tagValue: #{query_tag_value}"
			puts "Extension: #{days_extended}"
			puts "New Date: #{new_expiration_date}"
		end

		region_names = get_region_list
		puts "Region(s): #{region_names}" if verbose_mode
		region_names.each do |region_name|
			puts "Region: #{region_name}" if verbose_mode
			ec2 = Aws::EC2::Resource.new(region: region_name)
			ec2.instances(filters:[{ name: "tag:#{query_tag_key}", values: [ query_tag_value ] }]).each do |instance|
				ec2.create_tags(resources: [instance.instance_id.to_s], tags: [{key: "ExpirationDate", value: "#{new_expiration_date}"}])
				print_info query_action, instance.instance_id, instance.state.name, "| New Date: #{new_expiration_date}\n" if verbose_mode
				self.total_count += 1
				self.total_actions += 1
				self.total_running += 1 if instance.state.name == "running"
				self.total_stopped += 1 if instance.state.name == "stopped"
			end
		end
	end

	def print_run_stats()
		puts "<><><><><>| EC2 action.capitalize |<><><><><>"
		puts "Total Insaces: #{total_count}"
		puts "Total Running: #{total_running}"
		puts "Total Stopped: #{total_stopped}"
		puts "    Total #{query_action.capitalize}s: #{total_actions}"
	end


	private

	def print_info(mode, id, state, ending = "")
		print "    Action: #{mode} | ID: #{id} | State: #{state} #{ending}"
	end
		
	def get_instance_list(region, key, value)
		availible_regions = Aws.partition('aws').regions.map(&:name)
		if region == "all"
			region_names = availible_regions
		elsif availible_regions.include?(region)
			region_names = [region]
		else
			fail "InvalidRegion: #{region} -- Must specify a valid AWS region or \'all\' for all regions"
		end
		instance_list = region_names.each_with_object([]) do |region_name, arr|
			ec2 = Aws::EC2::Resource.new(region: region_name)
			arr << ec2.instances(filters:[{ name: "tag:#{key}", values: [ value ] }])
		end
	end

	def get_region_list
		availible_regions = Aws.partition('aws').regions.map(&:name)
		if query_region == "all"
			availible_regions
		elsif availible_regions.include?(query_region)
			[query_region]
		else
			fail "InvalidRegion: #{query_region} -- Must specify a valid AWS region or \'all\' for all regions"
		end
	end



end