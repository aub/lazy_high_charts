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
      options_collection = jsonify_hash_with_exceptions(object.options, ["onclick", "load", "formatter", "events"])
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

    def jsonify_hash_with_exceptions(hash, exceptions)
      options_collection = []
      hash.keys.each do |key|
        k = key.to_s.camelize.gsub!(/\b\w/) { $&.downcase }
        if hash[key].is_a? Hash
          options_collection << "#{k}: {#{jsonify_hash_with_exceptions(hash[key], exceptions).join(", ")}}"
        else
          if exceptions.include?(k)
            options_collection << "#{k}: #{hash[key]}"
          else
            options_collection << "#{k}: #{hash[key].to_json}"
          end
        end
      end
      options_collection
    end
  end
end
