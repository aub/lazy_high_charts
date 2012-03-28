#from 
#http://snippets.dzone.com/posts/show/4706
class Hash

  # Merges self with another hash, recursively.
  # 
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  # 
  # Thanks to whoever made it.

  def deep_merge(hash)
    target = dup
    
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      
      target[key] = hash[key]
    end
    
    target
  end
  def deep_merge!(second)
    second.each_pair do |k,v|
      if self[k].is_a?(Hash) and second[k].is_a?(Hash)
        self[k].deep_merge!(second[k])
      else
        self[k] = second[k]
      end
    end
  end
end

module LazyHighCharts
  class HighChart
    CANVAS_DEFAULT_HTML_OPTIONS = { :style => "height: 300px, width:615px" }
    SERIES_OPTIONS = %w(lines points bars shadowSize colors)

    attr_accessor :data, :options, :placeholder, :html_options
    alias  :canvas :placeholder
    alias  :canvas= :placeholder=

    def initialize(canvas = nil, html_opts = {})

      @collection_filter = nil
      self.tap do |high_chart|
        high_chart.data       ||= []
        high_chart.options    ||= {}
        high_chart.defaults_options
        high_chart.html_options = html_opts.reverse_merge(CANVAS_DEFAULT_HTML_OPTIONS)
        high_chart.canvas       = canvas if canvas
        yield high_chart if block_given?
      end
    end

    #	title:		legend: 		xAxis: 		yAxis: 		tooltip: 	credits:  :plotOptions

    def defaults_options
    self.title({:style=>{:fontFamily=>'Helvetica, Arial, Sans-Serif;', :fontSize=>'18px;', :fontWeight=>'bold', :color=>'black'}})
    self.legend({:borderWidth=> 1, :backgroundColor=>'#FFFFFF'}) 
    self.x_axis({})
    self.y_axis({})
    self.tooltip({ :enabled=>true })
    self.credits({:enabled => false})
    self.colors([].to_json)
    self.plot_options({})
    self.chart({:defaultSeriesType=>"line" , :renderTo => nil})
    self.subtitle({})
    end


    # Pass other methods through to the javascript high_chart object.
    #
    # For instance: <tt>high_chart.grid(:color => "#699")</tt>
    #
    def method_missing(meth, opts = {})
      merge_options meth, opts
    end

    # Add a simple series to the graph:
    # 
    #   data = [[0,5], [1,5], [2,5]]
    #   @high_chart.series :name=>'Updated', :data=>data
    #   @high_chart.series :name=>'Updated', :data=>[5, 1, 6, 1, 5, 4, 9]
    #
    def series(opts = {})
      @data ||= []
      if opts.blank?
        @data << series_options.merge(:name => label, :data => d)
      else
        @data << opts.merge(:name => opts[:name], :data => opts[:data])
      end
    end

private

    def series_options
      @options.reject {|k,v| SERIES_OPTIONS.include?(k.to_s) == false}
    end

    def merge_options(name, opts)
      @options.deep_merge!  name => opts
    end

    def arguments_to_options(args)
      if args.blank? 
        {:show => true}
      elsif args.is_a? Array
        args.first
      else
        args
      end
    end

  end
end
