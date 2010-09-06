require 'rubygems'
require 'nokogiri'

doc = Nokogiri::XML($<.read)

doc.xpath("/*[@jwcid='$content$']").each do |tag|
  tag.remove_attribute('jwcid')
  tag.name = "t:content"
end

doc.xpath("//*[@jwcid='@Insert']").each do |tag|
  tag.swap("${" + tag['value'].sub("ognl:",'') + "}")
end

doc.xpath("//*[@jwcid='@If']").each do |tag|
  if tag['element']
    tag.name = tag['element']
    tag.remove_attribute('element')
    tag['t:type'] = "if"
  else
    tag.name = "t:if"
  end

  tag.remove_attribute('jwcid')
  tag.attribute('condition').name = 'test'
  tag['test'] = tag['test'].sub("ognl:",'')
end

doc.xpath("//*[@jwcid='@Else']").each do |tag|
  if_node = tag.previous_element
  new_node = doc.create_element('p:else')
  new_node << tag
  tag.remove_attribute('element')
  tag.remove_attribute('jwcid')
  if_node << new_node
end

doc.xpath("//*[@jwcid='@For']").each do |tag|
  tag.name = 't:loop'
  tag.remove_attribute('jwcid')
  tag['source'] = tag['source'].sub("ognl:",'')
  tag['value'] = tag['value'].sub("ognl:",'')
end

new_root = doc.create_element("html")
new_root.add_namespace("t", "http://tapestry.apache.org/schema/tapestry_5_1_0.xsd")
new_root.add_namespace("p", "tapestry:parameter")
new_root << doc.create_element("head") << doc.create_element("title")
new_root << doc.root
doc.root = new_root

print doc.to_xml(
  :indent => 2,
  :save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION | Nokogiri::XML::Node::SaveOptions::FORMAT,
  :encoding => "UTF-8"
)