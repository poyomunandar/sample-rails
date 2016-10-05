AGENT
The agent can be installed limited only to linux OS.
Prerequisite: Ruby version 2.2.3
Steps:
1. Copy the Agent to the agent machine. Let's assume this directory is our root directory.
2. Modify the configuration file in config/config.yml:
  - Set the server IP and PORT to the real server IP and real port where server is listening
  - Set the ALERT_FILENAME to an existing directory (the file will be created by the application)
  - Set the agent PORT to the real port where the agent is listening
  - Set the agent IP to the real IP of the agent
  - Leave the other
3. Run gem install bundle from command console  
4  Run bundle install from command console 
5. Run bin/crossover_trial_agent from command console


SERVER
The rails server theoretically can be installed in any OS but the creator only test it in Ubuntu and Windows. For windows, make sure any issues such as SSL and devkit already installed properly so gem installation will be running fine.
Prerequisite: Ruby version 2.2.3, Rails 5.0, MySQL database is running and ready to use
Steps:
1. Copy the Server to the server machine. Let's assume this directory is our root directory.
2. Modify the configuration file in config/config.yml:
  - Set the server IP and PORT to the real server IP and real port where server is listening
  - Set the agent PORT to the real port where the agent is listening
  - Leave the other
3. Run gem install bundle from command console
4. Run bundle install from command console
5. Modify the database config file in config/database.yml
  - Set the host to the IP of the database machine
  - Set username and password to a working username and password for the MySQL database
6. Run rake db:create from command console (We dont need a script to create the database and its tables, just run these commands instead)
7. Run rake db:migrate from command console (We dont need a script to create the database and its tables, just run these commands instead)
8. Run rails server -e development from command console
9. Wait for a while after agent and server run before doing the test. This is to make sure some data has been stored in the database


HOW TO TEST
1. Open browser, set URL to htp://<server IP>:<server PORT> and press enter. This should open the CPU Usage page for the first time
2. Webservice API: 
   - http://<server IP>:<server PORT>/webservices/cpu_usage?agent_ip=<agent IP>&password=password&user=test
   - http://<server IP>:<server PORT>/webservices/disk_usage?agent_ip=<agent IP>&password=password&user=test
   - http://<server IP>:<server PORT>/webservices/running_process?agent_ip=<agent IP>&password=password&user=test
   
HOW TO RUN THE UNIT TEST
- For agent: go to the agent root directory and run rspec in the command console
- For server: go to the server directory and run rspec in the command console. Notes: need to have an active database, so make sure the database.yml already pointed to a working database before run the rspec.
