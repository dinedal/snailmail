require 'json'

class Snailmail::Transcription
  def self.wav_to_text(url)
    # Sorry twillio, your service costs money and google does a good job
    #
    # Here I stream the recording url through ffmpeg to get flac, and
    # simultaneously upload to google for transcription

    json_result = JSON.parse %x{curl #{url} 2> /dev/null | ffmpeg -i pipe:0 -vn -sn -acodec flac -f flac pipe:1 2> /dev/null | curl -v -X POST -H 'Content-Type: audio/x-flac; rate=8000' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7' --data-binary @- "https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US&results=10" 2> /dev/null}

    json_result["hypotheses"].sort_by{|h| -h["confidence"]}.first["utterance"]
  end
end
