class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :keywords do |t|
      t.string :company_name
      t.string :owner

      t.timestamps
    end
  end
end
