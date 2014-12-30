#!/usr/bin/ruby
 
require 'net/http'
require 'net/smtp'
 
# Brian Wigginton
# http://www.bwigg.com/2008/10/ruby-script-to-check-site-availability/
# 10/7/2008
#
# Check's availabilty of a website. Needs to be run via a cron job.
# Example cron job line to be placed in crontab
#
# 0,15,30,45 * * * * username ~/scripts/check_uptime.rb
#
# This script uses a txt file to look for urls and email addresses.
# This text file needs to be in the following format
# -- lines with beginning with # signs will be ignored
# -- first thing should be the url
# -- then a space
# -- then email addresses seperated by commas, no white space.
# EXAMPLE
#       example.com admin@axample.com,bob@example.com
 
File.open("/home/user/scripts/sites.txt").each { |line|
	# get rid of CRLF
	line.chomp!
 
	next if(line[0..0] == '#' || line.empty?)
 
	url, emails = line.split(' ')
	emails = emails.split(",")
 
	# check if http:// was in the url if not add it in there
	url.insert(0, "http://") unless(url.match(/^http\:\/\//))
 
	# Get the HTTP_RESPONSE from the site we are checking
	res = Net::HTTP.get_response(URI.parse(url.to_s))
 
	# Check the response code and send an email if the code is bad
	unless(res.code =~ /2|3\d{2}/ ) then
		from = "admin@example.com"
		message = "From: admin@example.com\nSubject: #{url} Unavailable\n\n#{url} - #{res.code} - #{res.message}\nHTTP Version - #{res.http_version}\n\n"
		begin
			Net::SMTP.start('localhost',25 , 'example.com') do |smtp|
			smtp.send_message(message, from, emails)
		end
		rescue Exception => e
			print "Exception occured: " + e
		end
	end
}
