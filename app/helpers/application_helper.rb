module ApplicationHelper
  def last_catalog_refresh
    time = CatalogEntry.order('refreshed_at DESC').first.try(:refreshed_at)
    time && time.to_s || 'Never'
  end

  def instance_groups
    Group.order(:name).all.map { |g| g.name }
  end

  def code_control(css_class, input)
    (%%<code class="#{css_class} form-control">% +
        input.gsub(/<([^>]+)>/, '<span class="token">&lt;\\1&gt;</span>') +
        '</code>').html_safe
  end
end
