require 'mysql2'

def rename(name)
  name.gsub(/([Tt]wp)/, 'Township').gsub(/([Hh]wy)/, 'Highway')
end

def clean_slashes(name)
  chunks = name.split('/')
  return chunks.first.downcase if chunks.size == 1

  result = "#{chunks.last} #{chunks.first.downcase}"
  result << " and #{chunks[1].downcase}" if chunks.size > 2 && !chunks[1].empty?
  result
end

def clean_commas(name)
  chunks = name.split(',')
  result = "#{chunks[0].rstrip}"
  result << " (#{chunks[1].lstrip.split.map(&:capitalize).join(' ')})" if chunks[1]
  result
end

def clean_duplicates(name)
  name.split.uniq(&:capitalize).join(' ')
end

def clean_dots(name)
  name.gsub('.', '')
end

client = Mysql2::Client.new(host: '', username: '', password: '', database: '')
results = client.query("SELECT * FROM hle_dev_test_sergey_magas;")
results.each do |row|
  clean_name = row['candidate_office_name']
  clean_name = rename(clean_name)
  clean_name = clean_dots(clean_name)
  clean_name = clean_slashes(clean_name) unless clean_name.split('/').size.zero?
  clean_name = clean_duplicates(clean_name)
  clean_name = clean_commas(clean_name) unless clean_name.split(',').size.zero?
  sentence = "The candidate is running for the #{clean_name} office."
  client.query("UPDATE hle_dev_test_sergey_magas SET clean_name = \"#{clean_name}\", sentence = \"#{sentence}\" WHERE id = #{row['id']};")
end
