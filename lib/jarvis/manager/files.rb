
module Manager
  # top class
  class Files

    def list(path)
      list = `( ls #{ENV['HOME']}/.jarvis/#{path} )`
      list = list.split("\n")
      list.each do |item|
        item.slice! '.yml'
      end
    end

  end
end
