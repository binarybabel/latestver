module ApplicationHelper
  def body_c
    c = params[:controller].to_s.split('/').last
    a = params[:action]
    "#{c} #{c}-#{a}"
  end

  def active_c(input)
    if input
      'active'
    else
      ''
    end
  end

  def last_catalog_refresh
    time = CatalogEntry.order('refreshed_at DESC').first.try(:refreshed_at)
    time && time.to_s || 'Never'
  end

  def instance_groups
    Group.order(:name).all.map { |g| g.name }
  end

  def code_sample(input, opts=nil)
    opts = {theme: '', icon: 'terminal', label: ''}.merge(opts.to_h)
    (%%<div class="input-sample #{opts[:theme]} form-control"><i class="fa fa-#{opts[:icon]}"> #{opts[:label]}</i><code>% +
        input.gsub(/<([^>]+)>/, '<span class="token">\\1</span>') +
        '</code></div>').html_safe
  end

  def badge_snippet(entry, type='html', version=nil)
    data = {
        href: catalog_view_url(name: entry.name, tag: entry.tag),
        alt: I18n.t('app.nav.title'),
        src: catalog_view_api_url(name: entry.name, tag: entry.tag, format: 'svg')
    }
    data[:src] += "?v=#{version}" if version
    case type.to_s
      when 'md'
        '[![%{alt}](%{src})](%{href})' % data
      else
        '<a href="%{href}"><img alt="%{alt}" src="%{src}" /></a>' % data
    end
  end
end
