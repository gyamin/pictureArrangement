# encoding: utf-8
#--
# #-- から #++まではRdocでのコメント生成が行われない。
#++

require 'fileutils'
require 'exifr'

class PictureArrangement

  attr_accessor :source_dir, :destination_dir, :stage

  def initialize(source_dir, destination_dir)
    if File.exist?(source_dir)
      @source_dir = source_dir
    else
      raise "Directory not exist"    
    end
    if File.exist?(destination_dir)
      @destination_dir = destination_dir
    else
      raise "Directory not exist"    
    end
  end
    
  # === Description: Return files in @source_dir direcotory.
  # === param:
  # * Array   exteintions : file extentions added to return pictures. 
  # === return:
  # * Array   files in @source_dir direcotory     
  def get_pictures(extentions, target_dir=@source_dir)
    selected_files = Array.new
    files = Dir::entries(target_dir)
    files.each{ |file|
      extentions.each{ |extention|
        reg = Regexp.new("\.#{extention}")
        if reg =~ file
          selected_files.push("#{target_dir}/#{file}") 
        end
      } 
    }
    return selected_files
  end
    
  # === Description: Make directory where pictures are stored.
  # === param:
  # * String  Directory path 
  # === return:
  # *    
  def make_destination_dir(dest_dir)
    unless File.exist?(dest_dir)
      #ディレクトリが存在しない場合作成
      FileUtils.mkdir_p(dest_dir) 
    end
  end

  def arrange_pictures(txtbox_progress = nil)
    pictures = self.get_pictures(["JPG", "NEF"])
    progress_denominator = pictures.length

    pictures.each_with_index do |picture, i|

      # 進捗表示する場合
      if(txtbox_progress)
        txtbox_progress.text = "#{i + 1}/#{progress_denominator}"
      end
      
      # ファイルがJPGでない場合、次のループへ
      next if not /JPG$/ =~ picture

      camera = EXIFR::JPEG.new(picture).model
      date = EXIFR::JPEG.new(picture).date_time
      dir_date = date.strftime("%Y%m%d")

      # originalディレクトリ作成
      original_dir = "#{@destination_dir}/original/#{dir_date}" 
      self.make_destination_dir(original_dir)
      # picturesディレクトリ作成
      pictures_dir = "#{@destination_dir}/pictures/#{dir_date}" 
      self.make_destination_dir(pictures_dir)

      if File.exist?(original_dir)
        # NEFファイルが存在する場合は、NEFファイルのみをオリジナルにコピー
        basename = File.basename(picture, ".JPG")
        raw_file = "#{@source_dir}/#{basename}.NEF"
        if File.exist?(raw_file)
          # NEFファイルが存在する
          FileUtils.cp(raw_file, original_dir)
          FileUtils.cp(raw_file, pictures_dir)
        else
          # NEFファイルが存在しない
          FileUtils.cp(picture, original_dir)
        end
      end

      if File.exist?(pictures_dir)
        FileUtils.cp(picture, pictures_dir)
      end

    end
  end
end 
