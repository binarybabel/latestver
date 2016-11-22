class GroupController < ApplicationController
  def index
    @group_name = params[:group]
    @group = Group.find_by!(name: @group_name)
    @instances = Instance.where(:group => @group).joins(:catalog_entry).order('catalog_entries.name')
  end

  def update
    index
    Instance.transaction do
      @instances.each do |i|
        k = "ver_#{i.id}".to_sym
        v = params[k].to_s
        unless v.to_s.empty? or v == i.version
          v = nil if %w(l latest).include?(v)
          i.update!(v)
        end
      end
    end
    render 'index'
  end
end
