module Manager
  # top class
  class Files

    def source_path
      "#{ENV['HOME']}/.jarvis"
    end

    def list(path)
      list = `( ls #{source_path}/#{path} )`
      list = list.split("\n")
      list.each do |item|
        item.slice! '.yml'
      end
    end

    def create_tmp_dirs(plan_name, qtd)
      qtd.times do |i|
        `( mkdir -p  #{source_path}/tmp/#{plan_name}#{i + 1})`
      end
    end

    def delete_tmp
      `( rm -rf #{source_path}/tmp/* )`
    end

    def split_file(plan_name, file_path, qtd)
      csv = CSV.read(file_path, headers: false)
      file_name = file_path.split('/').last
      # npf = number per file
      npf = (csv.length / qtd).to_i
      if npf.zero?
        raise(RangeError, "Number of lines on file #{file_path} are less than split quantity...
                          \nPlease put more data to the file!")
      end

      qtd.times do |i|
        File.open("#{source_path}/tmp/#{plan_name}#{i + 1}/#{file_name}", 'w') do |f|
          aux = csv[(i * npf)..(((i + 1) * npf) - 1)].map(&:to_csv)
          aux[npf - 1] = aux.last.sub("\n", '')
          f.write aux.join
        end
      end
    rescue RangeError => msg
      puts msg
      delete_tmp
      exit!
    end

  end
end
