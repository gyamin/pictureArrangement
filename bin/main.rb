# encoding: utf-8
require 'java'
require 'jrubyfx'
require_relative 'picture_arrangement'
fxml_root File.dirname(__FILE__)

class MainApp < JRubyFX::Application
  def start(stage)
    with(stage, title: "Picture Arrangement") do
      fxml MainController
      show
    end
  end
end

class  MainController
  include JRubyFX::Controller
  fxml "home.fxml"
  
  def choose_directory()
    directory_chooser = DirectoryChooser.new();
    directory = directory_chooser.showDialog(stage);
    return directory
  end
  
  def choose_file()
    file_chooser = FileChooser.new();
    file = file_chooser.showOpenDialog(stage);
    return file
  end
  
  def select_source_directory
    directory = self.choose_directory()
    @text_source_path.text = directory.getPath() if directory  
  end
  
  def select_destination_directory
    directory = self.choose_directory()
    @text_destination_path.text = directory.getPath() if directory
  end
  
  def arrange_pictures
    
    picture_arrangement = PictureArrangement.new(
                          @text_source_path.text, 
                          @text_destination_path.text)
                        
    # 写真整理実行
    picture_arrangement.arrange_pictures(@txtbox_progress);
    
  end
  
end

MainApp.launch()