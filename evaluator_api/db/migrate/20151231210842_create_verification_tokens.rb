class CreateVerificationTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :verification_tokens do |t|
      t.references :user, index: { unique: true }, foreign_key: true
      t.string :token, null: false
      t.timestamps null: false
    end
    add_index :verification_tokens, [:user_id, :token]
    add_index :verification_tokens, :created_at
  end
end
