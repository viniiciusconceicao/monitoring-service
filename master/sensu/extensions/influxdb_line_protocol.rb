#!/usr/bin/env ruby
require "sensu/extension"
module Sensu
	module Extension
		class InfluxDBLineProtocol < Mutator
			def name
				"influxdb_line_protocol"
			end
			def description
				"returns check output formatted for InfluxDB's line protocol"
			end
			def run(event)
				host = event[:client][:name]
				ip = event[:client][:address]
				metric = event[:check][:name]
				output = event[:check][:output]

				data = []
				output.split("\n").each do |result|
					m = result.split
					next unless m.count == 3
					key = m[0].split('.', 2)[1]
					key.gsub!('.', '_')
					value = m[1].to_f
					time = m[2].ljust(19, '0')
					data << "#{metric},host=#{host},ip=#{ip},metric=#{key} value=#{value} #{time}"
				end
				yield data.join("\n"), 0
			end
		end
	end
end
