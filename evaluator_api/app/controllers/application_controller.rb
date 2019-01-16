class ApplicationController < ActionController::API
  include ResourceInferrable
  include AuthenticationFilterable
  include NotCachable
  include Rescuer
  include JSONRenderable
  include TransactionWrappable

  # POST /api/{plural}
  def create
    set_resource(resource_class.new(resource_params))
    if get_resource.save
      render json: get_resource, status: :created
    else
      render json: get_resource.errors, status: :unprocessable_entity
    end
  end

  # GET /api/{plural_resource_variable}
  def index
    resources = apply_query(base_index_query, query_params)
                .order(order_args)
                .page(page_params[:page])
                .per(page_params[:page_size])
    instance_variable_set(plural_resource_variable, resources)
    render_multiple
  end

  # GET /api/{resource_name}/:id
  def show
    render json: get_resource if stale?(get_resource, template: false)
  end

  # DELETE /api/{resource_name}/:id
  def destroy
    get_resource.destroy
    head :no_content
  end

  # PATCH/PUT /api/{resource_name}/:id
  def update
    if get_resource.update(resource_params)
      render json: get_resource
    else
      render json: get_resource.errors, status: :unprocessable_entity
    end
  end

  protected

  # By default it is resource_class
  # Override for special filtering
  # Usage is base_index_query.where(...)...
  def base_index_query
    resource_class
  end

  # Returns the allowed parameters for searching
  # Override this method in each controller
  # to permit additional parameters to query on
  def query_params
    {}
  end

  # Returns the allowed parameters for pagination
  def page_params
    params.permit(:page, :page_size)
  end

  def error_messages
    Rails.application.config.configurations[:error_messages]
  end

  def messages
    Rails.application.config.configurations[:messages]
  end

  def apply_query(base, query_params)
    base.where(query_params)
  end

  def order_args
    :created_at
  end
end
