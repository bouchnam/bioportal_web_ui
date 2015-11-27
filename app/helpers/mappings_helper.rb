module MappingsHelper

  RELATIONSHIP_URIS = {
    "http://www.w3.org/2004/02/skos/core" => "skos:",
    "http://www.w3.org/2000/01/rdf-schema" => "rdfs:",
    "http://www.w3.org/2002/07/owl" => "owl:",
    "http://www.w3.org/1999/02/22-rdf-syntax-ns" => "rdf:"
  }

  # Used to replace the full URI by the prefixed URI
  RELATIONSHIP_PREFIX = {
      "http://www.w3.org/2004/02/skos/core#" => "skos:",
      "http://www.w3.org/2000/01/rdf-schema#" => "rdfs:",
      "http://www.w3.org/2002/07/owl#" => "owl:",
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#" => "rdf:",
      "http://purl.org/linguistics/gold/" => "gold:",
      "http://lemon-model.net/lemon#" => "lemon:"
  }

  INTERPORTAL_HASH = $INTERPORTAL_HASH

  def get_short_id(uri)
    split = uri.split("#")
    name = split.length > 1 && RELATIONSHIP_URIS.keys.include?(split[0]) ? RELATIONSHIP_URIS[split[0]] + split[1] : uri
    "<a href='#{uri}' target='_blank'>#{name}</a>"
  end

  # a little method that returns true if the URIs array contain a gold:translation or gold:freeTranslation
  def is_translation(relation_array)
    if relation_array.kind_of?(Array)
      relation_array.map!(&:downcase)
      if relation_array.include? "http://purl.org/linguistics/gold/translation"
        true
      elsif relation_array.include? "http://purl.org/linguistics/gold/freetranslation"
        true
      else
        false
      end
    else
      LOG.add :error, "Warning: Mapping relation is not an array"
      false
    end
  end

  # a little method that returns the uri with a prefix : http://purl.org/linguistics/gold/translation become gold:translation
  def get_prefixed_uri(uri)
    RELATIONSHIP_PREFIX.each { |k, v| uri.sub!(k, v) }
    return uri
  end

  # method to get (using http) prefLabel for interportal classes
  def get_link_for_interportal_cls_ajax(class_uri, class_ui_url)
    interportal_key = get_interportal_key(class_ui_url)
    if interportal_key
      json_class = JSON.parse(Net::HTTP.get(URI.parse("#{class_uri}?apikey=#{interportal_key}")))
      if !json_class["prefLabel"].nil?
        return json_class["prefLabel"]
      else
        return nil
      end
    else
      return nil
    end
  end

  def get_link_for_cls_ajax(cls_id, ont_acronym, target=nil)
    # Note: bp_ajax_controller.ajax_process_cls will try to resolve class labels.
    # Uses 'http' as a more generic attempt to resolve class labels than .include? ont_acronym; the
    # bp_ajax_controller.ajax_process_cls will try to resolve class labels and
    # otherwise remove the UNIQUE_SPLIT_STR and the ont_acronym.
    if target.nil?
      target = ""
    else
      target = " target='#{target}' "
    end
    if cls_id.start_with? 'http://'
      href_cls = " href='#{bp_class_link(cls_id, ont_acronym)}' "
      data_cls = " data-cls='#{cls_id}' "
      data_ont = " data-ont='#{ont_acronym}' "
      return "<a class='cls4ajax' #{data_ont} #{data_cls} #{href_cls} #{target}>#{cls_id}</a>"
    else
      return auto_link(cls_id, :all, :target => '_blank')
    end
  end

  # to get the apikey from the interportal instance of the interportal class.
  # The best way to know from which interportal instance the class came is to compare the UI url
  def get_interportal_key(class_ui_url)
    if !INTERPORTAL_HASH.nil?
      INTERPORTAL_HASH.each do |key, value|
        if class_ui_url.start_with?(value["ui"])
          return value["apikey"]
        else
          return nil
        end
      end
    end
  end

  # method to extract the prefLabel from the external class URI
  def get_link_for_external_cls(class_uri)
    if class_uri.include? "#"
      prefLabel = class_uri.split("#")[-1]
    else
      prefLabel = class_uri.split("/")[-1]
    end
    return prefLabel
  end

  # Replace the interportal mapping ontology URI (that link to the API) by the link to the ontology in the UI
  def get_interportal_ui_link(uri, process_name)
    interportal_acronym = process_name.split(" ")[2]
    if interportal_acronym.nil? || interportal_acronym.empty?
      return uri
    else
      return uri.sub!(INTERPORTAL_HASH[interportal_acronym]["api"], INTERPORTAL_HASH[interportal_acronym]["ui"])
    end
  end

end
