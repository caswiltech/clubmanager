module ApplicationHelper
  
  def stringfix(str)
    str.split.map{|x| x.titleize.gsub(/ /,'')}.join(' ')
  end
end
