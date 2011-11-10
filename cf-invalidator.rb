#!/usr/bin/env ruby

puts " * Please install the fog gem\n $ gem install fog" and exit if !defined?("Fog") == 'constant' && Fog.class == Module
require 'rubygems'
require 'optparse'
require 'fog'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: cf-invalidator.rb -a ACCESS_KEY_ID -s SECRET_ACCESS_KEY -i DISTRIBUTION_ID [PATH1 PATH2]"

  opt.on('-i','--distribution_id DISTRIBUTION_ID', '') do |distribution_id|
    options[:distribution_id] = distribution_id
  end

  opt.on('-a','--access_key_id ACCESS_KEY_ID', '') do |access_key_id|
    options[:access_key_id] = access_key_id
  end

  opt.on('-s','--secret_access_key SECRET_ACCESS_KEY', '') do |secret_access_key|
    options[:secret_access_key] = secret_access_key
  end
end

opt_parser.parse!
options[:paths] = ARGV

class CloudFrontInvalidator

  def initialize(arguments)
    @options = arguments
  end

  def connection
    @connection ||= Fog::CDN.new(
      :provider => 'AWS',
      :aws_access_key_id => @options[:access_key_id],
      :aws_secret_access_key => @options[:secret_access_key]
    )
  end

  def has_paths?
    @options[:paths].any?
  end

  def has_distribution_id?
    @options[:distribution_id]
  end

  def invalidate_paths
    connection.get_distribution(@options[:distribution_id])
    puts "== Invalidating\n#{@options[:paths].join("\n")}"
    connection.post_invalidation(@options[:distribution_id], @options[:paths]).tap do |response|
      puts " * InvalidationId: #{response.body['Id']}\n"
    end
  end

  def list_invalidations
    connection.get_invalidation_list(@options[:distribution_id]).tap do |response|
      if response.body['InvalidationSummary'].any?
        puts "== Invalidation list"
        response.body['InvalidationSummary'].each do |invalidation|
          puts "#{invalidation['Id']} - #{invalidation['Status']}"
        end
      end
    end
  end

  def self.perform_with(arguments)
    CloudFrontInvalidator.new(arguments).tap do |invalidator|
      invalidator.invalidate_paths if invalidator.has_distribution_id? and invalidator.has_paths?
      invalidator.list_invalidations if invalidator.has_distribution_id?
    end
  end

end

CloudFrontInvalidator.perform_with options
