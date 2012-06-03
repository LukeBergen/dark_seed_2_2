if (ARGV.size != 1)
  puts "please specify filename to load marshal data from.  That is all."
  exit
end

file = ARGV[0]

marsh = Marshal::load(File.open(file, "r") {|f| f.read})

if (marsh.is_a?(Array))
  if (marsh.first.is_a?(Array))
    marsh.each {|m| puts m.join(",")}
  else
    puts marsh.join(",")
  end
else
  puts marsh
end
