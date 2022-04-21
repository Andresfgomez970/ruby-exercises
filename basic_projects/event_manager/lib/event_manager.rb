require 'csv'
require 'google/apis/civicinfo_v2'
require './lib/utils' 
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]  
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def clean_homephone(homephone)
  homephone = homephone.gsub(/-|\(|\)|\.| /, '')

  if homephone.length < 10
    'wrong number'
  elsif homephone.length == 10
    homephone
  elsif homephone.length == 11
    if homephone[0] == '1'
      homephone[1..11]
    else
      'wrong number'
    end
  end

end

def clean_regdate(regdate)
  date = DateTime.strptime(regdate, '%Y/%d/%m %H:%M')
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

def create_thanks_htmls()
  file_name = "event_attendees.csv"
  contents = CSV.open(
    file_name, 
    headers: true,  
    header_converters: :symbol)
  
  template_letter = File.read_safe('form_letter.erb')
  erb_template = ERB.new template_letter
  
  contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    homephone = clean_homephone(row[:homephone])
    regdate = clean_regdate(row[:regdate])
  
    legislators = legislators_by_zipcode(zipcode)
  
    form_letter = erb_template.result(binding)
  
    save_thank_you_letter(id, form_letter)
  end
end


file_name = "event_attendees.csv"
contents = CSV.open(
  file_name, 
  headers: true,  
  header_converters: :symbol)

dates = contents.each.map {|row| clean_regdate(row[:regdate]) } 

hours = dates.map { |date| date.hour }.tally 
peak_hours = hours.sort_by{|k, v| v * -1}.transpose[0]
puts "Peak hours in order: #{peak_hours}"

days = dates.map {|date| date.wday}.tally
peak_days = days.sort_by{|k, v| v * -1}.transpose[0]
days = ["Sunday", "Monday", "Tuesday", "Wendsday", "Thursday", "Friday", "Saturday"]

puts "Peak days in order: #{peak_days.map { |day_i| days[day_i] } }"