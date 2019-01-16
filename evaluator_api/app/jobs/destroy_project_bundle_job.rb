class DestroyProjectBundleJob < ActiveJob::Base
  queue_as :default

  rescue_from(ActiveJob::DeserializationError) do
  end

  def perform(project_bundle)
    project_bundle.destroy
  end
end
