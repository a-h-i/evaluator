module JSONRenderable
  extend ActiveSupport::Concern

  protected

  def render_multiple
    resources = instance_variable_get(plural_resource_variable)
    render json: {
      page: resources.current_page,
      total_pages: resources.total_pages,
      page_size: resources.size,
      "#{resource_name.pluralize}": resources.as_json
    }
  end

end
