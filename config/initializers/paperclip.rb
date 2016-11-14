require 'paperclip/media_type_spoof_detector'

module Paperclip
  class MediaTypeSpoofDetector
    def type_from_file_command
      begin
        Paperclip.run("file", "-b --mime :file", :file => @file.path)
      rescue

      end
    end
  end
end