result_all = {}

def read_dir(dir, criterias)
  result = []
  dir = Dir.new(dir)
  dir.each do |file|
    next if file == '.' || file == '..'
    fullpath = dir.path + '\\' + file
    if Dir.exist?(fullpath)
      result << read_dir(fullpath, criterias)
    else
      pass = false
      criterias.each do |criteria|
        unless fullpath.match(criteria)
          pass = true
          break
        end
      end
      next if pass
      result << fullpath
    end
  end
  return result
end

path = 'D:\Documents\prudential\aob\BusinessLogic'
services_dir = read_dir(path, ['Service','trunk'])

services_dir.flatten.each do |filename| begin
    file_content = File.readlines(filename)
    current_method = ''
    queries = []
    query = ''
    start_record_query = false
    map_method_query = {}
    file_content.each do |line|
      next if /^[ \t]*\/\//.match(line) # do not process if it's remarked
      # checking if the line contains method declaration
      if /def[ \t]+([a-zA-Z0-9 \t]+)\([a-zA-Z0-9 \t,]*\)[\t ]*\{/.match(line)
        if (current_method != Regexp.last_match.captures[0])
          map_method_query[current_method] = queries
          current_method = Regexp.last_match.captures[0]
          queries = []
        end
      end
      # checking if the line contains main keyword for query
      if /([ \t'"]+select[ \t]+|[ \t'"]+SELECT[ \t]+|[ \t'"]+insert[ \t]+|[ \t'"]+INSERT[ \t]+|[ \t'"]+update[ \t]+|[ \t'"]+UPDATE[ \t]+|[ \t'"]+delete[ \t]+|[ \t'"]+DELETE[ \t]+|WHERE[ \t]+)/.match(line) && !start_record_query
        start_record_query = true
        query += line.gsub(/[\r\n \t]/,' ')
        # checking if the line contains method declaration or variable declaration or newline as a sign of the end of the query
      elsif start_record_query && (/^[ \t\r\n]*$/.match(line) || /^[ \t]*def[ \t]+/.match(line) || /^[ \t]*[a-zA-Z0-9]+[ \t]+[a-zA-Z0-9]+[ \t]*=/.match(line))
        queries << query
        query = ''
        start_record_query = false
      elsif start_record_query
        query += line.gsub(/[\r\n \t]/,' ')
      end
      map_method_query[current_method] = queries unless queries == [] || map_method_query[current_method]
    end
    map_method_query.each do |key, value|
      result_all[filename.split('\\')[-1].split('.')[0].downcase + '.' + key.downcase] = value unless value == []
    end
  rescue
    next
  end
  #  result_all.each do |key, value|
  #    puts key
  #    value.each {|data| puts data}
  #  end
end

endpoint_query = {}
controllers_dir = read_dir(path,['Controller.','trunk'])

controllers_dir.flatten.each do |filename| begin
    file_content = File.readlines(filename)
    current_method = ''
    file_content.each do |line|
      next if /^[ \t]*\/\//.match(line) # do not process if it's remarked
      # checking if the line contains method declaration
      if /[a-zA-Z0-9]+[ \t]+([a-zA-Z0-9 \t]+)\([a-zA-Z0-9 \t,]*\)[\t ]*\{/.match(line)
        if (current_method != Regexp.last_match.captures[0])
          current_method = Regexp.last_match.captures[0]
        end
      end
      endpoint = {}
      config_file = filename.split('\\')[0..8].join('\\') + '\\conf\application.yml'
      if (!endpoint[config_file] && /context-path:[ \t]*'(\/[a-zA-Z0-9]+)'/.match(IO.read(config_file)))
        prefix =  Regexp.last_match.captures[0]
        endpoint[config_file] = prefix
      end
      # check if there is service calling
      if /[ \t]+([a-zA-Z0-9]+Service\.[a-zA-Z0-9]+)/.match(line)
        key = Regexp.last_match.captures[0]
        endpoint_query[endpoint[config_file] + '/' + current_method] = result_all[key.downcase] || ['No query']
      end
    end
  rescue
    next
  end
  f = File.new("D:\\Documents\\prudential\\endpointQuery.csv",'w+')
  endpoint_query.each do |key, value|
    f.write key
    value.each {|data| f.puts ';' + data}
  end
end
