result_all = {}

def isDir? dir
  begin
    Dir.new(dir)
  rescue
    return false
  end
  return true
end

def read_dir(dir, criterias)
  result = []
  dir = Dir.new(dir)
  dir.each do |file|
    next if file == '.' || file == '..'
    fullpath = dir.path + '\\' + file
    if isDir?(fullpath)
      result << read_dir(fullpath, criterias)
    else     
      pass = false	
      criterias.each do |criteria|
	    pass = false
	    criteria.each do |crit|
			unless fullpath.match(crit)
			  pass = true
			  break
			end
		end	
        break unless pass		
      end
      next if pass
      result << fullpath
    end
  end
  return result
end

#get input parameters of each endpoint on pruhub
path = 'C:\\MyWorld\\BackofficeWeb'
controller_dir = read_dir(path, [['controllers','trunk']])
endpoint_content = {}
pruconstant_path = read_dir(path, [['pruforce\.constant\.js']])
pruconstant_content = File.read(pruconstant_path.flatten[0])

controller_dir.flatten.each do |filename| begin
    file_content = File.readlines(filename)
	last100lines = []
	counter = 0
	# remove after finish the testing
	# next unless filename.match('NewsUpdateApprovalController.js')
	puts "filename: #{filename}"
    file_content.each do |line|
      next if /^[ \t]*\/\//.match(line) # do not process if it's remarked
	  last100lines.delete_at(0) if counter > 100
	  last100lines << line
	  counter += 1
      # check if there is service calling
	  input_parameter = ''
      if /[ \t]+([a-zA-Z0-9]+Service[s]*)\.([a-zA-Z0-9]+)[ \t]*\([ \t]*([a-zA-Z0-9\{\} :\$\._]+)[a-zA-Z0-9\{\},:\$\._ ]*\)/.match(line)
        service_name = Regexp.last_match.captures[0]       	
		method_name = Regexp.last_match.captures[1]        
		parameter_name = Regexp.last_match.captures[2]    
        puts "service_name: #{service_name}"
		puts "method_name: #{method_name}"
		puts "parameter_name: #{parameter_name}"
        if parameter_name.match(/[\{\}]+/)
          puts "case 1"
		  # case 1, the input parameter already json
		  input_parameter = parameter_name.gsub(/[\{\}]/, '')
		  puts "input_parameter: #{input_parameter}"
		else
		  # check in the last 100 lines the real input parameters
		  if /#{parameter_name.gsub(/\}/,'\\}').gsub(/\{/,'\\{')}[ \t\r\n]*=[ \t\r\n]*\{([ \$\t\r\n:\.,\[\]\(\)"'a-zA-Z0-9]+)\}/.match(last100lines.join("\r\n"))
		    puts "case 2"
		    # case 2, the input parameter is defined already before as a full json
		    input_parameter = Regexp.last_match.captures[-1]
		    puts "Regexp.last_match.captures[-1]: #{Regexp.last_match.captures[-1]}"
		  else
		    puts "case 3"
		    dt = []
		    puts "case 3.1"
		    last100lines.each do |line_in_parameter|
			  if /#{parameter_name.gsub(/\}/,'\\}').gsub(/\{/,'\\{')}\.([a-zA-Z0-9]+)[ \r\n\t]*=[ \r\n\t]*/.match(line_in_parameter)
			    puts "Regexp.last_match.captures[0]: #{Regexp.last_match.captures[0]}"
			    dt << Regexp.last_match.captures[0] + ':' + Regexp.last_match.captures[0]
			  end
			end
			puts "case 3.2"
			input_parameter = dt.uniq.join(',')
			puts "case 3.3"
			puts "dt.join(','): #{input_parameter}"
		  end	
		end
		if input_parameter == ''
		  input_parameter = parameter_name
		  puts "input_parameter == '': #{input_parameter}"
		end

		service_name = "BannerServices" if service_name == 'CorporateBannerServices'
        services_dir = read_dir(path, [['services','trunk',service_name[0..-2]]])
        puts "service_name[0..-2]: #{service_name[0..-2]}"
		base_path = ''
		api_path = ''
		services_dir.flatten.each do |fn|
		  puts "filename service: #{fn}"
		  fl_content = File.read(fn)
		  
		  if /function[ \t\r\n]*#{method_name}[ \r\n\t]*\([ \r\n\ta-zA-Z0-9\[\]\(\)\{\},\.";_=:\$]+API_PATH\.([A-Za-z0-9_]+)/.match(fl_content)		    
			api_path = Regexp.last_match.captures[0]
		  end
		  if /function[ \t\r\n]*#{method_name}[ \r\n\t]*\([\/ \r\n\ta-zA-Z0-9\[\]\(\)\{\},'\.";_=:\$\+]+\(API_ADDRESS\.([A-Za-z0-9_]+)[, a-zA-Z0-9 \._]+\)/.match(fl_content)
		    api_address = Regexp.last_match.captures[0]
		  end
		  puts "api_address: #{api_address}"
		  puts "api_path: #{api_path}"
		  if /#{api_address}: "http:\/\/[a-z0-9:\/\.]+(\/[a-zA-Z0-9]+)"/.match(pruconstant_content)
		    base_path = Regexp.last_match.captures[0] unless api_address.nil?
		  end
		  if /#{api_path}: '([a-zA-Z0-9\/]+)'/.match(pruconstant_content)
		    api_path = Regexp.last_match.captures[0]
		  end
		  puts "base_path after: #{base_path}"
          puts "api_path after: #{api_path}"
		end

		next if base_path == ''
		real_api = base_path + api_path
		puts "real_api: #{real_api}"
		endpoint_content[real_api.downcase] = input_parameter.strip
		
      end
    end    
  rescue => ex
    puts ex.message
    next
  end
