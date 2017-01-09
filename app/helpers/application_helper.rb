module ApplicationHelper
  def body_class
    c = params[:controller].to_s.split('/').last
    a = params[:action]
    "#{c} #{c}-#{a}"
  end

  def last_catalog_refresh
    time = CatalogEntry.order('refreshed_at DESC').first.try(:refreshed_at)
    time && time.to_s || 'Never'
  end

  def instance_groups
    Group.order(:name).all.map { |g| g.name }
  end

  def input_sample(input, opts=nil)
    opts = {theme: '', icon: 'terminal', label: ''}.merge(opts.to_h)
    (%%<div class="input-sample #{opts[:theme]} form-control"><i class="fa fa-#{opts[:icon]}"> #{opts[:label]}</i><code>% +
        input.gsub(/<([^>]+)>/, '<span class="token">\\1</span>') +
        '</code></div>').html_safe
  end
end
