require 'net/ssh'

def sshexec(cmd)
  Net::SSH.start('localhost', @user, :port => 2222) do |ssh|
    return ssh.exec!(cmd)
  end
end

Given(/^my system hasn't transprouter$/) do
  @user = "direct"
end

Given(/^a web resource (https?:.+) is not accessible$/) do |url|
  body = sshexec("curl #{url}")
  expect(body).to eq("curl: (6) Couldn't resolve host 'web.away'\n")
end

When(/^my system has transprouter$/) do
  @user = "proxied"
end

When(/^I access web resource (https?:.+)$/) do |url|
  Net::SSH.start('localhost', @user, :port => 2222) do |ssh|
    @http_response_body = ssh.exec!("curl --silent #{url}")
  end
end

Then(/^the request response body contain$/) do |expected_body|
  expect(@http_response_body).to eq(expected_body)
end

Given(/^a SSH service on (.+) is is not accessible$/) do |host|
  output = sshexec("ssh root@#{host} true")
  expect(output).to eq("ssh: Could not resolve hostname #{host}: Name or service not known\r\n")
end

When(/^I execute "([^"]*)" on (.+)$/) do |cmd, host|
  @sshexec_output = sshexec("ssh root@#{host} #{cmd}")
end

Then(/^the command result is$/) do |expected_output|
  expect(@sshexec_output).to eq(expected_output)
end