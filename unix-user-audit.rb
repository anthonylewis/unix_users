#!/usr/bin/env ruby

require 'unix_user_list'

# Load and archive list of users from last run
prev_users = UnixUserList.new
prev_users.load 'logs/all-users-curr.txt'
prev_users.archive 'logs/all-users-curr.txt', 'logs'

# Get current list of users and save it
curr_users = UnixUserList.new
curr_users.update 'unix-servers.txt', 'audits'
curr_users.save 'logs/all-users-curr.txt'

# Generate time stamp for this run
time_stamp = Time.now.strftime('%Y%m%d-%H%M%S')

# Diff between curr and prev list is users added
users_added = curr_users - prev_users
users_added.save "logs/users-added-#{time_stamp}.txt"
 
# Diff between prev and curr list is users removed
users_removed = prev_users - curr_users
users_removed.save "logs/users-removed-#{time_stamp}.txt"

