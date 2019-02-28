#!/usr/bin/env ruby
#auth: ben helsley
#desc: ruby test thingy

require "aws-sdk"
require "thor"
require "date"
require "./WorkspaceRunner"


class Workflow < Thor

	version_number = "0.1.0"

	desc 'version', "prints the version"
	def version
		puts "Workflow -- Version: #{version_number}"
	end

	desc 'list', "Lists EC2 resources"
	option :all, type: 'boolean'
	option :region, type: 'string', aliases: '-r', desc: 'Specify the AWS region to list resources in'
	option :key, type: 'string', aliases: '-k', desc: 'Specify the EC2 tag key to filter by', default: 'Owner'
	option :value, type: 'string', aliases: '-v', desc: 'Specify the EC2 tag value to filter by', default: 'ben.helsley'
	option :verbose, type: 'boolean', aliases: '-V', desc: 'verbose mode'
	def list
		query_tag_key = options[:key]
		query_tag_value = options[:value]
		verbose_mode = options[:verbose]
		work_mode = "list"
		total_count = 0
		total_running = 0
		total_stopped = 0

		Aws.partition('aws').regions.each do |rgn|
		
			ec2 = Aws::EC2::Resource.new(region: rgn.name)
			instance_list = ec2.instances(filters:[{ name: "tag:#{query_tag_key}", values: [ query_tag_value ] }])
			
			puts "Region: #{rgn.name}" if verbose_mode

			if verbose_mode
				puts "  Instances:"
				puts "    --none--" if instance_list.first == nil
			end

			instance_list.each do |instance|
				state = instance.state.name
				total_running+=1 if state=="running"
				total_stopped+=1 if state=="stopped"
				total_count+=1
				printInfo work_mode, instance.instance_id, state, "  " if verbose_mode
			end
		end

		puts "<><><><><>| EC2 List |<><><><><>" if verbose_mode
		puts "Total Insaces: #{total_count}"
		puts "Total Running: #{total_running}"
		puts "Total Stopped: #{total_stopped}"

	end

	desc 'start', "Start stopped instances"
	def start

		query_tag_key = "Owner"
		query_tag_value = "ben.helsley"
		work_mode = "start"
		verbose_mode = true
		total_count = 0
		total_running = 0
		total_stopped = 0
		total_starts = 0

		region_list = Aws.partition('aws').regions

		region_list.each do |rgn|
			
			ec2 = Aws::EC2::Resource.new(region: rgn.name)
			instance_list = ec2.instances(filters:[{ name: "tag:#{query_tag_key}", values: [ query_tag_value ] }])
			
			puts "Region: #{rgn.name}" if verbose_mode

			if verbose_mode
				puts "  Instances:"
				puts "    --none--" if instance_list.first == nil
			end

			instance_list.each do |instance|
				
				state = instance.state.name
				printInfo work_mode, instance.instance_id, state, " \r" if verbose_mode
				
				if state=="stopped"
					total_starts+=1
					instance.start
					#instance.wait_until_running
					dots=["-","\\","|","/","-","\\","|","/"]
					index=0
					instance.wait_until_running do |w|
						w.delay = 5
						w.max_attempts = 100
						state=ec2.instance(instance.instance_id.to_s).state.name
						started=true if state == "running"
						printInfo work_mode, instance.instance_id, state, " #{dots[index%index.size]}\r" if verbose_mode
						$stdout.flush
						index+=1
					end
					total_running+=1
				elsif state=="running"
					total_running+=1
				end

				state=ec2.instance(instance.instance_id.to_s).state.name
				total_count+=1
				printInfo work_mode, instance.instance_id, state, "  \n" if verbose_mode

			end
		end

		puts "<><><><><>| EC2 Start |<><><><><>" if verbose_mode
		puts "Total Insaces: #{total_count}"
		puts "Total Running: #{total_running}"
		puts "    Total Starts: #{total_starts}"
		puts "Total Stopped: #{total_stopped}"

	end



	desc 'stop', "Stop running instances"
	option :all, type: 'boolean'
	option :region, type: 'string', aliases: '-r', desc: 'Specify the AWS region to list resources in, specify \'all\' for all regions', required: true
	option :key, type: 'string', aliases: '-k', desc: 'Specify the EC2 tag key to filter by', default: 'Owner'
	option :value, type: 'string', aliases: '-v', desc: 'Specify the EC2 tag value to filter by', default: 'ben.helsley'
	option :verbose, type: 'boolean', aliases: '-V', desc: 'verbose mode'
	def stop
		wsr = WorkspaceRunner.new(options[:key],options[:value],"renew",options[:region],options[:verbose])
		wsr.stop
		wsr.print_run_stats
	end

	desc 'start', "Start stopped instances"
	option :all, type: 'boolean'
	option :region, type: 'string', aliases: '-r', desc: 'Specify the AWS region to list resources in, specify \'all\' for all regions', required: true
	option :key, type: 'string', aliases: '-k', desc: 'Specify the EC2 tag key to filter by', default: 'Owner'
	option :value, type: 'string', aliases: '-v', desc: 'Specify the EC2 tag value to filter by', default: 'ben.helsley'
	option :days, type: 'numeric', aliases: '-d', desc: 'Specify the number of days to extend expiration date by, must be between 1 and 10', default: 8
	option :verbose, type: 'boolean', aliases: '-V', desc: 'verbose mode'
	def renew
		wsr = WorkspaceRunner.new(options[:key],options[:value],"renew",options[:region],options[:verbose])
		wsr.renew "all", options[:days]
		wsr.print_run_stats
	end
end

Workflow.start(ARGV)
