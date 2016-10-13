
module Manager
  class Files

    def list(path)
      list = %x( ls #{ENV['HOME']}/.jarvis/#{path} )
      list = list.split('\n')
      list.each do |item|
        item = item.slice! '.yml'
      end
    end

  end
end