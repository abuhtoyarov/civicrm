module CiviCrm
  class XML
    class << self
      def parse(text)
        # CiviCRM <Result>s sometimes contain weird elements
        # like <preferred_communication_method><0></0></ ...
        # that Nokogiri::XML can't hang with. Get rid of them before
        # parsing.
        fixed_text = text.to_s.
                     gsub("\n", "").
                     gsub(/<(\w|_)+>\s*<\d+><\/\d+>\s*<\/(\w|_)+>/, "")

        doc = Nokogiri::XML.parse(fixed_text)

        results = doc.xpath('//Result')
        results.map do |result|
          hash = {}
          result.children.each do |attribute|
            next unless attribute.is_a?(Nokogiri::XML::Element)
            hash[attribute.name] = attribute.children[0].text rescue nil
          end
          hash
        end
      end
      def encode(resources)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.ResultSet do
            Array.wrap(resources).each do |resource|
              attributes = resource.respond_to?(:attributes) ? resource.attributes : resource
              xml.Result do
                attributes.each do |key, value|
                  xml.send key.to_sym, value
                end
              end
            end
          end
        end
        builder.to_xml
      end
    end
  end
end
