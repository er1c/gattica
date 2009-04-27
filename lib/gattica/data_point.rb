module Gattica
  
  # Represents a single "row" of data containing any number of dimensions, metrics
  
  class DataPoint
    
    include Convertible
    
    attr_reader :id, :updated, :title, :dimensions, :metrics, :xml
    
    # Parses the XML <entry> element
    def initialize(xml)
      @xml = xml.to_s
      @id = xml.at('id').inner_html
      @updated = DateTime.parse(xml.at('updated').inner_html)
      @title = xml.at('title').inner_html
      @dimensions = xml.search('dxp:dimension').collect do |dimension|
        { dimension.attributes['name'].split(':').last.to_sym => dimension.attributes['value'].split(':').last }
      end
      @metrics = xml.search('dxp:metric').collect do |metric|
        { metric.attributes['name'].split(':').last.to_sym => metric.attributes['value'].split(':').last.to_i }
      end
    end
    
    
    # Outputs in Comma Seperated Values format
    def to_csv(format = :long)
      output = ''
      
      # only output
      case format
      when :long
        output = "\"#{@id}\",\"#{@updated.to_s}\",\"#{@title}\","
      end
      
      # output all dimensions
      output += @dimensions.collect do |dimension|
        "\"#{dimension.value}\""
      end.join(',')
      output += ','
      
      # output all metrics
      output += @metrics.collect do |metric|
        "\"#{metric.value}\""
      end.join(',')
      
      return output
    end
    
    
    def to_yaml
      { 'id' => @id,
        'updated' => @updated,
        'title' => @title,
        'dimensions' => @dimensions,
        'metrics' => @metrics }.to_yaml
    end
    
  end
  
end