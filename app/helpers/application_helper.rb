module ApplicationHelper
  def last_catalog_refresh
    time = CatalogEntry.order('refreshed_at DESC').first.try(:refreshed_at)
    time && time.to_s || 'Never'
  end

  def instance_groups
    Instance.select(:group).distinct.map {|x| x.group}.sort
  end
end
