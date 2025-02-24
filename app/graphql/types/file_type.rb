module Types
  class FileType < Types::BaseScalar
    description "A valid URL, transported as a string"

    def self.coerce_input(file, context)
      ActionDispatch::Http::UploadedFile.new(
        filename: file.original_filename,
        type: file.content_type,
        headers: file.headers,
        tempfile: file.tempfile,
      )
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      return nil #{ message: "Oops, something went wrong!", errors: [e.message] }
    end
  end
end