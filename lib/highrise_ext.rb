require "highrise"

Highrise::Base.format = :xml

Highrise::Party.class_eval do
  def notes
    Highrise::Note.find_all_across_pages(:from => "/#{type_collection_name}/#{id}/notes.xml")
  end

  def emails
    Highrise::Email.find_all_across_pages(:from => "/#{type_collection_name}/#{id}/emails.xml")
  end

  def name
    type_object.name
  end

  def type_object
    Highrise.const_get(attributes['type']).new(attributes)
  end

  def type_collection_name
    Highrise.const_get(attributes['type']).collection_name
  end
end
