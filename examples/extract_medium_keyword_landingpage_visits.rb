require 'rubygems'
require 'gattica'
require 'fastercsv'

ga_profile = "" #Enter your Profile Here
start_date = Date.new(2009, 4, 1)
end_date = Date.new(2009, 4, 3)
file_path = "data" # Directory Needs to exist

puts "Google Username: "
u = gets.chomp
raise "bad username" unless !u.empty?
puts "Google Password: "
system "stty -echo"
pw = gets.chomp
system "stty echo"
raise "bad password" unless !pw.empty?


class ExtractKeywords
  def initialize(email,password)
    @gs = Gattica.new({:email => email, :password => password})
  end

  def get_accounts
    results = []
    @gs.accounts.each{|account|
      profile = {}
      profile[:site_title] = account.title
      profile[:profile_id] = account.profile_id ## this is the id required for requests to the API
      profile[:account_name] = account.account_name
      profile[:account_id] = account.account_id
      profile[:web_property_id] = account.web_property_id
      results << profile
    }
    return results
  end

  def connect_profile(profile)
    @gs.profile_id = profile[:profile_id]
  end

  def connect_profile_id(profile_id)
    @gs.profile_id = profile_id
  end

  def get_keywords(start_date = nil, end_date = Date.today)
    results = []
    csv_data = @gs.get({
        :start_date => (start_date || (end_date - 365)).to_s,
        :end_date => end_date.to_s,
        :dimensions => ["medium", "keyword", "landingPagePath"],
        :metrics => "entrances",
        :sort => "-entrances",
        :page => true}).to_csv(:long)

    return FasterCSV.parse(csv_data, :headers => true)
  end

end




gs = ExtractKeywords.new(u, pw)
gs.connect_profile_id(ga_profile)

(start_date .. end_date).each { |date|
  file = "#{file_path}/medium_keyword_landingpage_visits_#{date.strftime('%Y-%m-%d')}.csv"
  next if File::exists?( file )

  FasterCSV.open(file, "w") do |csv|
    csv << ["medium", "keyword", "landingPagePath", "entrances"]
    keywords = gs.get_keywords(date, date)
    keywords.each{|row|
      csv << [row["medium"], row["keyword"], row["landingPagePath"], row["entrances"]]
    }

  end
}
