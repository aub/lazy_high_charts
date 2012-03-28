# coding: utf-8
module LazyHighCharts
  module LayoutHelper

    def high_chart(placeholder, object  , formatter=nil)
      object.html_options.merge!({:id=>placeholder})
      object.options[:chart][:renderTo] = placeholder
      high_graph(placeholder,object , formatter)#.concat(content_tag("div","", object.html_options))
    end

    def high_stock(placeholder, object  , formatter=nil)
      object.html_options.merge!({:id=>placeholder})
      object.options[:chart][:renderTo] = placeholder
      high_graph_stock(placeholder,object , &block).concat(content_tag("div","", object.html_options))
    end

    def high_graph(placeholder, object, formatter=nil)
      build_html_output("Chart", placeholder, object, formatter)
    end

    def high_graph_stock(placeholder, object, formatter=nil)
      build_html_output("StockChart", placeholder, object, &block)
    end

    def build_html_output(type, placeholder, object, formatter=nil)
      options_collection = []
      object.options.keys.each do |key|
        k = key.to_s.camelize.gsub!(/\b\w/) { $&.downcase }
        options_collection << "#{k}: #{object.options[key].to_json}"
      end
      options_collection << "series: #{object.data.to_json}"

      graph =<<-EOJS
      <script type="text/javascript">
      (function() {
        var onload = window.onload;
        window.onload = function(){
          if (typeof onload == "function") onload();
          var options, chart;
          options = { #{options_collection.join(",")} };
          #{formatter if formatter}
          chart = new Highcharts.#{type}(options);
        };
      })()
      </script>
      EOJS

      if defined?(raw)
        return raw(graph) 
      else
        return graph
      end

    end
  end
end
