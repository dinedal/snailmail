require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

desc "Tests Twillio -> FFMpeg -> Google transcription in practice"
task :transcription_test do
  require "./lib/snailmail.rb"
  test_recording_url = %q{http://api.twilio.com/2010-04-01/Accounts/ACb84633f66d5af69d5d09b9b6535f1ed7/Recordings/RE6ff45ca6335a9b32a060fc997987f93e}

  expected_output = "hello this is paul trying out the recording service"

  transcription = Snailmail::Transcription.wav_to_text(test_recording_url).downcase

  if expected_output != transcription
    $stderr.puts "Transcription failed"
    $stderr.puts "Expected: #{expected_output}"
    $stderr.puts "Transcription returned: #{transcription}"
    raise Exception, "Transcription failed"
  else
    puts "Transcription test passed"
  end
end
