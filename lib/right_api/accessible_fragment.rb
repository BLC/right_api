module AccessibleFragment
  def initialize(data, connection)
    @data = data
    @connection = connection
  end
  
  def has_element?(elem)
    !@data.search(elem).size.zero?
  end
  
  def get_element(elem)
    @data.search(elem).first.inner_text
  end
  
  def method_missing(method_name, *args)
    name_with_dashes = method_name.to_s.gsub('_', '-')
    has_element?(name_with_dashes) ? get_element(name_with_dashes) : super
  end
end