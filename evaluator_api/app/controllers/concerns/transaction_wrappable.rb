module TransactionWrappable
  extend ActiveSupport::Concern

  protected
  def wrap_in_transaction
    resource_class.transaction do
      yield
    end
  end
end
