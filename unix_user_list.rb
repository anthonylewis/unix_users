
require 'net/ssh'

class UnixUserList
  attr_accessor :list

  def initialize(user_list = [])
    @list = user_list
  end

  def save(user_file)
    if @list.empty?
      puts "Warning, saving empty user list."
    end
    File.open(user_file, "w") do |file|
      file.write(@list.join("\n"))
    end
  rescue
    puts "Error saving data. #{$!}"
  end

  def load(user_file)
    File.open(user_file) do |file|
      @list = file.read.split("\n")
    end
  rescue
    puts "Error loading user data. #{$!}"
    @list = []
  end

  def archive(user_file, arch_path)
    time_stamp = File.mtime(user_file).strftime("%Y%m%d-%H%M%S")
    prev_file = "all-users-#{time_stamp}.txt"
    prev_file = File.join(arch_path, prev_file) unless arch_path.empty?
    File.rename(user_file, prev_file)
  rescue
    puts "Error archiving user data. #{$!}"
  end

  def update(server_file, user_name)
    File.foreach(server_file) do |server|
      # skip comments and blank lines
      if server !~ /^#.*$|^\s*$/
        server = server.chomp.downcase
        begin
          # open SSH connection using key from pageant
          Net::SSH.start(server, user_name) do |ssh|
            # call 'cat /etc/passwd' and wait for the result
            result = ssh.exec!("cat /etc/passwd")
            # add server name to each line and add to list
            result.each do |line|
              @list.push "#{server}:#{line.chomp}"
            end
          end
        rescue
          puts "Error connecting to #{server}. #{$!}"
        end
      end
    end
  rescue
    puts "Error updating user data. #{$!}"
  end

  def to_s
    if @list.empty?
      "None"
    else
      @list.join("\n")
    end
  end

  def -(other)
    UnixUserList.new(@list - other.list)
  end
end

