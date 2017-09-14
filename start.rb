require 'yaml'
require 'psych'
require 'pp'
#Classes
class Commit
  attr_accessor :name, :message, :hash
  def initialize(name, message, hash)
    @name = name
    @message = message
    @hash = hash
  end
  def to_str
    "|#{@name} | #{@hash}| #{@message} |-|-|--|"
  end
end

#Methods
def update_local_repo()
  Dir.chdir($repo_path){
    puts %x[git pull]
  }
end

def get_tags(list_size = 5)
  viable_tags = Array.new
  viable_tags << "master"
  Dir.chdir($repo_path){
    all_tags = %x[git tag --sort=-creatordate]
    all_tags_changed = all_tags.split("\n")
    all_tags_changed.each do |item|
      if item.match(/release-\d+_\d+_\d+\SRC\d+/)
        viable_tags << item
      else
        # puts "not matching"
      end
    end

    i = 0
    output = Array.new
    list_size.to_i.times do
      output << viable_tags[i]
      i = i+1
    end
    return output
  }
end

def diff_tags(old_tag, new_tag)
  Dir.chdir($repo_path){
    names = %x[git log --pretty=format:%an%x09 #{old_tag}...#{new_tag}].split("\n")
    messages =  %x[git log --pretty=format:%s #{old_tag}...#{new_tag}].split("\n")
    hashs = %x[git log --pretty=format:%h%x09 #{old_tag}...#{new_tag}].split("\n")
    # --ancestry-path

    Dir.chdir($repo_path) {%x[git describe --contains "#{@hash}"]}

    names.zip(messages, hashs).map { |commits_stuff| Commit.new(commits_stuff[0].strip, commits_stuff[1].strip,commits_stuff[2].strip) }

  }
end

def build_table(crew_name, crew_commits)
  if crew_commits.length > 0
    puts "h3. :) {color:green} *"+ crew_name+ "* {color}"
    puts "||Committer Name||Hash||Commit Message||User Facing||Impact area||Explanation||"
    puts [crew_commits,("\n" * 2)]

    File.open("my_first_output.txt", 'a+') { |file| file.puts( "h3. :) {color:green} *"+ crew_name+ "* {color}")}
    File.open("my_first_output.txt", 'a+') { |file| file.puts(["||Committer Name||Hash||Commit Message||User Facing||Impact area||Explanation||"]) }
    File.open("my_first_output.txt", 'a+') { |file| file.puts([crew_commits,("\n" * 2)])}

  else
    puts ["{color:red}" + crew_name + " have not commited anything{color}", ("\n" * 1)]

    File.open("my_first_output.txt", 'a+') { |file| file.puts(["{color:red}" + crew_name + " have not commited anything{color}", ("\n" * 1)])}
  end
end

def error_check(low = 1, high = 5,text)
  print text
    puts ("\n" * 2)
  input1 = gets.strip
  while input1.to_i < low.to_i || input1.to_i >high.to_i do
    puts ("\n" * 1)
    puts "I'm afraid that your input of '" + input1 + "' is NOT a valid value, SUCKKKKEEERRRRRR!!! "
    puts ("\n" * 2)
    print text
    puts ("\n" * 2)
    input1 = gets.strip
  end
  return input1
end

#Main
#   Set repo path
$repo_path = '/Users/gullif01/workspace/tap-static'
$repo_path = Psych.load_file('repo_path.yml')[0].to_s

#   Update local repo
puts [("\n" * 2), "Just updating the local repo m8.",("\n" * 2)]
update_local_repo()
puts [("\n" * 2), "Done updating buddy, now..",("\n" * 2)]

#   wipe output
File.open("my_first_output.txt", 'w') { |file| file.puts(" ") }

#   initialise variable
total_list = Array.new
lovely_horse_commits = Array.new
my_chemical_hanson_commits = Array.new
space_chimp_commits = Array.new
honey_badger_commits = Array.new
pyro_commits = Array.new
broken_marrow_commits = Array.new
unknown_user_commits = Array.new
all_other_commits = Array.new

#   read in crew configs
lovely_horse = Psych.load_file('lovely_horse_config.yml')
broken_marrow = Psych.load_file('broken_marrow_config.yml')
my_chemical_hanson = Psych.load_file('my_chemical_hanson.yml')
space_chimp = Psych.load_file('space_chimp_config.yml')
pyro = Psych.load_file('pyro_config.yml')
honey_badger = Psych.load_file('honey_badger_config.yml')
unknown_user = Psych.load_file('unknown_user_config.yml')

#   Tag list size
list_size = error_check(2,230,"Please enter the number of Tags you want to choose between (2 - 230)")
puts ("\n" * 1)
i = 0
list_size.to_i.times do
  if i==0
  puts get_tags(list_size.to_i)[i].to_s + "\t \t \t Select this by pressing ---- " + (i + 1).to_s
  else
  puts get_tags(list_size.to_i)[i].to_s + "\t Select this by pressing ---- " + (i + 1).to_s
end
  i = i + 1
end

tags = get_tags(list_size.to_i)

#   Tag selection
puts ("\n" * 2)
input1 = error_check(1,list_size,"Please select the older tag you'd like to compare:")
puts [ ("\n" * 1), "You've entered '" + input1 + "' which selects the tag of: '"+ tags[(input1.to_i - 1)] + "'", ("\n" * 2)]
input2 = error_check(1,list_size,"Please select the newer tag you'd like to compare:")
puts [ ("\n" * 1), "You've entered '" + input2 + "' which selects the tag of: '"+ tags[(input2.to_i - 1)] + "'", ("\n" * 2)]

#   Share commits out between crews
diff_tags(tags[input1.to_i - 1],tags[(input2.to_i - 1)]).sort_by {|commit| commit.name}.each do |item|

  # Dir.chdir($repo_path){
  # puts     %x[git describe "#{(item.hash)}"]
  #   }


  if  (lovely_horse.include? item.name)
    lovely_horse_commits << item.to_str
  elsif  (space_chimp.include? item.name)
    space_chimp_commits << item.to_str
  elsif  (honey_badger.include? item.name)
    honey_badger_commits << item.to_str
  elsif  (pyro.include? item.name)
    pyro_commits << item.to_str
  elsif  (broken_marrow.include? item.name)
    broken_marrow_commits << item.to_str
  elsif  (my_chemical_hanson.include? item.name)
    my_chemical_hanson_commits << item.to_str
  elsif  (unknown_user.include? item.name)
    unknown_user_commits << item.to_str
  else
    all_other_commits << item.to_str
  end
end

#   Output to terminal and my_first_output.txt
File.open("my_first_output.txt", 'a+') { |file| file.puts(["*+If any issues found in regression please discuss with product owners (Pete/Andrew W/Celia) and Kiran.+*", ("\n" * 1)])}
File.open("my_first_output.txt", 'a+') { |file| file.puts(["h3. This is a comparison between '*" + tags[(input1.to_i - 1)] + "*' and '*" + tags[(input2.to_i - 1)] + "*'", ("\n" * 1)])}
File.open("my_first_output.txt", 'a+') { |file| file.puts(["h3. Check the version of the back end service(s) (mountains) here:  https://tap-dashboard.tools.bbc.co.uk/content/mountain-services", ("\n" * 1)])}


build_table("Lovely Horses", lovely_horse_commits)
build_table("Space Chimps", space_chimp_commits)
build_table("My Chemical Hanson", my_chemical_hanson_commits)
build_table("Honey Badgers", honey_badger_commits)
build_table("Pyros", pyro_commits)
build_table("Moss Piglets", broken_marrow_commits)
build_table("Other Devs", unknown_user_commits)
build_table("Unknowns", all_other_commits)

puts ["---------------------------------------------------------------", ("\n" * 1)]

File.open("my_first_output.txt", 'a+') { |file| file.puts(["---------------------------------------------------------------", ("\n" * 1)])}