end


#get input parameters of each endpoint based on the adapter files
file_content = File.read('C:\\Users\\c17623\\Documents\\adapters.txt')
file_content.scan(/var[ \t\r\n]+content[ \t\r\n\/]*=[ \t\r\n\/\*\[\]]*\{([ \r\n\t a-zA-Z0-9\:\"\/\,\=\+\*\.\%\-\'\{\[\]\;]*)\}[ \r\n\t a-zA-Z0-9\:\"\/\,\=\+\*\.\%\}\-\'\{\[\]\;]*"X-Requested-Url"[ \t\r\n]*:[ \t\r\n]*'([\/'a-zA-Z0-9_\.]*)'/).each do |data|
  endpoint_content[data[1].downcase] = data[0]
end
file_content.scan(/var[ \t\r\n]+content[ \t\r\n\/]*=[ \t\r\n\/\*\[\]]*\{([ \r\n\t a-zA-Z0-9\:\"\/\,\=\+\*\.\%\-\'\{\[\]\;]*)\}[ \r\n\t a-zA-Z0-9\:\"\/\,\=\+\*\.\%\}\-\'\{\[\]\;]*path[ \t\r\n]*:[ \t\r\n]*'([\/'a-zA-Z0-9_\.]*)'/).each do |data|
  next if data[1].strip == 'request.path' || data[1].strip == '/base/proxy'
  endpoint_content[data[1].strip.downcase] = data[0].strip
end

path = 'C:\\MyWorld'
services_dir = read_dir(path, [['Service','trunk']])

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
        query += line.gsub(/\s/, ' ')
        # checking if the line contains method declaration or variable declaration or newline as a sign of the end of the query
      elsif start_record_query && (/^[ \t\r\n]*$/.match(line) || /^[ \t]*def[ \t]+/.match(line) || /^[ \t]*[a-zA-Z0-9]+[ \t]+[a-zA-Z0-9]+[ \t]*=/.match(line))
        queries << query
        query = ''
        start_record_query = false
      elsif start_record_query
        query += line.gsub(/\s/, ' ')
      end
      map_method_query[current_method] = queries unless queries == [] || map_method_query[current_method]
    end
    map_method_query.each do |key, value|
      result_all[filename.split('\\')[-1].split('.')[0].downcase + '.' + key.downcase] = value unless value == []
    end
  rescue
    next
  end
end

endpoint_query = {}
controllers_dir = read_dir(path,[['(Controllers|controllers)','trunk']])

controllers_dir.flatten.each do |filename| begin
    file_content = File.readlines(filename)
    current_method = ''
    current_classname = ''
    file_content.each do |line|
      next if /^[ \t]*\/\//.match(line) # do not process if it's remarked
      # checking if the line contains class declaration
      if /class[ \t]+([a-zA-Z0-9]+)[\t ]*\{/.match(line)
        current_classname = Regexp.last_match.captures[0]
      end  
      # checking if the line contains method declaration
      if /[a-zA-Z0-9]+[ \t]+([a-zA-Z0-9 \t]+)\([a-zA-Z0-9 \t,]*\)[\t ]*\{/.match(line)
        if (current_method != Regexp.last_match.captures[0])
          current_method = Regexp.last_match.captures[0]
        end
      end
      endpoint = {}
      config_file = filename.split('\\')[0..5].join('\\') 
	  config_file += '\\conf\\application.yml'
      if (!endpoint[config_file] && /(context-path|contextPath)[ \t]*:[ \t]*[']*(\/[a-zA-Z0-9]+)[']*/.match(IO.read(config_file)))
        prefix =  Regexp.last_match.captures[1]
        endpoint[config_file] = prefix
	  end
      # check if there is service calling
      if /[ \t]+([a-zA-Z0-9]+Service\.[a-zA-Z0-9]+)/.match(line)
        key = Regexp.last_match.captures[0]
        endpoint_name = ((endpoint[config_file].downcase == ('/' + current_classname.gsub(/Controller/,'').downcase) || endpoint[config_file].downcase.match('pushnotif')) ? endpoint[config_file] : (endpoint[config_file] + '/' + current_classname.gsub(/Controller/,''))) + '/' + current_method
        endpoint_query[endpoint_name] = result_all[key.downcase] || ['No query']
      end
    end
  rescue
    next
  end
  f = File.new('C:\\Users\\c17623\\Documents\\endpointQuery.csv','w+')
  endpoint_query.each do |key, value|    
    f.write key
	if(endpoint_content[key.downcase] != nil)
		f.write "~" + endpoint_content[key.downcase].gsub(/\s/, '').gsub(',','!!!')
	else
		f.write "~No Input Parameters"
	end
    value.each {|data| f.puts '~' + data.gsub(',','!!!') if data!= nil && data != ''}
  end
end
