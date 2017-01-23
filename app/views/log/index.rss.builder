#encoding: UTF-8

xml.instruct! :xml, :version => '1.0'
xml.rss :version => '2.0' do
  xml.channel do
    xml.title 'Latestver Update Log'
    xml.author 'BinaryBabel OSS'
    xml.link 'https://lv.binarybabel.org'
    xml.language 'en-us'

    @catalog_log.each do |l|
      xml.item do
        xml.title "#{l.catalog_entry.label} #{l.version_to}"
        xml.category l.catalog_entry.to_param
        xml.pubDate l.created_at.to_s(:rfc822)
        xml.link catalog_view_url(name: l.catalog_entry.name, tag: l.catalog_entry.tag)
        xml.description "#{l.catalog_entry.to_param} updated to version #{l.version_to} from #{l.version_from or 'unknown'}"
        xml.guid "clu-#{l.id}"
      end
    end
  end
end
