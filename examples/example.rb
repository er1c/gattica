require '../lib/gattica'

# authenticate with the API
ga = Gattica.new('activecom2@gmail.com','Active123')

# get the list of accounts you have access to with that username and password
accounts = ga.accounts

# for this example we just use the first account's profile_id, but you'll probably want to look
# at this list and choose the profile_id of the account you want (the web_property_id is the
# property you're most used to seeing in GA, looks like UA123456-1)
ga.profile_id = accounts.first.profile_id

# now get the number of page views by browser for Janurary 2009
# note that as of right now, Gattica does not support filtering
data = ga.get({ :start_date => '2009-01-01', 
                :end_date => '2009-01-31',
                :dimensions => ['browser'],
                :metrics => ['pageviews'],
                :sort => ['-pageviews'] })

# write the data out as CSV
puts data.to_csv(:short)
